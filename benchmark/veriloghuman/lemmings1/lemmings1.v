
module top_module (
	input clk,
	input areset,
	input bump_left,
	input bump_right,
	output reg walk_left,
	output reg walk_right
);

	// Define states
	typedef enum reg {LEFT, RIGHT} state_t;
	state_t current_state, next_state;

	// State transition logic
	always @(posedge clk or posedge areset) begin
		if (areset) begin
			current_state <= LEFT;
		end else begin
			current_state <= next_state;
		end
	end

	// Next state logic
	always @(*) begin
		case (current_state)
			LEFT: begin
				if (bump_left || bump_right) begin
					next_state = RIGHT;
				end else begin
					next_state = LEFT;
				end
			end
			RIGHT: begin
				if (bump_left || bump_right) begin
					next_state = LEFT;
				end else begin
					next_state = RIGHT;
				end
			end
			default: next_state = LEFT;
		endcase
	end

	// Output logic
	always @(current_state) begin
		case (current_state)
			LEFT: begin
				walk_left = 1;
				walk_right = 0;
			end
			RIGHT: begin
				walk_left = 0;
				walk_right = 1;
			end
			default: begin
				walk_left = 1;
				walk_right = 0;
			end
		endcase
	end

endmodule
