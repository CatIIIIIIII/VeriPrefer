
module top_module (
	input clk,
	input a, 
	output reg q
);

always @(posedge clk) begin
    if (a == 1) begin
        q <= 1;
    end
end

endmodule
