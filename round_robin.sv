module round_robin #(
    parameter  T_DATA_WIDTH = 8,
               S_DATA_COUNT = 2,
               M_DATA_COUNT = 3,
               T_ID___WIDTH = $clog2(S_DATA_COUNT),
               T_DEST_WIDTH = $clog2(M_DATA_COUNT)
)(
    input  logic                        clk,
    input  logic                        rst_n,

    input  logic [T_DEST_WIDTH - 1 : 0] number,

    input  logic [T_DATA_WIDTH - 1 : 0] s_data_i [S_DATA_COUNT - 1 : 0],
    input  logic [T_DEST_WIDTH - 1 : 0] s_dest_i  [S_DATA_COUNT - 1 : 0],
    input  logic [S_DATA_COUNT - 1 : 0] s_last_i,
    input  logic [S_DATA_COUNT - 1 : 0] s_valid_i,

    input  logic                        m_ready_i,

    output logic                        m_valid_o,
    output logic                        m_last_o,

    output logic [T_DATA_WIDTH - 1 : 0] m_data_o,
    output logic [T_ID___WIDTH - 1 : 0] m_id_o,

    output logic [T_ID___WIDTH - 1 : 0] s_ready_id
);

typedef enum {WAIT, BUSY, LAST} state;
logic [1 : 0] c_state;
logic [T_ID___WIDTH - 1 : 0] order; // номер пердыдущего принятого запроса
logic instant;

task automatic search;
begin
    for (int i = 1; i <= S_DATA_COUNT; ++i) begin
        logic [T_ID___WIDTH - 1 : 0] id;
        logic fit;

        id = (order + i) % S_DATA_COUNT;
        fit = s_valid_i[id] && (s_dest_i[id] == number);

        if (fit) begin // найдено подходящее master-устройство
            instant = 1;
            order <= id; // обновление счетчика порядка
            m_valid_o <= 1;
            m_last_o <= s_last_i[id];
            m_data_o <= s_data_i[id];
            m_id_o <= id;

            if (s_last_i[id])
                c_state <= LAST;
            else
                c_state <= BUSY;
        end
    end
end
endtask

assign s_ready_id = order;
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        m_valid_o <= 0;
        m_last_o <= 0;

        order <= 0;
        c_state <= WAIT;
    end else begin
        case (c_state)
            WAIT: begin // slave-устройство ожидает передачу или m_ready_i
                if (m_ready_i) begin
                    search;
                end
            end
            BUSY: begin  // идёт передача 
                if (~m_ready_i) begin
                    m_valid_o <= 0;
                    c_state = WAIT;
                end else begin
                    m_valid_o <= 1;
                    m_last_o <= s_last_i[order];
                    m_data_o <= s_data_i[order];
                    m_id_o <= order;

                    if (s_last_i[order])
                        c_state <= LAST;
                end
            end
            LAST: begin // передаётся последний пакет
                if (~m_ready_i) begin
                    m_valid_o <= 0;
                    c_state <= WAIT;
                end else begin
                    instant = 0;
                    search;
                    if (~instant) begin // нового запроса нет
                        m_valid_o <= 0;
                        m_last_o <= 0;
                        order <= (order + 1) % S_DATA_COUNT;
                        c_state <= WAIT;
                    end
                end
            end
        endcase
    end
end

endmodule
