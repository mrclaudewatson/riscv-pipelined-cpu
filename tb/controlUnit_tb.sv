module controlUnit_tb;

    logic [6:0] opcode;

    logic       lui;
    logic [1:0] pcSrc;
    logic       branch;
    logic       jump;
    logic       memRead;
    logic       memWrite;
    logic       memToReg;
    logic       regWrite;
    logic [2:0] aluOp;
    logic [1:0] aluASel;
    logic       aluBSel;
    logic [2:0] imm_type;
    logic [2:0] func3;
    logic [6:0] func7;
    logic [3:0] decoded_alu_control;

    alu_op alu_decoder (
        .aluOp(aluOp),
        .func3(func3),
        .func7(func7),
        .alu_op(decoded_alu_control)
    );

    integer tests_run = 0;
    integer tests_passed = 0;
    integer tests_failed = 0;

    // Control bundle: {lui, pcSrc, branch, jump, memRead, memWrite,
    //                   memToReg, regWrite, aluOp, aluASel, aluBSel, imm_type}
    logic [17:0] actual_controls;

    controlUnit dut (
        .opcode(opcode),
        .lui(lui),
        .pcSrc(pcSrc),
        .branch(branch),
        .jump(jump),
        .memRead(memRead),
        .memWrite(memWrite),
        .memToReg(memToReg),
        .regWrite(regWrite),
        .aluOp(aluOp),
        .aluASel(aluASel),
        .aluBSel(aluBSel),
        .imm_type(imm_type)
    );

    assign actual_controls = {
        lui,
        pcSrc,
        branch,
        jump,
        memRead,
        memWrite,
        memToReg,
        regWrite,
        aluOp,
        aluASel,
        aluBSel,
        imm_type
    };

    task automatic check_decode(
        input string test_name,
        input logic [6:0] test_opcode,
        input logic [17:0] expected_controls
    );
        begin
            opcode = test_opcode;
            #1;
            tests_run++;

            if (actual_controls === expected_controls) begin
                tests_passed++;
                $display(
                    "PASSED: %-24s | opcode=%07b | controls=%018b",
                    test_name,
                    opcode,
                    actual_controls
                );
            end
            else begin
                tests_failed++;
                $display(
                    "FAILED: %-24s | opcode=%07b | expected=%018b | got=%018b",
                    test_name,
                    opcode,
                    expected_controls,
                    actual_controls
                );
            end
        end
    endtask

    initial begin
        $display("===============================================================");
        $display("                 RV32I CONTROL UNIT TESTBENCH                 ");
        $display("===============================================================");
        $display("Control order: lui pcSrc[1:0] branch jump memRead memWrite memToReg");
        $display("               regWrite aluOp aluASel aluBSel imm_type");
        $display("---------------------------------------------------------------");

        // R-type: register operands, ALU R-type operation.
        check_decode(
            "R-type",
            7'b0110011,
            18'b000000001_000_00_0_000
        );

        // OP-IMM: rs1 plus I-type immediate.
        check_decode(
            "OP-IMM",
            7'b0010011,
            18'b000000001_101_00_1_000
        );

        // Load: address is rs1 plus I-type immediate, then memory to register.
        check_decode(
            "Load",
            7'b0000011,
            18'b000001011_100_00_1_000
        );

        // Store: address is rs1 plus S-type immediate.
        check_decode(
            "Store",
            7'b0100011,
            18'b000000100_100_00_1_100
        );

        // Branch: compare rs1 and rs2, and use a B-type target immediate.
        check_decode(
            "Branch",
            7'b1100011,
            18'b000100000_010_00_0_010
        );

        // JAL: jump target uses PC plus J-type immediate.
        check_decode(
            "JAL",
            7'b1101111,
            18'b001010001_011_00_0_001
        );

        // JALR: jump target uses rs1 plus I-type immediate.
        check_decode(
            "JALR",
            7'b1100111,
            18'b010010001_011_00_1_000
        );

        // LUI: write a U-type immediate to the destination register.
        check_decode(
            "LUI",
            7'b0110111,
            18'b100000001_001_10_1_011
        );

        // AUIPC: calculate PC plus a U-type immediate.
        check_decode(
            "AUIPC",
            7'b0010111,
            18'b000000001_110_01_1_011
        );

        // AUIPC must add for every immediate pattern in these bit positions.
        for (int bits_value = 0; bits_value < 1024; bits_value++) begin
            {func7, func3} = 10'(bits_value);
            #1;
            if (decoded_alu_control !== 4'b0000)
                $fatal(1, "AUIPC must select ADD: func7=%07b func3=%03b", func7, func3);
        end
        $display("PASSED: AUIPC selects ADD for all 1024 func7/func3 patterns");

        // Unsupported/reserved opcodes must keep all controls inactive.
        check_decode(
            "Unsupported zero",
            7'b0000000,
            18'b000000000_000_00_0_000
        );

        check_decode(
            "FENCE unsupported",
            7'b0001111,
            18'b000000000_000_00_0_000
        );

        check_decode(
            "SYSTEM unsupported",
            7'b1110011,
            18'b000000000_000_00_0_000
        );

        $display("---------------------------------------------------------------");
        $display("SCOREBOARD: %0d tests run | %0d passed | %0d failed",
                 tests_run, tests_passed, tests_failed);

        if (tests_failed == 0) begin
            $display("RESULT: ALL CONTROL UNIT TESTS PASSED");
            $finish;
        end
        else begin
            $display("RESULT: CONTROL UNIT TESTS FAILED");
            $fatal(1, "Control unit scoreboard detected %0d failure(s)", tests_failed);
        end
    end

endmodule
