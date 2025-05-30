
module top_module (
	input clk,
	input a, 
	output reg [2:0] q
);

always @(posedge clk) begin
	if (a) begin
		if (q == 7) begin
			q <= 0;
		end else begin
			q <= q + 1;
		end
	end else begin
		q <= 0;
	end
end

endmodule
