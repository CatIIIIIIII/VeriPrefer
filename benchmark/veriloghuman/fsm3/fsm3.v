
module top_module (
	input clk,
	input in,
	input areset,
	output reg out
);

	// Define the states
	typedef enum reg [1:0] {A, B, C, D} state_t;
	reg [1:0] current_state, next_state;

	// State transition logic
	always @(posedge clk or posedge areset) begin
		if (areset) begin
			current_state <= A; // Reset to state A
		end else begin
			current_state <= next_state;
		end
	end

	// Next state logic
	always @(*) begin
		case (current_state)
			A: begin
				if (in == 0)
					next_state = A;
				else
					next_state = B;
			end
			B: begin
				if (in == 0)
					next_state = C;
				else
					next_state = B;
			end
			C: begin
				if (in == 0)
					next_state = A;
				else
					next_state = D;
			end
			D: begin
				if (in == 0)
					next_state = C;
				else
					next_state = B;
			end
			default: next_state = A; // Default case
		endcase
	end

	// Output logic
	always @(current_state) begin
		case (current_state)
			A, B, C: out = 0;
			D: out = 1;
			default: out = 0; // Default case
		endcase
	end

endmodule
