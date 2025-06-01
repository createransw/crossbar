module round_robin_test();

logic clk;
logic rst_n;

logic [1 : 0] number;
logic m_ready_i;

logic [1 : 0] s_dest_i [1 : 0];
logic [1 : 0] s_valid_i;
logic [1 : 0] s_last_i;
logic s_ready_id;

logic m_valid_o;
logic m_last_o;

always #5 begin
    clk <= ~clk;
end

round_robin uut (
    .clk(clk),
    .rst_n(rst_n),

    .number(number),

    .s_dest_i(s_dest_i),
    .s_valid_i(s_valid_i),
    .s_last_i(s_last_i),

    .m_ready_i(m_ready_i),

    .m_valid_o(m_valid_o),
    .m_last_o(m_last_o),
    .s_ready_id(s_ready_id)
);

initial begin
    clk = 1;
    rst_n = 0;
    #10;
    rst_n = 1;
    number = 0;
    m_ready_i = 1;
    s_dest_i[0] = 0;
    s_dest_i[1] = 0;
    s_valid_i = '0;
    s_last_i = '0;
    #10;
    s_valid_i[0] = 1;
    s_dest_i[0] = 0;
    #10;
    s_valid_i[1] = 1;
    s_dest_i[1] = 0;
    #10;
    s_last_i[0] = 1;
    #10;
    s_valid_i[0] = 0;
    #10;
    s_last_i[1] = 1;
    #10;
    s_valid_i[1] = 0;
    s_last_i = '0;
    #20;
    s_valid_i[0] = 1;
    s_valid_i[1] = 1;
    #20;
    s_last_i[0] = 1;
    #10;
    s_last_i[0] = 0;
    s_valid_i[0] = 0;
    #10;
    s_last_i[1] = 1;
    #10;
    s_last_i[1] = 0;
    s_valid_i[1] = 0;
    #10;
    s_valid_i = '1;
    s_dest_i[0] = 1;
    s_dest_i[1] = 1;
    #50;
    

    $finish;
end
endmodule

