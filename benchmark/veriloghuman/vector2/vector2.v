
module top_module (
	input [31:0] in,
	output [31:0] out
);

// Reverse the byte order
assign out = {in[7:0], in[15:8], in[23:16], in[31:24]};

endmodule
