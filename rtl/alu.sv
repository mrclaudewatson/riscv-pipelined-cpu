module alu(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] alu_control,
    output logic [31:0] result,
    output logic zero);

    localparam logic [3:0]
        alu_add = 4'b0000,
        alu_sub = 4'b0001,
        alu_and = 4'b0010,
        alu_or = 4'b0011,
        alu_xor = 4'b0100,
        alu_sll = 4'b0101,
        alu_srl = 4'b0110,
        alu_sra = 4'b0111,
        alu_slt = 4'b1000,
        alu_sltu = 4'b1001;

    always_comb begin
        case(alu_control)

        alu_add: begin
            result = a + b;
        end

        alu_sub: begin
            result = a - b;
        end

        alu_and: begin
            result = a & b;
        end

        alu_or: begin
            result = a | b;
        end

        alu_xor: begin
            result = a ^ b;
        end

        alu_sll: begin
            result = a << b[4:0];
        end

        alu_srl: begin
            result = a >> b[4:0];
        end

        alu_sra: begin
            result = $signed(a) >>> b[4:0];
        end

        alu_slt: begin
            result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
        end

        alu_sltu: begin
            result = (a < b) ? 32'd1 : 32'd0;
        end

        default: begin 
            result = 32'd0;
        end

        endcase
    end

    assign zero = (result == 32'd0);

endmodule

