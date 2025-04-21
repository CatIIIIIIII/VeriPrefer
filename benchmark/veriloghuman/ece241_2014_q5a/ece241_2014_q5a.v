
module top_module (
	input clk,
	input areset,
	input x,
	output reg z
);

// State encoding
parameter IDLE = 2'b00;
parameter INVERT = 2'b01;

// State register
reg [1:0] state;

// Next state logic
always @(posedge clk or posedge areset) begin
	if (areset) begin
		state <= IDLE;
	end else begin
		case (state)
			IDLE: begin
				if (x == 1'b1) begin
					state <= INVERT;
				end else begin
					state <= IDLE;
				end
			end
			INVERT: begin
				state <= INVERT;
			end
			default: begin
				state <= IDLE;
			end
		endcase
	end
end

// Output logic
always @(posedge clk or posedge areset) begin
	if (areset) begin
		z <= 1'b0;
	end else begin
		case (state)
			IDLE: begin
				z <= 1'b0;
			end
			INVERT: begin
				z <= ~x;
			end
			default: begin
				z <= 1'b0;
			end
		endcase
	end
end

endmodule
