module mux2(
    input logic sel,
    input logic [31:0] in1, 
    input logic [31:0] in2, 

    output logic [31:0] out
);
    assign out = sel ? in2 : in1;

endmodule
