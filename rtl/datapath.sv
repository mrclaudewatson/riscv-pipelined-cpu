

module datapath(

    // control signals
    input logic clk,
    input logic rst,

    // pc signals
    input logic [31:0] pc,

    // signals from control unit
    input logic wr_flag,
    input logic write_data,
    input logic [2:0] imm_type,
    input logic       lui,
    input logic       pcSrc,
    input logic       branch,
    input logic       jump,
    input logic       memRead,
    input logic       memWrite,
    input logic       memToReg,
    input logic       regWrite,

    // from alu control
    input logic [3:0] alu_op,


);

    // instruction memory signls 
    logic [31:0] instruction;

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
    logic [31:0] read_data_mem;


    // write back mux signals
    logic [31:0] pc_plus_4_out;
    logic [31:0] target_addr;
    logic [31:0] rs1_plus_immediate;
    logic [31:0] pc_next;















// instantiate modules

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
        .wr_flag(wr_flag),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );


    immediate_gen immediate_gen_inst (
        .instruc(instruction),
        .imm_type(imm_type),
        .extended_immed(immediate)

    );

    // mux 3
    mux3 alu_operan_A (
        .in1(read_data1), 
        .in2(pc),
        .in3(32'b0),
        .sel(alu_op[1:0]),
        .out(alu_operand_A)
    );  


    // mux 2
    mux2 alu_operan_B (
        .in1(read_data2),
        .in2(immediate),
        .sel(alu_op[2]),
        .out(alu_operand_B)
    );


    alu alu_inst (
        .operand_A(alu_operand_A),
        .operand_B(alu_operand_B),
        .alu_op(alu_op),
        .result(alu_result)
    );


    data_mem data_mem_inst (
        .clk(clk),
        .write_mem_flag(memWrite),
        .addr(alu_result),
        .write_data(read_data2),
        .read_data(read_data_mem)
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


    mux3 write_back_mux (
        .in1(pc_plus_4_out),
        .in2(target_addr),
        .in3(rs1_plus_immediate),
        .sel(pcSrc),
        .out(pc_next)
    );
























endmodule