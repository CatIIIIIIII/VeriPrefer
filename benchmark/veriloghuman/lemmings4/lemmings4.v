
module top_module (
	input clk,
	input areset,
	input bump_left,
	input bump_right,
	input ground,
	input dig,
	output reg walk_left,
	output reg walk_right,
	output reg aaah,
	output reg digging
);

	// Define states
	typedef enum reg [3:0] {
		WALK_LEFT,
		WALK_RIGHT,
		FALL,
		DIG_LEFT,
		DIG_RIGHT,
		SPLATTER
	} state_t;

	// State register
	state_t state, next_state;

	// Reset state
	always @(posedge clk or posedge areset) begin
		if (areset)
			state <= WALK_LEFT;
		else
			state <= next_state;
	end

	// Next state logic
	always @(*) begin
		next_state = state;
		case (state)
			WALK_LEFT: begin
				if (bump_left)
					next_state = WALK_RIGHT;
				else if (bump_right)
					next_state = WALK_LEFT;
				else if (!ground)
					next_state = FALL;
				else if (dig)
					next_state = DIG_LEFT;
			end
			WALK_RIGHT: begin
				if (bump_right)
					next_state = WALK_LEFT;
				else if (bump_left)
					next_state = WALK_RIGHT;
				else if (!ground)
					next_state = FALL;
				else if (dig)
					next_state = DIG_RIGHT;
			end
			FALL: begin
				if (ground)
					next_state = WALK_LEFT;
			end
			DIG_LEFT: begin
				if (!ground)
					next_state = FALL;
				else if (ground)
					next_state = WALK_LEFT;
			end
			DIG_RIGHT: begin
				if (!ground)
					next_state = FALL;
				else if (ground)
					next_state = WALK_RIGHT;
			end
			SPLATTER: begin
				next_state = SPLATTER;
			end
		endcase
	end

	// Output logic
	always @(*) begin
		walk_left = 0;
		walk_right = 0;
		aaah = 0;
		digging = 0;

		case (state)
			WALK_LEFT: begin
				walk_left = 1;
			end
			WALK_RIGHT: begin
				walk_right = 1;
			end
			FALL: begin
				aaah = 1;
			end
			DIG_LEFT: begin
				digging = 1;
			end
			DIG_RIGHT: begin
				digging = 1;
			end
			SPLATTER: begin
				// All outputs are 0
			end
		endcase
	end

endmodule
