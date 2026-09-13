/*



*/

module reg_file(

    input logic clk,
    input logic wr_flag,

    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,

    input logic [31:0] write_data,

    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] registers [31:0];

    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    always_ff @(posedge clk) begin
        if (wr_flag && (rd != 5'd0))
            registers[rd] <= write_data;
    end

endmodule

