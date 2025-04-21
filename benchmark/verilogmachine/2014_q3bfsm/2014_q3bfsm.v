
module top_module (
	input clk,
	input reset,
	input x,
	output reg z
);

	// Define the states using 3 bits
	typedef enum reg [2:0] {
		A = 3'b000,
		B = 3'b001,
		C = 3'b010,
		D = 3'b011,
		E = 3'b100
	} state_t;

	// Declare the current state and next state
	state_t current_state, next_state;

	// State register
	always @(posedge clk or posedge reset) begin
		if (reset)
			current_state <= A; // Initialize state to A on reset
		else
			current_state <= next_state; // Update state on clock edge
	end

	// Next state logic
	always @(*) begin
		case (current_state)
			A: begin
				if (x)
					next_state = B;
				else
					next_state = A;
			end
			B: begin
				if (x)
					next_state = E;
				else
					next_state = B;
			end
			C: begin
				if (x)
					next_state = B;
				else
					next_state = C;
			end
			D: begin
				if (x)
					next_state = C;
				else
					next_state = B;
			end
			E: begin
				if (x)
					next_state = E;
				else
					next_state = D;
			end
			default: next_state = A; // Default case, should not happen
		endcase
	end

	// Output logic
	always @(*) begin
		if (current_state == D || current_state == E)
			z = 1'b1; // Output is high when state is D or E
		else
			z = 1'b0; // Output is low otherwise
	end

endmodule
