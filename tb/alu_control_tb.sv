module alu_control_tb;

    logic [2:0] aluOp;
    logic [2:0] func3;
    logic [6:0] func7;
    logic [3:0] alu_control;

    integer tests_run = 0;
    integer tests_failed = 0;

    localparam logic [2:0]
        ALU_OP_RTYPE  = 3'b000,
        ALU_OP_LUI    = 3'b001,
        ALU_OP_BRANCH = 3'b010,
        ALU_OP_JUMP   = 3'b011,
        ALU_OP_MEM    = 3'b100,
        ALU_OP_IMM    = 3'b101;

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

    alu_op dut (
        .aluOp(aluOp),
        .func3(func3),
        .func7(func7),
        .alu_op(alu_control)
    );

    task automatic check_control(
        input string test_name,
        input logic [2:0] test_alu_op,
        input logic [2:0] test_func3,
        input logic [6:0] test_func7,
        input logic [3:0] expected_control
    );
        begin
            aluOp = test_alu_op;
            func3 = test_func3;
            func7 = test_func7;
            #1;
            tests_run++;

            if (alu_control !== expected_control) begin
                tests_failed++;
                $display(
                    "FAILED: %-20s | aluOp=%03b func3=%03b func7=%07b expected=%04b got=%04b",
                    test_name,
                    aluOp,
                    func3,
                    func7,
                    expected_control,
                    alu_control
                );
            end
            else begin
                $display("PASSED: %s", test_name);
            end
        end
    endtask

    initial begin
        $display("==============================================");
        $display("          ALU CONTROL TESTBENCH               ");
        $display("==============================================");

        check_control("R-type ADD", ALU_OP_RTYPE, 3'b000, 7'b0000000, ALU_ADD);
        check_control("R-type SUB", ALU_OP_RTYPE, 3'b000, 7'b0100000, ALU_SUB);
        check_control("R-type AND", ALU_OP_RTYPE, 3'b111, 7'b0000000, ALU_AND);
        check_control("R-type OR", ALU_OP_RTYPE, 3'b110, 7'b0000000, ALU_OR);
        check_control("R-type XOR", ALU_OP_RTYPE, 3'b100, 7'b0000000, ALU_XOR);
        check_control("R-type SLL", ALU_OP_RTYPE, 3'b001, 7'b0000000, ALU_SLL);
        check_control("R-type SRL", ALU_OP_RTYPE, 3'b101, 7'b0000000, ALU_SRL);
        check_control("R-type SRA", ALU_OP_RTYPE, 3'b101, 7'b0100000, ALU_SRA);
        check_control("R-type SLT", ALU_OP_RTYPE, 3'b010, 7'b0000000, ALU_SLT);
        check_control("R-type SLTU", ALU_OP_RTYPE, 3'b011, 7'b0000000, ALU_SLTU);
        check_control("R-type SUB ignores other func7 bits", ALU_OP_RTYPE, 3'b000, 7'b1111111, ALU_SUB);

        check_control("Immediate ADD", ALU_OP_IMM, 3'b000, 7'b0100000, ALU_ADD);
        check_control("Immediate AND", ALU_OP_IMM, 3'b111, 7'b0000000, ALU_AND);
        check_control("Immediate OR", ALU_OP_IMM, 3'b110, 7'b0000000, ALU_OR);
        check_control("Immediate XOR", ALU_OP_IMM, 3'b100, 7'b0000000, ALU_XOR);
        check_control("Immediate SLL", ALU_OP_IMM, 3'b001, 7'b0000000, ALU_SLL);
        check_control("Immediate SRL", ALU_OP_IMM, 3'b101, 7'b0000000, ALU_SRL);
        check_control("Immediate SRA", ALU_OP_IMM, 3'b101, 7'b0100000, ALU_SRA);
        check_control("Immediate SLT", ALU_OP_IMM, 3'b010, 7'b0000000, ALU_SLT);
        check_control("Immediate SLTU", ALU_OP_IMM, 3'b011, 7'b0000000, ALU_SLTU);
        check_control("Immediate ADD ignores func7", ALU_OP_IMM, 3'b000, 7'b1111111, ALU_ADD);

        check_control("LUI always ADD", ALU_OP_LUI, 3'b111, 7'b1111111, ALU_ADD);
        check_control("Branch always SUB", ALU_OP_BRANCH, 3'b111, 7'b1111111, ALU_SUB);
        check_control("Jump always ADD", ALU_OP_JUMP, 3'b111, 7'b1111111, ALU_ADD);
        check_control("Memory always ADD", ALU_OP_MEM, 3'b111, 7'b1111111, ALU_ADD);
        check_control("AUIPC always ADD", 3'b110, 3'b111, 7'b1111111, ALU_ADD);
        check_control("Unknown op 111", 3'b111, 3'b111, 7'b1111111, ALU_ADD);

        $display("----------------------------------------------");
        $display("Tests run: %0d | Failed: %0d", tests_run, tests_failed);
        if (tests_failed != 0)
            $fatal(1, "ALU control testbench failed");
        $finish;
    end

endmodule