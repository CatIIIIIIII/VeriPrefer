
module top_module (
	input clk,
	input j,
	input k,
	input areset,
	output reg out
);

// Define the states
parameter OFF = 2'b00;
parameter ON = 2'b01;

// State register
reg [1:0] current_state, next_state;

// State transition logic
always @(posedge clk or posedge areset) begin
	if (areset) begin
		current_state <= OFF;
	end else begin
		current_state <= next_state;
	end
end

// Next state logic
always @(*) begin
	case (current_state)
		OFF: begin
			if (j == 1'b1) begin
				next_state = ON;
			end else begin
				next_state = OFF;
			end
		end
		ON: begin
			if (k == 1'b1) begin
				next_state = OFF;
			end else begin
				next_state = ON;
			end
		end
		default: next_state = OFF;
	endcase
end

// Output logic
always @(current_state) begin
	case (current_state)
		OFF: out = 1'b0;
		ON: out = 1'b1;
		default: out = 1'b0;
	endcase
end

endmodule
