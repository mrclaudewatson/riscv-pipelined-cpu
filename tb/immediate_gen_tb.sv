module immediate_gen_tb;

    logic [31:0] instruc;
    logic [2:0]  imm_type;
    logic [31:0] extended_immed;

    localparam logic [2:0]
        IMM_I = 3'b000,
        IMM_J = 3'b001,
        IMM_B = 3'b010,
        IMM_U = 3'b011,
        IMM_S = 3'b100;

    immediate_gen dut (
        .instruc(instruc),
        .imm_type(imm_type),
        .extended_immed(extended_immed)
    );

    task check_result(
        input logic [31:0] expected,
        input string test_name
    );
        begin
            #1;

            if (extended_immed === expected)
                $display("PASS: %s | output = %h", test_name, extended_immed);
            else
                $display("FAIL: %s | expected = %h, got = %h",
                         test_name, expected, extended_immed);
        end
    endtask

    initial begin

        // I-type: immediate = 10
        instruc = 32'b000000001010_00000_000_00000_0010011;
        imm_type = IMM_I;
        check_result(32'd10, "I-type positive");

        // I-type: immediate = -1
        instruc = 32'b111111111111_00000_000_00000_0010011;
        imm_type = IMM_I;
        check_result(32'hFFFFFFFF, "I-type negative");

        // S-type: immediate = 20
        instruc = 32'b0000000_00000_00000_010_10100_0100011;
        imm_type = IMM_S;
        check_result(32'd20, "S-type positive");

        // B-type: immediate = 8
        instruc = 32'b0000000_00000_00000_000_0100_0_1100011;
        imm_type = IMM_B;
        check_result(32'd8, "B-type positive");

        // U-type
        instruc = 32'h12345037;
        imm_type = IMM_U;
        check_result(32'h12345000, "U-type");

        // J-type: immediate = 8
        instruc = 32'b00000000100000000000_00000_1101111;
        imm_type = IMM_J;
        check_result(32'd8, "J-type positive");

        // Invalid imm_type
        instruc = 32'b0;
        imm_type = 3'b111;
        check_result(32'b0, "Default case");

        $display("Immediate generator testing complete.");
        $finish;

    end

endmodule
