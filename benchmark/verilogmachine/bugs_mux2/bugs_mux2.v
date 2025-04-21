
module top_module (
	input sel,
	input [7:0] a,
	input [7:0] b,
	output reg [7:0] out
);

always @(*) begin
    if (sel == 0) begin
        out = b;
    end else if (sel == 1) begin
        out = a;
    end else begin
        out = 8'b0;  // Default value if sel is neither 0 nor 1
    end
end

endmodule
