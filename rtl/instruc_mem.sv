module instruc_mem (
    input logic [31:0] pc,

    output logic [31:0] instruction
);

    logic [31:0] mem [0:255];

    assign instruction = mem[pc[9:2]];

endmodule
