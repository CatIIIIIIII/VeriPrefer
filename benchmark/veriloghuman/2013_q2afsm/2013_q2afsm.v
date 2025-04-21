
module top_module (
	input clk,
	input resetn,
	input [3:1] r,
	output [3:1] g
);

// State encoding
parameter [1:0] A = 2'b00;
parameter [1:0] B = 2'b01;
parameter [1:0] C = 2'b10;
parameter [1:0] D = 2'b11;

// State register
reg [1:0] current_state, next_state;

// State table
always @(*) begin
	case (current_state)
		A: begin
			if (r[1] == 1)
				next_state = B;
			else if (r[2] == 1)
				next_state = C;
			else if (r[3] == 1)
				next_state = D;
			else
				next_state = A;
		end
		B: begin
			if (r[1] == 1)
				next_state = B;
			else
				next_state = A;
		end
		C: begin
			if (r[2] == 1)
				next_state = C;
			else
				next_state = A;
		end
		D: begin
			if (r[3] == 1)
				next_state = D;
			else
				next_state = A;
		end
		default: next_state = A;
	endcase
end

// State flip-flops
always @(posedge clk or negedge resetn) begin
	if (!resetn)
		current_state <= A;
	else
		current_state <= next_state;
end

// Output assignment
always @(*) begin
	g[1] = (current_state == B) ? 1 : 0;
	g[2] = (current_state == C) ? 1 : 0;
	g[3] = (current_state == D) ? 1 : 0;
end

endmodule
