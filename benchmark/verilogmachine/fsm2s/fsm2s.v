
module top_module (
	input clk,
	input j,
	input k,
	input reset,
	output reg out
);

	// Define the states
	typedef enum reg {A, B} state_t;
	reg state_t current_state, next_state;

	// State transition logic
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			current_state <= A;
		end else begin
			current_state <= next_state;
		end
	end

	// Determine the next state based on current state and inputs
	always @(*) begin
		case (current_state)
			A: begin
				if (j) begin
					next_state = B;
				end else begin
					next_state = A;
				end
			end
			B: begin
				if (k) begin
					next_state = A;
				end else begin
					next_state = B;
				end
			end
		endcase
	end

	// Output logic
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			out <= 0;
		end else begin
			out <= (current_state == B) ? 1 : 0;
		end
	end

endmodule
