
module top_module (
    input in1,
    input in2,
    output logic out
);

// Invert the in2 input
logic inverted_in2;
assign inverted_in2 = ~in2;

// AND gate with in1 and the inverted in2
assign out = in1 & inverted_in2;

endmodule
