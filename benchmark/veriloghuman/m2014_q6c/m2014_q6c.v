
module top_module (
	input [6:1] y,
	input w,
	output Y2,
	output Y4
);

assign Y2 = y[1] & ~w;  // y[1] is the bit for state A, and we need w = 0 to transition to B

assign Y4 = (y[2] | y[3]) & ~w | y[6] & w;  // y[2] is the bit for state B, y[3] is the bit for state C, and y[6] is the bit for state F

endmodule
