
module top_module (
	input [1023:0] in,
	input [7:0] sel,
	output [3:0] out
);

// Calculate the starting index of the 4-bit block in the input vector
wire [9:0] start_index;
assign start_index = sel << 2; // Each 4-bit block is 2 bits wide in terms of index shift

// Extract the 4-bit block from the input vector starting from the calculated index
assign out = in[start_index +: 4];

endmodule
