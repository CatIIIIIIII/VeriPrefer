
module top_module (
	input [99:0] in,
	output out_and,
	output out_or,
	output out_xor
);

// Output of a 100-input AND gate
assign out_and = &in;

// Output of a 100-input OR gate
assign out_or = |in;

// Output of a 100-input XOR gate
assign out_xor = ^in;

endmodule
