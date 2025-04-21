
module top_module (
	input clk,
	input [7:0] in,
	input reset,
	output reg [23:0] out_bytes,
	output reg done
);

// State definitions
typedef enum reg [1:0] {
	IDLE,
	BYTE1,
	BYTE2
} state_t;

// State register
state_t state, next_state;

// Internal registers to store the bytes of the message
reg [7:0] byte1, byte2;

// State transition logic
always @(posedge clk or posedge reset) begin
	if (reset) begin
		state <= IDLE;
		done <= 0;
	end else begin
		state <= next_state;
	end
end

// Next state logic
always @(*) begin
	next_state = state;
	case (state)
		IDLE: begin
			if (in[3] == 1) begin
				next_state = BYTE1;
				byte1 = in;
			end
		end
		BYTE1: begin
			next_state = BYTE2;
			byte2 = in;
		end
		BYTE2: begin
			next_state = IDLE;
			done = 1;
		end
	endcase
end

// Output logic
always @(posedge clk or posedge reset) begin
	if (reset) begin
		out_bytes <= 24'b0;
		done <= 0;
	end else begin
		case (state)
			IDLE: begin
				out_bytes <= 24'b0;
				done <= 0;
			end
			BYTE1: begin
				out_bytes[23:16] <= byte1;
				done <= 0;
			end
			BYTE2: begin
				out_bytes[15:8] <= byte2;
				out_bytes[7:0] <= in;
				done <= 1;
			end
		endcase
	end
end

endmodule
