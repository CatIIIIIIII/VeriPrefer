
module top_module (
	input [5:0] y,
	input w,
	output Y1,
	output Y3
);

assign Y1 = (y == 6'b000001 && w == 1'b1) || (y == 6'b001000 && w == 1'b1);
assign Y3 = (y == 6'b000010 && w == 1'b0) || (y == 6'b000100 && w == 1'b0) || (y == 6'b001000 && w == 1'b0);

endmodule
