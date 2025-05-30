module round_robin #(
    parameter  S_DATA_COUNT = 2,
               M_DATA_COUNT = 3,
    localparam T_ID___WIDTH = $clog2(S_DATA_COUNT),
               T_DEST_WIDTH = $clog2(M_DATA_COUNT)
)(
    input  logic                        clk,
    input  logic                        rst_n,

    input  logic [T_DEST_WIDTH - 1 : 0] number,
    input  logic                        m_ready,

    input  logic [T_DEST_WIDTH - 1 : 0] s_dest_i  [S_DATA_COUNT - 1 : 0],
    input  logic [T_DEST_WIDTH - 1 : 0] s_valid_i,
    input  logic                        s_last,
    output logic [S_DATA_COUNT - 1 : 0] s_ready_o
);

typedef enum {READY, BUSY, WAIT} state;
logic [1 : 0] c_state;
logic [T_ID___WIDTH - 1 : 0] order; // номер пердыдущего принятого запроса

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        s_ready_o <= '0;
        c_state <= WAIT;
        order <= 0;
    end
end

always_ff @(posedge clk) begin
    case (c_state)
        READY: begin // slave-устройство готово принять данные 
            if (~m_ready) begin
                c_state = WAIT;
            end else begin
                for (int i = 0; i < S_DATA_COUNT; ++i) begin
                    logic [T_ID___WIDTH - 1 : 0] id; // номер master-кандидата
                    logic fit; // действительно ли требуется передача

                    id = (order + i) % S_DATA_COUNT;
                    fit = s_valid_i[id] && (s_dest_i[id] == number);
                    if (fit) begin
                        order <= id; // обновляем номер 
                        c_state <= BUSY;
                        break;
                    end
                end
            end
        end
        BUSY: begin  // идёт передача 
            if (~m_ready) begin
                c_state = WAIT;
            end else begin
                s_ready_o[order] <= 1; // показываем, что данные принимаются

                if (s_last) begin // обрабатывается последний пакет
                    s_ready_o <= 0;
                    order <= (order + 1) % S_DATA_COUNT;
                    c_state <= READY;
                end
            end
        end
        WAIT: begin // slave-устройство не готово
            if (m_ready)
                c_state <= READY;
        end
    endcase
end

endmodule
