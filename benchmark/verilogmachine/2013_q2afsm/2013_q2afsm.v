
module top_module (
	input clk,
	input resetn,
	input [3:1] r,
	output [3:1] g
);

	// Define the states
	typedef enum logic [1:0] {
		A = 2'b00,
		B = 2'b01,
		C = 2'b10,
		D = 2'b11
	} state_t;

	// State registers
	state_t state, next_state;

	// State register update on rising edge of clock
	always_ff @(posedge clk or negedge resetn) begin
		if (!resetn) begin
			state <= A;
		end else begin
			state <= next_state;
		end
	end

	// Next state logic
	always_comb begin
		case (state)
			A: begin
				if (r[1]) begin
					next_state = B;
				end else if (r[2]) begin
					next_state = C;
				end else if (r[3]) begin
					next_state = D;
				end else begin
					next_state = A;
				end
			end
			B: begin
				if (r[1]) begin
					next_state = B;
				end else begin
					next_state = A;
				end
			end
			C: begin
				if (r[2]) begin
					next_state = C;
				end else begin
					next_state = A;
				end
			end
			D: begin
				if (r[3]) begin
					next_state = D;
				end else begin
					next_state = A;
				end
			end
			default: begin
				next_state = A;
			end
		endcase
	end

	// Output logic
	always_comb begin
		g = 3'b000;
		case (state)
			B: g[1] = 1'b1;
			C: g[2] = 1'b1;
			D: g[3] = 1'b1;
			default: g = 3'b000;
		endcase
	end

endmodule
