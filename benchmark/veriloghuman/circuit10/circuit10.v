
module top_module (
	input clk,
	input a,
	input b,
	output q,
	output state
);

reg q_reg;

// Combinational logic for state
assign state = a & b;

// D flip-flop with toggle logic
always @(posedge clk) begin
	if (a == 1 && b == 0) begin
		q_reg <= ~q_reg; // Toggle q_reg
	end
end

// Assign the flip-flop output to q
assign q = q_reg;

endmodule
