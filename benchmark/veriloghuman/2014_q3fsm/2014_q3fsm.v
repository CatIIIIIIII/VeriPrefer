
module top_module (
	input clk,
	input reset,
	input s,
	input w,
	output reg z
);

	// Define the states
	typedef enum reg [1:0] {A, B, C, D} state_t;
	state_t state, next_state;

	// State register
	always @(posedge clk or posedge reset) begin
		if (reset)
			state <= A;
		else
			state <= next_state;
	end

	// Next state logic
	always @(*) begin
		next_state = state;
		case (state)
			A: begin
				if (s == 1)
					next_state = B;
			end
			B: begin
				case ({w, w, w})
					3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110: next_state = C;
					default: next_state = D;
				endcase
			end
			C: next_state = B;
			D: next_state = B;
		endcase
	end

	// Output logic
	always @(*) begin
		case (state)
			A: z = 0;
			B: z = 0;
			C: z = 1;
			D: z = 0;
		endcase
	end

endmodule
