
module top_module (
	input [3:0] in,
	output [2:0] out_both,
	output [3:1] out_any,
	output [3:0] out_different
);

// Bitwise AND operation between bits 2 through 0 and bits 3 through 1
assign out_both = in[2:0] & in[3:1];

// Bitwise OR operation between bits 2 through 0 and bits 3 through 1
assign out_any = {in[3], in[2:0] | in[3:1]};

// Bitwise XOR operation between the input vector and bits 3 through 1 with bit 0 as an exception
assign out_different = {in[3] ^ in[2], in[2] ^ in[1], in[1] ^ in[0], in[0]};

endmodule
