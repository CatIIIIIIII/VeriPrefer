
module top_module (
	input in,
	input [1:0] state,
	output reg [1:0] next_state,
	output out
);

always @(*) begin
	case (state)
		2'b00: begin // State A
			if (in == 0)
				next_state = 2'b00; // Next state is A
			else
				next_state = 2'b01; // Next state is B
			out = 0; // Output is 0
		end
		2'b01: begin // State B
			if (in == 0)
				next_state = 2'b10; // Next state is C
			else
				next_state = 2'b01; // Next state is B
			out = 0; // Output is 0
		end
		2'b10: begin // State C
			if (in == 0)
				next_state = 2'b00; // Next state is A
			else
				next_state = 2'b11; // Next state is D
			out = 0; // Output is 0
		end
		2'b11: begin // State D
			if (in == 0)
				next_state = 2'b10; // Next state is C
			else
				next_state = 2'b01; // Next state is B
			out = 1; // Output is 1
		end
		default: begin
			next_state = 2'b00; // Default next state is A
			out = 0; // Default output is 0
		end
	endcase
end

endmodule
