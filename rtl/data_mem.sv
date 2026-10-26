module data_mem(
    input logic clk,
    input logic write_mem_flag,

    input logic [31:0] addr,
    input logic [31:0] write_data,

    output logic [31:0] mem_out_data
);

    logic [31:0] mem [0:255];

    assign mem_out_data = mem[addr[9:2]];

    always_ff @(posedge clk) begin
        if (write_mem_flag)
            mem[addr[9:2]] <= write_data;
    end

endmodule
