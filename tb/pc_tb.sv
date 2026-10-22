module pc_tb;

    logic clk;
    logic rst;
    logic [31:0] pc_next;
    logic [31:0] pc_value;

    pc dut (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc_value)
    );

    always #5 clk = ~clk;

    task check_result(
        input logic [31:0] expected,
        input string test_name
    );
        begin
            if (pc_value === expected)
                $display("PASS: %s | pc = %h", test_name, pc_value);
            else begin
                $error("FAIL: %s | expected = %h, got = %h",
                       test_name, expected, pc_value);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        pc_next = 32'b0;

        rst = 1'b1;
        #1;
        check_result(32'b0, "asynchronous reset");

        @(negedge clk);
        pc_next = 32'h12345678;
        rst = 1'b0;
        #1;
        check_result(32'b0, "reset deassertion does not update PC");

        @(posedge clk);
        #1;
        check_result(32'h12345678, "capture next PC on rising edge");

        pc_next = 32'h87654321;
        #1;
        check_result(32'h12345678, "hold value between rising edges");

        @(posedge clk);
        #1;
        check_result(32'h87654321, "capture next PC on rising edge");

        rst = 1'b1;
        #1;
        check_result(32'b0, "asynchronous reset between edges");

        $display("PC testing complete.");
        $finish;
    end

endmodule