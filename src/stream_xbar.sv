module stream_xbar #(
    parameter  T_DATA_WIDTH = 8,
               S_DATA_COUNT = 2,
               M_DATA_COUNT = 3,
               T_ID___WIDTH = $clog2(S_DATA_COUNT),
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

// id master-устройств, которым открыта запись
logic [T_ID___WIDTH - 1 : 0] s_ready_id [M_DATA_COUNT - 1 : 0];

generate
    // создаём round_robin модуль для каждого выхода
    genvar i;
    for (i = 0; i < M_DATA_COUNT; ++i) begin : order
        logic [T_DEST_WIDTH - 1 : 0] number;
        logic valid;
        logic last;

        assign number = i;
        assign m_valid_o[i] = valid;
        assign m_last_o[i] = last;
        round_robin #(
            .T_DATA_WIDTH(T_DATA_WIDTH),
            .S_DATA_COUNT(S_DATA_COUNT),
            .M_DATA_COUNT(M_DATA_COUNT)
        ) r_r (
            .clk(clk),
            .rst_n(rst_n),

            .number(number),

            .s_data_i(s_data_i),
            .s_dest_i(s_dest_i),
            .s_last_i(s_last_i),
            .s_valid_i(s_valid_i),

            .m_ready_i(m_ready_i[i]),

            .m_valid_o(valid),
            .m_last_o(last),

            .m_data_o(m_data_o[i]),
            .m_id_o(m_id_o[i]),

            .s_ready_id(s_ready_id[i])
        );
    end
endgenerate

generate
    // создаём связь входа
    genvar j;
    for (j = 0; j < S_DATA_COUNT; ++j) begin : control
        logic dest;
        logic match;
        assign dest = s_dest_i[j];
        assign match = s_valid_i[j] && (s_ready_id[dest] == j) && m_ready_i[dest];
        assign s_ready_o[j] = match;
    end
endgenerate

endmodule
