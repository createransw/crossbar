module stream_xbar_test();

logic clk;
logic rst_n;

logic [3 : 0] s_data_i [1 : 0];
logic s_dest_i [1 : 0];
logic [1 : 0] s_last_i;
logic [1 : 0] s_valid_i;
logic [1 : 0] s_ready_o;

logic [3 : 0] m_data_o [1 : 0];
logic m_id_o [1 : 0];
logic [1 : 0] m_last_o;
logic [1 : 0] m_valid_o;
logic [1 : 0] m_ready_i;

always #5
    clk <= ~clk;

stream_xbar #(
    .T_DATA_WIDTH(4),
    .S_DATA_COUNT(2),
    .M_DATA_COUNT(2)
) uud (
    .clk(clk),
    .rst_n(rst_n),

    .s_data_i(s_data_i),
    .s_dest_i(s_dest_i),
    .s_last_i(s_last_i),
    .s_valid_i(s_valid_i),
    .s_ready_o(s_ready_o),

    .m_data_o(m_data_o),
    .m_id_o(m_id_o),
    .m_last_o(m_last_o),
    .m_valid_o(m_valid_o),
    .m_ready_i(m_ready_i)
);

initial begin
    clk = 1;
    rst_n = 0;
    #10;
    rst_n = 1;
    m_ready_i = '1;
    #10;
    s_valid_i[0] = 1;
    s_last_i[0] = 0;
    s_dest_i[0] = 0;
    s_data_i[0] = 4'hA;

    s_valid_i[1] = 1;
    s_last_i[1] = 0;
    s_dest_i[1] = 0;
    s_data_i[1] = 4'hC;

    #10;
    s_last_i[0] = 1;
    s_data_i[0] = 4'hB;
    #10;
    s_valid_i[0] = 0;
    #10;

    s_last_i[1] = 0;
    s_dest_i[1] = 0;
    s_last_i[1] = 1;
    s_data_i[1] = 4'hD;
    #10;
    s_valid_i[0] = 1;
    s_last_i[0] = 0;
    s_dest_i[0] = 1;
    s_data_i[0] = 4'hE;

    s_last_i[1] = 0;
    s_data_i[1] = 8;
    #10;
    s_data_i[0] = 4'hF;
    s_last_i[0] = 1;

    s_last_i[1] = 1;
    s_data_i[1] = 9;
    #10;
    s_valid_i = '0;
    #50;
   
    $finish;
end

endmodule

