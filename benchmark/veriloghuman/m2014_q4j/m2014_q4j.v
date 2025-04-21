
module top_module (
	input [3:0] x,
	input [3:0] y,
	output [4:0] sum
);

// Internal signals to connect the full adders
wire c0, c1, c2, c3;

// Full adder for the least significant bit (LSB)
full_adder fa0 (
	.a(x[0]),
	.b(y[0]),
	.cin(1'b0),
	.sum(sum[0]),
	.cout(c0)
);

// Full adder for the second bit
full_adder fa1 (
	.a(x[1]),
	.b(y[1]),
	.cin(c0),
	.sum(sum[1]),
	.cout(c1)
);

// Full adder for the third bit
full_adder fa2 (
	.a(x[2]),
	.b(y[2]),
	.cin(c1),
	.sum(sum[2]),
	.cout(c2)
);

// Full adder for the most significant bit (MSB)
full_adder fa3 (
	.a(x[3]),
	.b(y[3]),
	.cin(c2),
	.sum(sum[3]),
	.cout(c3)
);

// Overflow bit is the carry out from the most significant bit
assign sum[4] = c3;

endmodule

// Full adder module
module full_adder (
	input a,
	input b,
	input cin,
	output sum,
	output cout
);

assign sum = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
