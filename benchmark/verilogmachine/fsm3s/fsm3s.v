
module top_module (
	input clk,
	input in,
	input reset,
	output reg out
);

	// Define the states
	typedef enum reg [1:0] {A, B, C, D} state_t;
	
	// Declare the current state and next state
	state_t current_state, next_state;

	// State register
	always @(posedge clk or posedge reset) begin
		if (reset)
			current_state <= A;
		else
			current_state <= next_state;
	end

	// Next state logic
	always @(*) begin
		case (current_state)
			A: begin
				if (in)
					next_state = B;
				else
					next_state = A;
			end
			B: begin
				if (in)
					next_state = B;
				else
					next_state = C;
			end
			C: begin
				if (in)
					next_state = D;
				else
					next_state = A;
			end
			D: begin
				if (in)
					next_state = B;
				else
					next_state = C;
			end
			default: next_state = A;
		endcase
	end

	// Output logic
	always @(*) begin
		if (current_state == D)
			out = 1;
		else
			out = 0;
	end

endmodule
