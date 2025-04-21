
module top_module(
	input x,
	input y,
	output z);

// Instantiate the first A submodule
wire a1_out;
A a1 (
	.x(x),
	.y(y),
	.z(a1_out)
);

// Instantiate the first B submodule
wire b1_out;
B b1 (
	.x(x),
	.y(y),
	.z(b1_out)
);

// Instantiate the second A submodule
wire a2_out;
A a2 (
	.x(x),
	.y(y),
	.z(a2_out)
);

// Instantiate the second B submodule
wire b2_out;
B b2 (
	.x(x),
	.y(y),
	.z(b2_out)
);

// Connect the outputs of the first A and B submodules to an OR gate
wire or_out;
assign or_out = a1_out | b1_out;

// Connect the outputs of the second A and B submodules to an AND gate
wire and_out;
assign and_out = a2_out & b2_out;

// Connect the outputs of the OR and AND gates to an XOR gate
assign z = or_out ^ and_out;

endmodule

// Module A implementation
module A(
	input x,
	input y,
	output z);
assign z = (x ^ y) & x;
endmodule

// Module B implementation
module B(
	input x,
	input y,
	output z);
// The waveform provided for Module B suggests a specific behavior that can be implemented using a case statement
always @(x, y) begin
	case ({x, y})
		2'b00: z = 1;
		2'b01: z = 0;
		2'b10: z = 0;
		2'b11: z = 1;
	endcase
end
endmodule
