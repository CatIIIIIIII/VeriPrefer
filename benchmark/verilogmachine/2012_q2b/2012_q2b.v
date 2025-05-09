
module top_module (
	input [5:0] y,
	input w,
	output Y1,
	output Y3
);

assign Y1 = y[5] & w; // Y1 is the logical AND of the first bit of y and w

assign Y3 = (y[4] | y[3] | y[1] | y[0]) & ~w; // Y3 is the logical AND of the logical OR of the second, third, fifth, and sixth bits of y and the logical NOT of w

endmodule
