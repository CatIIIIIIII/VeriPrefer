
module top_module (
	input clk,
	input resetn,
	input x,
	input y,
	output reg f,
	output reg g
);

	// Define the states
	typedef enum reg [2:0] {
		STATE_A,  // Initial state
		STATE_B,  // State after reset de-assertion
		STATE_C,  // State after setting f to 1
		STATE_D,  // State monitoring x for 1, 0, 1
		STATE_E,  // State setting g to 1
		STATE_F,  // State monitoring y for 1 within 2 cycles
		STATE_G   // State maintaining g = 1 permanently
	} state_t;

	// Declare the current state and next state
	state_t current_state, next_state;

	// State register
	always @(posedge clk or negedge resetn) begin
		if (!resetn) begin
			current_state <= STATE_A;
		end else begin
			current_state <= next_state;
		end
	end

	// Next state logic
	always @(*) begin
		next_state = current_state;  // Default is to stay in the current state

		case (current_state)
			STATE_A: begin
				if (!resetn) begin
					next_state = STATE_A;
				end else begin
					next_state = STATE_B;
				end
			end

			STATE_B: begin
				next_state = STATE_C;
			end

			STATE_C: begin
				next_state = STATE_D;
			end

			STATE_D: begin
				if (x == 1) begin
					next_state = STATE_D;
				end else if (x == 0) begin
					next_state = STATE_E;
				end else begin
					next_state = STATE_D;
				end
			end

			STATE_E: begin
				if (x == 1) begin
					next_state = STATE_F;
				end else begin
					next_state = STATE_E;
				end
			end

			STATE_F: begin
				if (y == 1) begin
					next_state = STATE_G;
				end else begin
					next_state = STATE_F;
				end
			end

			STATE_G: begin
				next_state = STATE_G;
			end

			default: begin
				next_state = STATE_A;
			end
		endcase
	end

	// Output logic
	always @(*) begin
		f = 0;
		g = 0;

		case (current_state)
			STATE_B: begin
				f = 1;
			end

			STATE_E: begin
				g = 1;
			end

			STATE_G: begin
				g = 1;
			end

			default: begin
				f = 0;
				g = 0;
			end
		endcase
	end

endmodule
