//*********************************************************************************************
// Module and port declaration
//*********************************************************************************************
module datapath(

    // control signals
    input logic clk,
    input logic rst,

    // signals from control unit
    input logic writeReg,
    input logic [2:0] imm_type,
    input logic [1:0] pcSrc,
    input logic branch,
    input logic jump,
    input logic memWrite,
    input logic memToReg,
    input logic [1:0] aluASel, // 00: rs1, 01: PC, 10: zero
    input logic aluBSel, // 0: rs2, 1: immediate

    // from alu control
    input logic [3:0] alu_op,

    // pc signals
    output logic [31:0] pc,
    output logic [31:0] instruction

);


//*********************************************************************************************
// WIRES
//*********************************************************************************************
    // instruction memory signls 

    // register file signals
    logic [31:0] read_data1;
    logic [31:0] read_data2;

    // immediate generator signals 
    logic [31:0] immediate;

    // alu signals
    logic [31:0] alu_operand_A;
    logic [31:0] alu_operand_B;
    logic [31:0] alu_result;

    // data memory signals
    logic [31:0] mem_data;


    // write back mux signals
    logic [31:0] pc_plus_4_out;
    logic [31:0] target_addr;
    logic [31:0] rs1_plus_immediate;
    logic [31:0] pc_next;

    logic [31:0] reg_write_data;

    logic branch_taken;
    logic [1:0] write_back_sel;
    logic [1:0] pc_next_sel;
    logic take_branch;



//*********************************************************************************************
// instantiate modules
//*********************************************************************************************

    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    instruc_mem instruc_mem_inst (
        .pc(pc), 
        .instruction(instruction)
    );

    reg_file reg_file_inst (
        .clk(clk), 
        .writeReg(writeReg && !rst),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .write_data(reg_write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    immediate_gen immediate_gen_inst (
        .instruc(instruction),
        .imm_type(imm_type),
        .extended_immed(immediate)
    );

    // mux 3 for alu operand A
    mux3 alu_operan_A (
        .in1(read_data1), 
        .in2(pc),
        .in3(32'b0),
        .sel(aluASel),
        .out(alu_operand_A)
    );  

    // mux 2 for alu operand B
    mux2 alu_operan_B (
        .in1(read_data2),
        .in2(immediate),
        .sel(aluBSel),
        .out(alu_operand_B)
    );


    alu alu_inst (
        .a(alu_operand_A),
        .b(alu_operand_B),
        .alu_op(alu_op),
        .result(alu_result),
        .zero()
    );

    data_mem data_mem_inst (
        .clk(clk),
        .write_mem_flag(memWrite && !rst),
        .addr(alu_result),
        .write_data(read_data2),
        .mem_out_data(mem_data)
    );

    adder pc_plus4 (
        .a(pc),
        .b(32'd4),
        .sum(pc_plus_4_out)
    );

    adder branch_target (
        .a(pc),
        .b(immediate),
        .sum(target_addr)
    );

    adder jalr_target (
        .a(read_data1),
        .b(immediate),
        .sum(rs1_plus_immediate)
    );

    mux3 pc_next_mux (
        .in1(pc_plus_4_out),
        .in2(target_addr),
        .in3({rs1_plus_immediate[31:1], 1'b0}),
        .sel(pc_next_sel),
        .out(pc_next)
    );

    mux3 write_back_mux(
            .in1(alu_result),
            .in2(mem_data),
            .in3(pc_plus_4_out),
            .sel(write_back_sel),
            .out(reg_write_data)
        );

    branch_decision branch_decision1(
        .rs1_data(read_data1),
        .rs2_data(read_data2),
        .funct3(instruction[14:12]),
        .branch_taken(branch_taken)
    );



//*********************************************************************************************
// code
//*********************************************************************************************


    assign take_branch = branch && branch_taken;

    always_comb begin

        if (jump)
            write_back_sel = 2'b10; // write back jal and jalr
        else if (memToReg)
            write_back_sel = 2'b01; // load value
        else
            write_back_sel = 2'b00; // alu result


        if (take_branch)
            pc_next_sel = 2'b01; // branch target
        else
            pc_next_sel = pcSrc;  // sequential, JAL, or JALR



    end





endmodule
