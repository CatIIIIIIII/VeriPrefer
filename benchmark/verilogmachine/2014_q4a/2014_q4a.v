
module top_module (
	input clk,
	input w,
	input R,
	input E,
	input L,
	output reg Q
);

always @(posedge clk) begin
	if (!E) begin
		// If E is low, hold the current state of Q
		Q <= Q;
	end else begin
		if (L) begin
			// If L is high, update Q with the value of R
			Q <= R;
		end else begin
			// If L is low, update Q with the value of w
			Q <= w;
		end
	end
end

endmodule
