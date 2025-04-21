
module top_module (
	input clk,
	input areset,
	input x,
	output reg z
);

	// Parameters for the states
	parameter A = 2'b00;
	parameter B = 2'b01;
	parameter C = 2'b10;

	// State register
	reg [1:0] state;

	// Always block triggered on the positive edge of the clock and reset signal
	always @(posedge clk or posedge areset) begin
		if (areset) begin
			// Reset the state to A
			state <= A;
		end else begin
			// Determine the next state based on the current state and input x
			case (state)
				A: begin
					if (x) begin
						state <= C;
					end else begin
						state <= A;
					end
				end
				B: begin
					if (x) begin
						state <= B;
					end else begin
						state <= C;
					end
				end
				C: begin
					if (x) begin
						state <= B;
					end else begin
						state <= C;
					end
				end
				default: begin
					state <= A; // Default case, should not happen
				end
			endcase
		end
	end

	// Determine the output based on the current state
	always @(*) begin
		if (state == C) begin
			z = 1'b1;
		end else begin
			z = 1'b0;
		end
	end

endmodule
