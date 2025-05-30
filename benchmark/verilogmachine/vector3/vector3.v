
module top_module (
	input [4:0] a,
	input [4:0] b,
	input [4:0] c,
	input [4:0] d,
	input [4:0] e,
	input [4:0] f,
	output [7:0] w,
	output [7:0] x,
	output [7:0] y,
	output [7:0] z
);

// Concatenate the inputs and the value 2'b11
wire [47:0] concatenated;
assign concatenated = {a, b, c, d, e, f, 2'b11};

// Assign the concatenated signal to the outputs
assign w = concatenated[47:40];
assign x = concatenated[39:32];
assign y = concatenated[31:24];
assign z = concatenated[23:16];

endmodule
