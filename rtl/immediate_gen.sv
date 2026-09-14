/*

this immediate generator takes in the 32 bit instruction, extracts the immediate based on the 
type sent by the control unit and outputs its 32 bit expansion. 

*/

module immediate_gen(
    input logic [31:0] instruc,
    input logic [2:0] imm_type,

    output logic [31:0] extended_immed
);

        // making constants
        localparam logic [2:0]
            IMM_I = 3'b000, 
            IMM_J = 3'b001,
            IMM_B = 3'b010,
            IMM_U = 3'b011,
            IMM_S = 3'b100;

    // break the instruction signal based on datatype
    always_comb begin
        case (imm_type)

            IMM_I: begin 
                extended_immed = {{20{instruc[31]}}, instruc[31:20]};
            end

            IMM_S: begin 
                extended_immed = {{20{instruc[31]}}, instruc[31:25], instruc[11:7]};
            end

            IMM_B: begin 
                extended_immed = {{19{instruc[31]}}, instruc[31], instruc[7], instruc[30:25], instruc[11:8], 1'b0};
            end

            IMM_U: begin
                extended_immed = {{instruc[31:12]}, 12'b0};
            end

            IMM_J: begin
                extended_immed = {{11{instruc[31]}}, instruc[31], instruc[19:12], instruc[20], instruc[30:21], 1'b0};
            end

            default: extended_immed = 32'd0;

        endcase 

    end

endmodule
