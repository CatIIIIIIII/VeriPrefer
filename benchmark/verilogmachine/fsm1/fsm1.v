
module top_module (
	input clk,
	input in,
	input areset,
	output reg out
);

	// Define the states
	typedef enum logic {A, B} state_t;
	reg state_t current_state, next_state;

	// State transition logic
	always @(*) begin
		case (current_state)
			A: begin
				if (in)
					next_state = A;
				else
					next_state = B;
			end
			B: begin
				if (in)
					next_state = B;
				else
					next_state = A;
			end
			default: next_state = B; // Default state is B
		endcase
	end

	// State register
	always @(posedge clk or posedge areset) begin
		if (areset)
			current_state <= B;
		else
			current_state <= next_state;
	end

	// Output logic
	always @(posedge clk or posedge areset) begin
		if (areset)
			out <= 0;
		else
			out <= (current_state == B);
	end

endmodule
