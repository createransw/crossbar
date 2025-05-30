module round_robin_test();

logic clk;
logic rst_n;

logic [1 : 0] number;
logic m_ready;

logic [1 : 0] s_dest_i [1 : 0];
logic [1 : 0] s_valid_i;
logic s_last;
logic [1 : 0] s_ready_o;

always #5 begin
    clk <= ~clk;
end

round_robin uut (
    .clk(clk),
    .rst_n(rst_n),

    .number(number),
    .m_ready(m_ready),

    .s_dest_i(s_dest_i),
    .s_valid_i(s_valid_i),
    .s_last(s_last),
    .s_ready_o(s_ready_o)
);

initial begin
    clk = 0;
    rst_n = 0;
    #15;
    rst_n = 1;
    number = 0;
    m_ready = 1;
    s_dest_i[0] = 0;
    s_dest_i[1] = 0;
    s_valid_i = '0;
    s_last = 0;
    #10;
    s_valid_i[0] = 1;
    s_dest_i[0] = 0;
    #10;
    s_valid_i[1] = 1;
    s_dest_i[1] = 0;
    #10;
    s_last = 1;
    #10;
    s_last = 0;
    s_valid_i[0] = 0;
    #10;
    s_last = 1;
    #10;
    s_valid_i[1] = 0;
    s_last = 0;
    #20;
    s_valid_i[0] = 1;
    s_valid_i[1] = 1;
    #20;
    s_last = 1;
    #10;
    s_last = 0;
    s_valid_i[0] = 0;
    #10;
    s_last = 1;
    #10;
    s_last = 0;
    s_valid_i[1] = 0;
    #10;
    s_valid_i = '1;
    s_dest_i[0] = 1;
    s_dest_i[1] = 1;
    #50;
    

    $finish;
end
endmodule

