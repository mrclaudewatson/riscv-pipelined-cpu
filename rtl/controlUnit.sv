module controlUnit (
    input  logic [6:0] opcode,

    //control signals
    output logic       lui,
    output logic       pcSrc,
    output logic       branch,
    output logic       jump,
    output logic       memRead,
    output logic       memWrite,
    output logic       memToReg,
    output logic       regWrite,

    // to alucontrol
    output logic [2:0] aluOp,

    // to muxes
    output logic [1:0] aluASel, // 00: rs1, 01: PC, 10: zero
    output logic       aluBSel, // 0: rs2, 1: immediate

    // to imm_gen
    output logic [2:0] imm_type
);


    localparam logic [2:0]
        ALU_OP_RTYPE  = 3'b000,
        ALU_OP_LUI    = 3'b001,
        ALU_OP_BRANCH = 3'b010,
        ALU_OP_JUMP   = 3'b011,
        ALU_OP_MEM    = 3'b100,
        ALU_OP_IMM    = 3'b101,
        ALU_OP_AUIPC  = 3'b110;

    localparam logic [2:0]
        IMM_I = 3'b000,
        IMM_J = 3'b001,
        IMM_B = 3'b010,
        IMM_U = 3'b011,
        IMM_S = 3'b100;

    always_comb begin
        // Safe defaults for unsupported opcodes
        lui      = 1'b0;
        pcSrc    = 1'b0;
        branch   = 1'b0;
        jump     = 1'b0;
        memRead  = 1'b0;
        memWrite = 1'b0;
        memToReg = 1'b0;
        regWrite = 1'b0;
        aluOp    = ALU_OP_RTYPE;
        aluASel  = 2'b00;
        aluBSel  = 1'b0;
        imm_type = IMM_I;

        case (opcode)
            // R-type
            7'b0110011: begin
                regWrite = 1'b1;
                aluOp    = ALU_OP_RTYPE;
            end

            // Immediate arithmetic
            7'b0010011: begin
                regWrite = 1'b1;
                aluOp    = ALU_OP_IMM;
                aluBSel  = 1'b1;
                imm_type = IMM_I;
            end

            // Load
            7'b0000011: begin
                memRead  = 1'b1;
                memToReg = 1'b1;
                regWrite = 1'b1;
                aluOp    = ALU_OP_MEM;
                aluBSel  = 1'b1;
                imm_type = IMM_I;
            end

            // Store
            7'b0100011: begin
                memWrite = 1'b1;
                aluOp    = ALU_OP_MEM;
                aluBSel  = 1'b1;
                imm_type = IMM_S;
            end

            // Branch
            7'b1100011: begin
                branch = 1'b1;
                aluOp  = ALU_OP_BRANCH;
                imm_type = IMM_B;
            end

            // JAL
            7'b1101111: begin
                jump     = 1'b1;
                pcSrc    = 1'b0;
                regWrite = 1'b1;
                aluOp    = ALU_OP_JUMP;
                imm_type = IMM_J;
            end

            // JALR
            7'b1100111: begin
                jump     = 1'b1;
                pcSrc    = 1'b1;
                regWrite = 1'b1;
                aluOp    = ALU_OP_JUMP;
                aluBSel  = 1'b1;
                imm_type = IMM_I;
            end

            // LUI
            7'b0110111: begin
                lui      = 1'b1;
                regWrite = 1'b1;
                aluOp    = ALU_OP_LUI;
                aluASel  = 2'b10;
                aluBSel  = 1'b1;
                imm_type = IMM_U;
            end

            // AUIPC: PC + immediate
            7'b0010111: begin
                regWrite = 1'b1;
                aluOp    = ALU_OP_AUIPC;
                aluASel  = 2'b01;
                aluBSel  = 1'b1;
                imm_type = IMM_U;
            end

            default: begin
                // Keep the defaults
            end
        endcase
    end
endmodule
