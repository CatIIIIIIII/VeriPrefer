
module top_module (
	input clk,
	input in,
	input areset,
	output reg out
);

// Define the states
parameter [1:0] A = 2'b00;
parameter [1:0] B = 2'b01;
parameter [1:0] C = 2'b10;
parameter [1:0] D = 2'b11;

// State register
reg [1:0] state;

// Combinational logic to determine the next state
always @(*) begin
	case (state)
		A: begin
			if (in)
				next_state = B;
			else
				next_state = A;
		end
		B: begin
			if (in)
				next_state = B;
			else
				next_state = C;
		end
		C: begin
			if (in)
				next_state = D;
			else
				next_state = A;
		end
		D: begin
			if (in)
				next_state = B;
			else
				next_state = C;
		end
		default: next_state = A;
	endcase
end

// Sequential logic to update the state register
always @(posedge clk or posedge areset) begin
	if (areset)
		state <= A;
	else
		state <= next_state;
end

// Output logic
always @(*) begin
	if (state == D)
		out = 1'b1;
	else
		out = 1'b0;
end

endmodule
