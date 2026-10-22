module cpu_tb;
    logic clk = 1'b0;
    logic rst = 1'b1;
    logic [31:0] pc_value;
    logic [31:0] instruction;
    integer pc_checks = 0;

    cpu dut (
        .clk(clk),
        .rst(rst),
        .pc(pc_value),
        .instruction(instruction)
    );

    always #5 clk = ~clk;

    // Encode instructions so branch offsets and register fields stay readable.
    function automatic logic [31:0] encode_i(
        input logic [4:0] rd,
        input logic [4:0] rs1,
        input logic [31:0] immediate,
        input logic [2:0] funct3 = 3'b000,
        input logic [6:0] opcode = 7'b0010011
    );
        return {immediate[11:0], rs1, funct3, rd, opcode};
    endfunction

    function automatic logic [31:0] encode_r(
        input logic [4:0] rd,
        input logic [4:0] rs1,
        input logic [4:0] rs2,
        input logic [6:0] funct7 = 7'b0000000
    );
        return {funct7, rs2, rs1, 3'b000, rd, 7'b0110011};
    endfunction

    function automatic logic [31:0] encode_s(
        input logic [4:0] rs1,
        input logic [4:0] rs2,
        input logic [31:0] immediate
    );
        return {immediate[11:5], rs2, rs1, 3'b010, immediate[4:0], 7'b0100011};
    endfunction

    function automatic logic [31:0] encode_b(
        input logic [2:0] funct3,
        input logic [4:0] rs1,
        input logic [4:0] rs2,
        input logic [31:0] offset
    );
        return {offset[12], offset[10:5], rs2, rs1, funct3,
                offset[4:1], offset[11], 7'b1100011};
    endfunction

    function automatic logic [31:0] encode_j(
        input logic [4:0] rd,
        input logic [31:0] offset
    );
        return {offset[20], offset[10:1], offset[11], offset[19:12], rd, 7'b1101111};
    endfunction

    task automatic step(input logic [31:0] expected_pc);
        @(posedge clk);
        #1;
        if (pc_value !== expected_pc)
            $fatal(1, "PC check %0d: expected %0d, got %0d", pc_checks, expected_pc, pc_value);
        pc_checks++;
    endtask

    task automatic check_reg(input int index, input logic [31:0] expected);
        if (dut.datapath_inst.reg_file_inst.registers[index] !== expected)
            $fatal(1, "x%0d: expected %h, got %h", index, expected,
                   dut.datapath_inst.reg_file_inst.registers[index]);
    endtask

    initial begin
        // Simulation initialization belongs in the testbench, not the CPU RTL.
        for (int index = 0; index < 256; index++) begin
            dut.datapath_inst.instruc_mem_inst.mem[index] = 32'h00000013;
            dut.datapath_inst.data_mem_inst.mem[index] = 32'd0;
        end
        for (int index = 0; index < 32; index++)
            dut.datapath_inst.reg_file_inst.registers[index] = 32'd0;

        // Program addresses are four times the memory index.
        dut.datapath_inst.instruc_mem_inst.mem[0] = encode_i(1, 0, 5);
        dut.datapath_inst.instruc_mem_inst.mem[1] = encode_i(2, 0, 7);
        dut.datapath_inst.instruc_mem_inst.mem[2] = encode_r(3, 1, 2);
        dut.datapath_inst.instruc_mem_inst.mem[3] = encode_r(4, 2, 1, 7'b0100000);
        dut.datapath_inst.instruc_mem_inst.mem[4] = encode_s(0, 3, 0);
        dut.datapath_inst.instruc_mem_inst.mem[5] = encode_i(5, 0, 0, 3'b010, 7'b0000011);
        dut.datapath_inst.instruc_mem_inst.mem[6] = encode_i(0, 0, 99); // x0 ignores writes.
        dut.datapath_inst.instruc_mem_inst.mem[7] = 32'h12345337; // LUI x6, 0x12345
        dut.datapath_inst.instruc_mem_inst.mem[8] = 32'h00001397; // AUIPC x7, 1
        dut.datapath_inst.instruc_mem_inst.mem[9] = encode_b(3'b000, 3, 5, 8);
        dut.datapath_inst.instruc_mem_inst.mem[10] = encode_i(8, 0, 99); // skipped
        dut.datapath_inst.instruc_mem_inst.mem[11] = encode_i(8, 0, 1);
        dut.datapath_inst.instruc_mem_inst.mem[12] = encode_b(3'b001, 1, 2, 8);
        dut.datapath_inst.instruc_mem_inst.mem[13] = encode_i(8, 0, 99); // skipped
        dut.datapath_inst.instruc_mem_inst.mem[14] = encode_i(9, 0, -1);
        dut.datapath_inst.instruc_mem_inst.mem[15] = encode_b(3'b100, 9, 1, 8);
        dut.datapath_inst.instruc_mem_inst.mem[16] = encode_i(8, 0, 99); // skipped
        dut.datapath_inst.instruc_mem_inst.mem[17] = encode_b(3'b101, 2, 1, 8);
        dut.datapath_inst.instruc_mem_inst.mem[18] = encode_i(8, 0, 99); // skipped
        dut.datapath_inst.instruc_mem_inst.mem[19] = encode_b(3'b110, 1, 9, 8);
        dut.datapath_inst.instruc_mem_inst.mem[20] = encode_i(8, 0, 99); // skipped
        dut.datapath_inst.instruc_mem_inst.mem[21] = encode_b(3'b111, 9, 1, 8);
        dut.datapath_inst.instruc_mem_inst.mem[22] = encode_i(8, 0, 99); // skipped

        // Exercise the untaken outcome of all six branch conditions too.
        dut.datapath_inst.instruc_mem_inst.mem[23] = encode_b(3'b000, 1, 2, 8);
        dut.datapath_inst.instruc_mem_inst.mem[24] = encode_b(3'b001, 3, 5, 8);
        dut.datapath_inst.instruc_mem_inst.mem[25] = encode_b(3'b100, 2, 1, 8);
        dut.datapath_inst.instruc_mem_inst.mem[26] = encode_b(3'b101, 1, 2, 8);
        dut.datapath_inst.instruc_mem_inst.mem[27] = encode_b(3'b110, 9, 1, 8);
        dut.datapath_inst.instruc_mem_inst.mem[28] = encode_b(3'b111, 1, 9, 8);
        dut.datapath_inst.instruc_mem_inst.mem[29] = encode_j(10, 8);
        dut.datapath_inst.instruc_mem_inst.mem[30] = encode_i(8, 0, 99); // skipped
        dut.datapath_inst.instruc_mem_inst.mem[31] = encode_i(11, 0, 137);
        dut.datapath_inst.instruc_mem_inst.mem[32] = encode_i(12, 11, 0, 3'b000, 7'b1100111);
        dut.datapath_inst.instruc_mem_inst.mem[33] = encode_i(8, 0, 99); // skipped
        dut.datapath_inst.instruc_mem_inst.mem[34] = encode_i(13, 0, 42);
        dut.datapath_inst.instruc_mem_inst.mem[35] = encode_s(0, 13, 4);
        dut.datapath_inst.instruc_mem_inst.mem[36] = encode_i(14, 0, 4, 3'b010, 7'b0000011);
        dut.datapath_inst.instruc_mem_inst.mem[37] = encode_i(16, 0, 8);
        dut.datapath_inst.instruc_mem_inst.mem[38] = encode_i(17, 16, -4, 3'b010, 7'b0000011);
        dut.datapath_inst.instruc_mem_inst.mem[39] = encode_j(0, 0);

        // Neither stores nor register writes may commit while reset is high.
        dut.datapath_inst.data_mem_inst.mem[0] = 32'hdeadbeef;
        dut.datapath_inst.instruc_mem_inst.mem[0] = encode_s(0, 0, 0);
        @(posedge clk);
        #1;
        if (dut.datapath_inst.data_mem_inst.mem[0] !== 32'hdeadbeef)
            $fatal(1, "Store committed during reset");
        @(negedge clk);
        dut.datapath_inst.instruc_mem_inst.mem[0] = encode_i(1, 0, 5);
        @(posedge clk);
        #1;
        check_reg(1, 0);
        @(negedge clk);
        rst = 1'b0;

        step(4); step(8); step(12); step(16); step(20); step(24);
        step(28); step(32); step(36); step(44); step(48); step(56);
        step(60); step(68); step(76); step(84); step(92); step(96);
        step(100); step(104); step(108); step(112); step(116); step(124);
        step(128); step(136); step(140); step(144); step(148);
        step(152); step(156); step(156);

        check_reg(1, 5); check_reg(2, 7); check_reg(3, 12); check_reg(4, 2);
        check_reg(5, 12); check_reg(6, 32'h12345000); check_reg(7, 32'h00001020);
        check_reg(8, 1); check_reg(9, 32'hffffffff); check_reg(10, 120);
        check_reg(11, 137); check_reg(12, 132); check_reg(13, 42); check_reg(14, 42);
        check_reg(16, 8); check_reg(17, 42);
        if (dut.datapath_inst.data_mem_inst.mem[0] !== 32'd12 ||
            dut.datapath_inst.data_mem_inst.mem[1] !== 32'd42)
            $fatal(1, "Word load/store program produced incorrect memory contents");
        if (dut.datapath_inst.reg_file_inst.read_data1 !== 32'd0)
            $fatal(1, "x0 must read as zero");

        // A short loop checks negative branch displacements and reset restart.
        @(negedge clk);
        rst = 1'b1;
        dut.datapath_inst.instruc_mem_inst.mem[0] = encode_i(20, 0, 3);
        dut.datapath_inst.instruc_mem_inst.mem[1] = encode_i(21, 0, 0);
        dut.datapath_inst.instruc_mem_inst.mem[2] = encode_r(21, 21, 20);
        dut.datapath_inst.instruc_mem_inst.mem[3] = encode_i(20, 20, -1);
        dut.datapath_inst.instruc_mem_inst.mem[4] = encode_b(3'b001, 20, 0, -8);
        dut.datapath_inst.instruc_mem_inst.mem[5] = encode_j(0, 0);
        @(negedge clk);
        rst = 1'b0;
        step(4); step(8); step(12); step(16); step(8);
        step(12); step(16); step(8); step(12); step(16); step(20); step(20);
        check_reg(20, 0);
        check_reg(21, 6);

        @(negedge clk);
        dut.datapath_inst.instruc_mem_inst.mem[5] = encode_j(22, -12);
        step(8);
        check_reg(22, 24);

        $display("CPU integration tests passed: %0d PC checks, register/memory checks, reset, branches and jumps.", pc_checks);
        $finish;
    end

    initial begin
        #2000;
        $fatal(1, "CPU test timed out");
    end
endmodule
