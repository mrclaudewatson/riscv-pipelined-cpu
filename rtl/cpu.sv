module cpu (
    input logic clk,
    input logic rst,


    output logic [31:0] pc
);

    logic [31:0] instruction;

    logic branch;
    logic jump;

    logic [1:0] pcSrc;

    logic memWrite;
    logic memToReg;
    logic regWrite;

    // connect to alu control
    logic [2:0] aluOp;

    logic [1:0] aluASel; 
    logic aluBSel;

    // to imm_gen
    logic [2:0] imm_type;

    logic [3:0] alu_op;



    controlUnit control_unit(
        .opcode(instruction[6:0]), 
        .lui(),
        .branch(branch),
        .jump(jump), 
        .pcSrc(pcSrc),
        .memRead(),
        .memWrite(memWrite),
        .memToReg(memToReg),
        .regWrite(regWrite),
        .aluOp(aluOp),
        .aluASel(aluASel),
        .aluBSel(aluBSel),
        .imm_type(imm_type)
    );

    alu_op alu_control(
        .aluOp(aluOp),
        .func3(instruction[14:12]),
        .func7(instruction[31:25]),
        .alu_op(alu_op)
    );

    datapath datapath1(
        .clk(clk),
        .rst(rst),
        .writeReg(regWrite),
        .imm_type(imm_type), 
        .pcSrc(pcSrc), 
        .branch(branch), 
        .jump(jump), 
        .memWrite(memWrite), 
        .memToReg(memToReg), 
        .aluASel(aluASel), 
        .aluBSel(aluBSel), 
        .alu_op(alu_op), 
        .pc(pc), 
        .instruction(instruction)
    );







endmodule
