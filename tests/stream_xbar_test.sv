module stream_xbar_test();

logic clk;
logic rst_n;

logic [3 : 0] s_data_i [1 : 0];
logic s_dest_i [1 : 0];
logic [1 : 0] s_last_i;
logic [1 : 0] s_valid_i;
logic [1 : 0] s_ready_o;
logic [1 : 0] s_ready_o_d;

logic [3 : 0] m_data_o [1 : 0];
logic [3 : 0] m_data_o_d [1 : 0];
logic m_id_o [1 : 0];
logic m_id_o_d [1 : 0];
logic [1 : 0] m_last_o;
logic [1 : 0] m_last_o_d;
logic [1 : 0] m_valid_o;
logic [1 : 0] m_valid_o_d;
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
    int fd = $fopen("./tests/vectors.txt", "r");
    if (fd == 0) $fatal(1, "File not found");

    clk = 1;
    rst_n = 0;
    #10;
    rst_n = 1;
    m_ready_i = '1;
   
    for (int i = 0; i < 7; ++i) begin
        $fscanf(
            fd,
            "%x %x %x %x %b %b %b    %b %x %x %x %x %b %b",
            s_data_i[1],
            s_data_i[0],
            s_dest_i[1],
            s_dest_i[0],
            s_last_i,
            s_valid_i,
            m_ready_i,

            s_ready_o_d,
            m_data_o_d[1],
            m_data_o_d[0],
            m_id_o_d[1],
            m_id_o_d[0],
            m_last_o_d,
            m_valid_o_d
        );
        #10;

        if (m_valid_o_d != m_valid_o)
            $error("Mismatch in m_valid_o");

        if (m_valid_o[0]) begin
            if (m_data_o_d[0] != m_data_o[0])
                $error("Mismatch in m_data_o[0]");
            if (m_id_o_d[0] != m_id_o[0])
                $error("Mismatch in m_id_o[0]");
            if (m_last_o_d[0] != m_last_o[0])
                $error("Mismatch in m_last_o[0]");
        end
        if (m_valid_o[1]) begin
            if (m_data_o_d[1] != m_data_o[1])
                $error("Mismatch in m_data_o[1]");
            if (m_id_o_d[1] != m_id_o[1])
                $error("Mismatch in m_id_o[1]");
            if (m_last_o_d[1] != m_last_o[1])
                $error("Mismatch in m_last_o[1]");
        end

        if (s_valid_i[0]) begin
            if (s_ready_o_d[0] != s_ready_o[0])
                $error("Mismatch in s_ready_o[0]");
        end
        if (s_valid_i[1]) begin
            if (s_ready_o_d[1] != s_ready_o[1])
                $error("Mismatch in s_ready_o[1]");
        end
    end

    $fclose(fd);
    $finish;
end

endmodule

