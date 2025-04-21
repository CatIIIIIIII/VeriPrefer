
module top_module (
	input clk,
	input in,
	input reset,
	output reg [7:0] out_byte,
	output reg done
);

// Define states
typedef enum reg [2:0] {
	IDLE,
	START,
	DATA,
	STOP
} state_t;

state_t state, next_state;

// Shift register to hold the data bits
reg [7:0] shift_reg;

// Counter to track the number of data bits received
reg [2:0] bit_count;

// Synchronous reset
always @(posedge clk or posedge reset) begin
	if (reset) begin
		state <= IDLE;
		out_byte <= 8'b0;
		done <= 0;
		shift_reg <= 8'b0;
		bit_count <= 3'b0;
	end else begin
		state <= next_state;
		case (state)
			IDLE: begin
				if (in == 0) begin
					next_state <= START;
					shift_reg <= 8'b0;
					bit_count <= 3'b0;
				end else begin
					next_state <= IDLE;
				end
			end
			START: begin
				if (bit_count < 3'b100) begin
					next_state <= DATA;
					shift_reg <= {shift_reg[6:0], in};
					bit_count <= bit_count + 1;
				end else begin
					next_state <= STOP;
				end
			end
			DATA: begin
				if (bit_count < 3'b1000) begin
					next_state <= DATA;
					shift_reg <= {shift_reg[6:0], in};
					bit_count <= bit_count + 1;
				end else begin
					next_state <= STOP;
				end
			end
			STOP: begin
				if (in == 1) begin
					next_state <= IDLE;
					out_byte <= shift_reg;
					done <= 1;
				end else begin
					next_state <= STOP;
				end
			end
		endcase
	end
end

// Asynchronous reset for done signal
always @(posedge clk or posedge reset) begin
	if (reset) begin
		done <= 0;
	end else if (state == STOP && in == 1) begin
		done <= 0;
	end
end

endmodule
