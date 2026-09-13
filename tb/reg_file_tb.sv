/*

this testbench will test the following:
1. register x0 is hardwired to 0
2. set 100 to x5
3. write 50 to x7
4. read two registers simultaneously
5. verify wr_flag = 0 prevents writing
6. attempt to write to x0
7. write max value (FFFFF)


*/


module reg_file_tb;

    logic clk;
    logic wr_flag;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [31:0] write_data;

    logic [31:0] read_data1;
    logic [31:0] read_data2;


    //instantiation
    reg_file dut(
        .clk(clk),
        .wr_flag(wr_flag),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );


    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // two tasks that check the register index + set test name
    task check_read1(
        input logic [31:0] expected, 
        input string test_name
    );
        #1;
        if (read_data1 == expected) begin 
            $display(" PASSED: %s ", test_name);
        end
        else begin
            $display(" FAILED: %s ", test_name);
        end
    endtask


    task check_read2(
        input logic [31:0] expected, 
        input string test_name
    );
        #1;
        if (read_data2 == expected) begin 
            $display(" PASSED: %s ", test_name);
        end
        else begin
            $display(" FAILED: %s ", test_name);
        end
    endtask


    initial begin
        // initial values
        wr_flag = 0;
        rd = 0;
        rs1 =0;
        rs2 = 0;

        // test 1: x0 to 0
        rs1 = 5'd0;
        check_read1(32'd0, "reg x0 to 0");


        // test 2: set 100 to x5
        rd = 5'd5;
        write_data = 32'd100;
        wr_flag = 1;

        @(posedge clk)
        #1;
        wr_flag = 0;
        rs1 = 5'd5;
        check_read1(100, "100 to x5");


        // test 3: 50 to x7
        rd = 5'd7;
        write_data = 32'd50;
        wr_flag = 1;

        @(posedge clk)
        #1; 
        wr_flag = 0;
        rs1 = 5'd7;
        check_read1(50, "50 to x7");


        // test 4: read two registers simultaneously
        rs1 = 5'd5;
        rs2 = 5'd7;

        check_read1(100,"dual read");
        check_read2(50, "dual read");


        // test 5: verify wr_flag = 0 prevents writing
        rd = 5'd3;
        write_data = 32'd67;
        wr_flag = 0;

        @(posedge clk)
        #1;
        wr_flag = 0;
        rs1 = 5'd3;
        check_read1(0, "no write when flag = 0");


        // test 6: attempt to write to x0
        rd = 5'd0;
        write_data = 32'd99;
        wr_flag = 1;

        @(posedge clk)
        #1;
        wr_flag = 0;
        rs1 = 5'd0;
        check_read1(32'd0, "x0 write attempt");

        // test 7: max value to register
        rd = 5'd2;
        write_data = 32'hFFFF_FFFF;
        wr_flag = 1;

        @(posedge clk)
        #1;
        wr_flag = 0;
        rs1 = 5'd2;
        check_read1( 32'hFFFF_FFFF, "max reg value");

    end 

endmodule
