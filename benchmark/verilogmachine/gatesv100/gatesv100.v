
module top_module (
	input [99:0] in,
	output [98:0] out_both,
	output [99:1] out_any,
	output [99:0] out_different
);

	// Shift the input vector by one bit
	wire [99:0] shifted_in = {in[98:0], 1'b0};

	// Generate out_both by performing a bit-wise AND operation
	assign out_both = in & shifted_in;

	// Generate out_any by performing a bit-wise OR operation
	assign out_any = in | shifted_in;

	// Generate out_different by performing a bit-wise XOR operation
	assign out_different = in ^ shifted_in;

endmodule
