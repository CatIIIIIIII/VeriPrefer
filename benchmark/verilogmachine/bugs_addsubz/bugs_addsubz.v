
module top_module (
	input do_sub,
	input [7:0] a,
	input [7:0] b,
	output reg [7:0] out,
	output reg result_is_zero
);

always @(*) begin
	case (do_sub)
		0: begin
			// Perform addition
			out = a + b;
		end
		1: begin
			// Perform subtraction
			out = a - b;
		end
		default: begin
			// Default case, should not occur
			out = 8'b0;
		end
	endcase

	// Check if the result is zero
	result_is_zero = (out == 8'b0) ? 1'b1 : 1'b0;
end

endmodule
