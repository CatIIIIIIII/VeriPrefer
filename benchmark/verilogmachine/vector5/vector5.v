
module top_module (
	input a,
	input b,
	input c,
	input d,
	input e,
	output [24:0] out
);

// Create the first 25-bit vector with bits set to 1 where the corresponding input is 0
wire [24:0] not_vector;
assign not_vector = {5{~a}}, {5{~b}}, {5{~c}}, {5{~d}}, {5{~e}};

// Create the second 25-bit vector with bits set to 1 where the corresponding input is 1
wire [24:0] input_vector;
assign input_vector = {5{a}}, {5{b}}, {5{c}}, {5{d}}, {5{e}};

// Compute the bitwise XOR of the two vectors
assign out = not_vector ^ input_vector;

endmodule
