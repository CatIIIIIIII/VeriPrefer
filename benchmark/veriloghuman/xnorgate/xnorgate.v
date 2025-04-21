
module top_module(
	input a, 
	input b,
	output out
);

// XNOR gate logic
assign out = ~(a ^ b);

endmodule
