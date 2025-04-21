
module top_module (
	input clk,
	input reset,
	input [3:1] s,
	output reg fr3,
	output reg fr2,
	output reg fr1,
	output reg dfr
);

// Define states
typedef enum reg [1:0] {
	LOW,      // Below s[1]
	BETWEEN1, // Between s[2] and s[1]
	BETWEEN2, // Between s[3] and s[2]
	HIGH      // Above s[3]
} state_t;

// State register
reg [1:0] current_state, next_state;

// State transition logic
always @(posedge clk or posedge reset) begin
	if (reset) begin
		current_state <= LOW;
	end else begin
		current_state <= next_state;
	end
end

// Next state logic
always @(*) begin
	case (current_state)
		LOW: begin
			if (s[1] == 1'b1) begin
				next_state = BETWEEN1;
			end else begin
				next_state = LOW;
			end
		end
		BETWEEN1: begin
			if (s[2] == 1'b1) begin
				next_state = BETWEEN2;
			end else if (s[1] == 1'b0) begin
				next_state = LOW;
			end else begin
				next_state = BETWEEN1;
			end
		end
		BETWEEN2: begin
			if (s[3] == 1'b1) begin
				next_state = HIGH;
			end else if (s[2] == 1'b0) begin
				next_state = BETWEEN1;
			end else begin
				next_state = BETWEEN2;
			end
		end
		HIGH: begin
			if (s[3] == 1'b0) begin
				next_state = BETWEEN2;
			end else begin
				next_state = HIGH;
			end
		end
		default: begin
			next_state = LOW;
		end
	endcase
end

// Output logic
always @(*) begin
	case (current_state)
		LOW: begin
			fr3 = 1'b1;
			fr2 = 1'b1;
			fr1 = 1'b1;
			dfr = 1'b0;
		end
		BETWEEN1: begin
			fr3 = 1'b0;
			fr2 = 1'b0;
			fr1 = 1'b1;
			dfr = 1'b0;
		end
		BETWEEN2: begin
			fr3 = 1'b0;
			fr2 = 1'b1;
			fr1 = 1'b1;
			dfr = 1'b0;
		end
		HIGH: begin
			fr3 = 1'b0;
			fr2 = 1'b0;
			fr1 = 1'b0;
			dfr = 1'b0;
		end
		default: begin
			fr3 = 1'b1;
			fr2 = 1'b1;
			fr1 = 1'b1;
			dfr = 1'b0;
		end
	endcase
end

// Additional logic to handle sensor change and increase flow rate
always @(posedge clk or posedge reset) begin
	if (reset) begin
		dfr <= 1'b0;
	end else begin
		if (current_state == LOW && next_state == BETWEEN1) begin
			dfr <= 1'b1;
		end else if (current_state == BETWEEN1 && next_state == BETWEEN2) begin
			dfr <= 1'b1;
		end else if (current_state == BETWEEN2 && next_state == HIGH) begin
			dfr <= 1'b1;
		end else begin
			dfr <= 1'b0;
		end
	end
end

endmodule
