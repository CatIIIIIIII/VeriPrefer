
module top_module (
	input clk,
	input areset,
	input x,
	output z
);

	// Define the states
	parameter A = 2'b00;
	parameter B = 2'b01;

	// State register
	reg [1:0] state;

	// Output register
	reg z_reg;

	// State machine logic
	always @(posedge clk or posedge areset) begin
		if (areset) begin
			state <= A;
			z_reg <= 0;
		end else begin
			case (state)
				A: begin
					if (x) begin
						state <= B;
						z_reg <= 1;
					end else begin
						state <= A;
						z_reg <= 0;
					end
				end
				B: begin
					if (x) begin
						state <= B;
						z_reg <= 0;
					end else begin
						state <= A;
						z_reg <= 1;
					end
				end
				default: begin
					state <= A;
					z_reg <= 0;
				end
			endcase
		end
	end

	// Assign output
	assign z = z_reg;

endmodule
