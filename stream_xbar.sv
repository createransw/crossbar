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
    for (genvar i = 0; i < M_DATA_COUNT; ++i) begin : control
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
    // автомат для каждого master-устройства
