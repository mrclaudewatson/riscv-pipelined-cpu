module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_control;

    logic [31:0] result;
    logic        zero;

    integer tests_passed = 0;
    integer tests_failed = 0;

    // ALU control values
    localparam logic [3:0]
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_AND  = 4'b0010,
        ALU_OR   = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SLL  = 4'b0101,
        ALU_SRL  = 4'b0110,
        ALU_SRA  = 4'b0111,
        ALU_SLT  = 4'b1000,
        ALU_SLTU = 4'b1001;


    // Instantiate the ALU
    alu dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );


    // Reusable test task
    task automatic check_result(
        input string test_name,
        input logic [31:0] input_a,
        input logic [31:0] input_b,
        input logic [3:0]  control,
        input logic [31:0] expected_result
    );

        begin
            a = input_a;
            b = input_b;
            alu_control = control;

            // Allow combinational logic to settle
            #1;

            if (result === expected_result) begin
                $display(
                    "PASSED: %-20s | A = %h | B = %h | Result = %h",
                    test_name,
                    a,
                    b,
                    result
                );

                tests_passed++;
            end
            else begin
                $display(
                    "FAILED: %-20s | A = %h | B = %h | Expected = %h | Got = %h",
                    test_name,
                    a,
                    b,
                    expected_result,
                    result
                );

                tests_failed++;
            end
        end

    endtask


    initial begin

        $display("==============================================");
        $display("             RV32I ALU TESTBENCH              ");
        $display("==============================================");


        // ------------------------------------------------
        // ADD
        // ------------------------------------------------

        check_result(
            "ADD",
            32'd10,
            32'd5,
            ALU_ADD,
            32'd15
        );

        check_result(
            "ADD zero",
            32'd0,
            32'd0,
            ALU_ADD,
            32'd0
        );


        // ------------------------------------------------
        // SUB
        // ------------------------------------------------

        check_result(
            "SUB",
            32'd10,
            32'd5,
            ALU_SUB,
            32'd5
        );

        check_result(
            "SUB negative",
            32'd5,
            32'd10,
            ALU_SUB,
            32'hFFFF_FFFB
        );


        // ------------------------------------------------
        // AND
        // ------------------------------------------------

        check_result(
            "AND",
            32'hFFFF_0000,
            32'h0F0F_0F0F,
            ALU_AND,
            32'h0F0F_0000
        );


        // ------------------------------------------------
        // OR
        // ------------------------------------------------

        check_result(
            "OR",
            32'hF000_0000,
            32'h0F00_0000,
            ALU_OR,
            32'hFF00_0000
        );


        // ------------------------------------------------
        // XOR
        // ------------------------------------------------

        check_result(
            "XOR",
            32'hFFFF_0000,
            32'h0F0F_0F0F,
            ALU_XOR,
            32'hF0F0_0F0F
        );


        // ------------------------------------------------
        // SLL
        // Shift Left Logical
        // ------------------------------------------------

        check_result(
            "SLL by 3",
            32'd1,
            32'd3,
            ALU_SLL,
            32'd8
        );

        check_result(
            "SLL by 31",
            32'd1,
            32'd31,
            ALU_SLL,
            32'h8000_0000
        );

        // This specifically tests b[4:0].
        // 35 decimal has lower 5 bits equal to 3.
        check_result(
            "SLL 35 -> shift 3",
            32'd1,
            32'd35,
            ALU_SLL,
            32'd8
        );


        // ------------------------------------------------
        // SRL
        // Shift Right Logical
        // ------------------------------------------------

        check_result(
            "SRL",
            32'h8000_0000,
            32'd1,
            ALU_SRL,
            32'h4000_0000
        );


        // ------------------------------------------------
        // SRA
        // Shift Right Arithmetic
        // ------------------------------------------------

        check_result(
            "SRA negative",
            32'hFFFF_FFF8,   // -8
            32'd1,
            ALU_SRA,
            32'hFFFF_FFFC    // -4
        );

        check_result(
            "SRA by 2",
            32'hFFFF_FFF8,   // -8
            32'd2,
            ALU_SRA,
            32'hFFFF_FFFE    // -2
        );


        // ------------------------------------------------
        // SLT
        // Signed comparison
        // ------------------------------------------------

        check_result(
            "SLT 5 < 10",
            32'd5,
            32'd10,
            ALU_SLT,
            32'd1
        );

        check_result(
            "SLT 10 < 5",
            32'd10,
            32'd5,
            ALU_SLT,
            32'd0
        );

        check_result(
            "SLT -1 < 5",
            32'hFFFF_FFFF,   // -1 signed
            32'd5,
            ALU_SLT,
            32'd1
        );


        // ------------------------------------------------
        // SLTU
        // Unsigned comparison
        // ------------------------------------------------

        check_result(
            "SLTU 5 < 10",
            32'd5,
            32'd10,
            ALU_SLTU,
            32'd1
        );

        check_result(
            "SLTU max < 5",
            32'hFFFF_FFFF,   // 4,294,967,295 unsigned
            32'd5,
            ALU_SLTU,
            32'd0
        );


        // ------------------------------------------------
        // ZERO FLAG TESTS
        // ------------------------------------------------

        a = 32'd5;
        b = 32'd5;
        alu_control = ALU_SUB;

        #1;

        if (zero === 1'b1) begin
            $display(
                "PASSED: ZERO flag when result = 0"
            );
            tests_passed++;
        end
        else begin
            $display(
                "FAILED: ZERO flag should be 1 when result = 0"
            );
            tests_failed++;
        end


        a = 32'd5;
        b = 32'd3;
        alu_control = ALU_SUB;

        #1;

        if (zero === 1'b0) begin
            $display(
                "PASSED: ZERO flag when result != 0"
            );
            tests_passed++;
        end
        else begin
            $display(
                "FAILED: ZERO flag should be 0 when result != 0"
            );
            tests_failed++;
        end


        // ------------------------------------------------
        // FINAL RESULTS
        // ------------------------------------------------

        $display("");
        $display("==============================================");
        $display("                TEST SUMMARY                  ");
        $display("==============================================");
        $display("Tests Passed : %0d", tests_passed);
        $display("Tests Failed : %0d", tests_failed);
        $display("Total Tests  : %0d", tests_passed + tests_failed);
        $display("==============================================");

        if (tests_failed == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("SOME ALU TESTS FAILED");

        $finish;

    end

endmodule

