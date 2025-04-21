
module top_module (
	input clk,
	input reset,
	input x,
	output reg z
);

// Define the state type
typedef enum reg [2:0] {
    STATE_000 = 3'b000,
    STATE_001 = 3'b001,
    STATE_010 = 3'b010,
    STATE_011 = 3'b011,
    STATE_100 = 3'b100
} state_t;

// Declare the current and next state registers
reg [2:0] current_state, next_state;

// State register
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= STATE_000;
    end else begin
        current_state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (current_state)
        STATE_000: begin
            if (x == 0) next_state = STATE_000;
            else next_state = STATE_001;
            z = 0;
        end
        STATE_001: begin
            if (x == 0) next_state = STATE_001;
            else next_state = STATE_100;
            z = 0;
        end
        STATE_010: begin
            if (x == 0) next_state = STATE_010;
            else next_state = STATE_001;
            z = 0;
        end
        STATE_011: begin
            if (x == 0) next_state = STATE_001;
            else next_state = STATE_010;
            z = 1;
        end
        STATE_100: begin
            if (x == 0) next_state = STATE_011;
            else next_state = STATE_100;
            z = 1;
        end
        default: begin
            next_state = STATE_000;
            z = 0;
        end
    endcase
end

endmodule
