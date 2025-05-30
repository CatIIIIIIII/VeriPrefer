
module top_module (
	input clock,
	input a, 
	output reg p,
	output reg q
);

	// Always block triggered on the negative edge of the clock
	always @(negedge clock) begin
		q <= a;
	end

	// Always block triggered on any change of the input signal a
	always @(a) begin
		if (clock) begin
			p <= a;
		end
	end

endmodule
