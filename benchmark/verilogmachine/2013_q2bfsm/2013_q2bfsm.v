
module top_module (
	input clk,
	input resetn,
	input x,
	input y,
	output reg f,
	output reg g
);

	// Define the states
	typedef enum reg [3:0] {
		A = 4'b0000,
		B = 4'b0001,
		S0 = 4'b0010,
		S1 = 4'b0011,
		S10 = 4'b0100,
		G1 = 4'b0101,
		G2 = 4'b0110,
		P0 = 4'b0111,
		P1 = 4'b1000
	} state_t;

	// State register
	reg [3:0] current_state, next_state;

	// State transition logic
	always @(posedge clk or negedge resetn) begin
		if (!resetn) begin
			current_state <= A;
		end else begin
			current_state <= next_state;
		end
	end

	// Next state logic
	always @(*) begin
		case (current_state)
			A: next_state = B;
			B: next_state = S0;
			S0: next_state = (x == 1) ? S1 : S0;
			S1: next_state = (x == 1) ? S1 : S10;
			S10: next_state = (x == 1) ? G1 : S0;
			G1: next_state = (y == 1) ? P1 : G2;
			G2: next_state = (y == 1) ? P1 : P0;
			P0: next_state = P0;
			P1: next_state = P1;
			default: next_state = A;
		endcase
	end

	// Output logic
	always @(posedge clk or negedge resetn) begin
		if (!resetn) begin
			f <= 1'b0;
			g <= 1'b0;
		end else begin
			f <= (current_state == B) ? 1'b1 : 1'b0;
			g <= (current_state == G1 || current_state == G2 || current_state == P1) ? 1'b1 : 1'b0;
		end
	end

endmodule
