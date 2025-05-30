module stream_xbar #(
    parameter  T_DATA_WIDTH = 8,
               S_DATA_COUNT = 2,
               M_DATA_COUNT = 3,
    localparam T_ID___WIDTH = $clog2(S_DATA_COUNT),
               T_DEST_WIDTH = $clog2(M_DATA_COUNT)
)(
    input logic clk,
    input logic rst_n,
    // multiple input streams
    input  logic [T_DATA_WIDTH-1:0] s_data_i  [S_DATA_COUNT-1:0],
    input  logic [T_DEST_WIDTH-1:0] s_dest_i  [S_DATA_COUNT-1:0],
    input  logic [S_DATA_COUNT-1:0] s_last_i ,
    input  logic [S_DATA_COUNT-1:0] s_valid_i,
    output logic [S_DATA_COUNT-1:0] s_ready_o,
    // multiple output streams
    output logic [T_DATA_WIDTH-1:0] m_data_o  [M_DATA_COUNT-1:0],
    output logic [T_ID___WIDTH-1:0] m_id_o    [M_DATA_COUNT-1:0],
    output logic [M_DATA_COUNT-1:0] m_last_o ,
    output logic [M_DATA_COUNT-1:0] m_valid_o,
    input  logic [M_DATA_COUNT-1:0] m_ready_i
);

typedef enum {WAIT, HALT, WRITE} state;
logic [1 : 0] c_state [S_DATA_COUNT - 1 : 0]; // состояния автоматов для master

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (int i = 0; i < S_DATA_COUNT; ++i)
            c_state[i] <= WAIT;
        s_ready_o <= '0;
        m_last_o <= '0;
        m_valid_o <= '0;
    end
end

generate
    // создаём round_robin модуль для каждого выхода
    for (genvar i = 0; i < M_DATA_COUNT; ++i) begin : order
        logic [T_DEST_WIDTH - 1 : 0] number;
        assign number = i;
        round_robin #(
            .S_DATA_COUNT(S_DATA_COUNT),
            .M_DATA_COUNT(M_DATA_COUNT)
        ) r_r (
            .clk(clk),
            .rst_n(rst_n),

            .number(number),
            .m_ready(m_ready_i[i]),

            .s_dest_i(s_dest_i),
            .s_valid_i(s_valid_i),
            .s_last(m_last_o[i])),
            .s_ready_o(s_ready_o)
        );
    end
endgenerate

generate
    // создаём управляющий автомат для каждого входа
    for (genvar i = 0; i < S_DATA_COUNT; ++i) begin : control
        always @(posedge clk) begin
            case (c_state[i])
                WAIT: begin // данных для передачи пока нет
                    if (s_valid_i[i] && ~s_ready_o[i]) begin
                        c_state[i] <= HALT;
                    end else if (s_valid_i[i]) begin
                        c_state[i] <= WRITE;
                    end
                end
                HALT: begin // есть данные для передачи, но slave не готово
                    if (s_ready_o[i])
                        c_state[i] <= WRITE;
                end
                WRITE: begin // slave-устройство готово
                    if (~s_ready_o[i]) begin
                        c_state[i] <= HALT;
                    end else begin

                        m_data_o[dest] <= s_data_i[i];
                        m_id_o[dest] <= i;
                        m_last_o[dest] <= s_last_i[i];
                        m_valid_o[dest] <= 1;

                        if (s_last_i[i]) begin // предаётся последний пакет
                            c_state[i] <= WAIT;
                            // сигнализируем о конце передачи
                            m_last_o[dest] <= 0;
                            m_valid_o[dest] <= 0;
                        end
                    end
                end
            endcase
        end
    end
endgenerate




generate
    // автомат для каждого master-устройства
