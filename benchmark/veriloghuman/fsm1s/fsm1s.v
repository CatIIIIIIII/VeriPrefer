
module top_module (
	input clk,
	input in,
	input reset,
	output reg out
);

// Define the states
typedef enum reg {B, A} state_t;
reg state_t current_state, next_state;

// State transition logic
always @(posedge clk or posedge reset) begin
	if (reset) begin
		current_state <= B;
	end else begin
		current_state <= next_state;
	end
end

// Next state logic
always @(*) begin
	case (current_state)
		B: begin
			if (in == 0) begin
				next_state = A;
			end else begin
				next_state = B;
			end
		end
		A: begin
			if (in == 0) begin
				next_state = B;
			end else begin
				next_state = A;
			end
		end
	endcase
end

// Output logic
always @(current_state) begin
	case (current_state)
		B: out = 1;
		A: out = 0;
	endcase
end

endmodule
