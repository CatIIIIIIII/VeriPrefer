
module top_module (
	input clk,
	input reset,
	input w,
	output reg z
);

	// Define the states
	typedef enum reg [2:0] {A, B, C, D, E, F} state_t;
	reg [2:0] current_state, next_state;

	// State transition logic
	always @(*) begin
		case (current_state)
			A: begin
				if (w)
					next_state = A;
				else
					next_state = B;
			end
			B: begin
				if (w)
					next_state = D;
				else
					next_state = C;
			end
			C: begin
				if (w)
					next_state = D;
				else
					next_state = E;
			end
			D: begin
				if (w)
					next_state = A;
				else
					next_state = F;
			end
			E: begin
				if (w)
					next_state = D;
				else
					next_state = E;
			end
			F: begin
				if (w)
					next_state = D;
				else
					next_state = C;
			end
			default: next_state = A;
		endcase
	end

	// State register
	always @(posedge clk or posedge reset) begin
		if (reset)
			current_state <= A;
		else
			current_state <= next_state;
	end

	// Output logic
	always @(*) begin
		if (current_state == E || current_state == F)
			z = 1'b1;
		else
			z = 1'b0;
	end

endmodule
