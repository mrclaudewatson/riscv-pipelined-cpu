

module alu_op (
    input logic [2:0] aluOp,
    input logic [2:0] func3,
    input logic [6:0] func7,

    output logic [3:0] alu_op

    );

    // outputs to alu module
    localparam logic [3:0]
        ALU_ADD = 4'b0000,
        ALU_SUB = 4'b0001,
        ALU_AND = 4'b0010,
        ALU_OR  = 4'b0011,
        ALU_XOR = 4'b0100,
        ALU_SLL = 4'b0101,
        ALU_SRL = 4'b0110,
        ALU_SRA = 4'b0111,
        ALU_SLT = 4'b1000,
        ALU_SLTU = 4'b1001;

    // alu op from main decoder
    localparam logic [2:0]
        ALU_OP_RTYPE  = 3'b000,
        ALU_OP_LUI    = 3'b001,
        ALU_OP_BRANCH = 3'b010,
        ALU_OP_JUMP   = 3'b011,
        ALU_OP_MEM    = 3'b100,
        ALU_OP_IMM    = 3'b101,
        ALU_OP_AUIPC  = 3'b110;

    always_comb begin

        case(aluOp)
            ALU_OP_RTYPE: begin

                case(func3)
                    // add or sub 
                    3'b000: begin
                        if(func7[5] == 1'b0) begin
                            alu_op = ALU_ADD;
                        end 
                        else begin
                            alu_op = ALU_SUB;
                        end
                    end
                    //and 
                    3'b111: begin 
                        alu_op = ALU_AND;
                    end
                    // or
                    3'b110: begin
                        alu_op = ALU_OR;
                    end
                    // xor
                    3'b100: begin
                        alu_op = ALU_XOR;
                    end
                    // shift left logical
                    3'b001: begin
                        alu_op = ALU_SLL;
                    end
                    // shfit right logic and arithmetic
                    3'b101: begin
                        if (func7[5] == 1'b0) begin
                            alu_op = ALU_SRL;
                        end 
                        else begin
                            alu_op = ALU_SRA;
                        end
                    end
                    // set less than
                    3'b010: begin
                        alu_op = ALU_SLT;
                    end
                    // set less than unsigned
                    3'b011: begin
                        alu_op = ALU_SLTU;
                    end

                    default: begin
                        alu_op = ALU_ADD;
                    end
                endcase
            end


            ALU_OP_AUIPC: begin
                alu_op = ALU_ADD;
            end

            ALU_OP_LUI: begin
                alu_op = ALU_ADD;
            end 

            ALU_OP_BRANCH: begin
                alu_op = ALU_SUB;
            end

            ALU_OP_JUMP: begin
                alu_op = ALU_ADD;
            end

            ALU_OP_MEM: begin
                alu_op = ALU_ADD;
            end

            ALU_OP_IMM: begin
                case(func3)
                    // addi
                    3'b000: begin
                        alu_op = ALU_ADD;
                    end
                    // andi
                    3'b111: begin
                        alu_op = ALU_AND;
                    end
                    // ori
                    3'b110: begin
                        alu_op = ALU_OR;
                    end
                    // xori
                    3'b100: begin
                        alu_op = ALU_XOR;
                    end
                    // slli
                    3'b001: begin
                        alu_op = ALU_SLL;
                    end
                    // srli and srai
                    3'b101: begin
                        if (func7[5] == 1'b0) begin
                            alu_op = ALU_SRL;
                        end 
                        else begin
                            alu_op = ALU_SRA;
                        end
                    end
                    // slti
                    3'b010: begin
                        alu_op = ALU_SLT;
                    end
                    // sltiu
                    3'b011: begin
                        alu_op = ALU_SLTU;
                    end

                    default: begin
                        alu_op = ALU_ADD;
                    end
                endcase
            end


            default: begin
                alu_op = ALU_ADD;
            end

        endcase

    end
    endmodule

