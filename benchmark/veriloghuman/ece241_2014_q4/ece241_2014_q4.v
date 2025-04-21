
module top_module (
	input clk,
	input x,
	output z
);

reg q1, q2, q3;

// XOR gate
assign q1 = x ^ q1;

// AND gate
assign q2 = x & ~q2;

// OR gate
assign q3 = x | ~q3;

// D flip-flops
always @(posedge clk) begin
    q1 <= q1;
    q2 <= q2;
    q3 <= q3;
end

// XNOR gate
assign z = ~(q1 ^ q2 ^ q3);

endmodule
