
module top_module (
	input [2:0] in,
	output [1:0] out
);

// Internal signals to hold intermediate results
wire count_0, count_1, count_2;

// Count the number of '1's in each bit position
assign count_0 = in[0];
assign count_1 = in[1];
assign count_2 = in[2];

// Sum the counts to get the total number of '1's
assign out = count_0 + count_1 + count_2;

endmodule
