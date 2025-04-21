
module top_module (
	input clk,
	input j,
	input k,
	input areset,
	output reg out
);

// Define the states
parameter [1:0] STATE_A = 2'b00;
parameter [1:0] STATE_B = 2'b01;

// Internal state register
reg [1:0] current_state, next_state;

// Combinational logic to determine the next state
always @(*) begin
    case (current_state)
        STATE_A: begin
            if (j)
                next_state = STATE_B;
            else
                next_state = STATE_A;
        end
        STATE_B: begin
            if (k)
                next_state = STATE_A;
            else
                next_state = STATE_B;
        end
        default: next_state = STATE_A; // Default to state A
    endcase
end

// Clocked process to update the state
always @(posedge clk or posedge areset) begin
    if (areset)
        current_state <= STATE_A;
    else
        current_state <= next_state;
end

// Output the current state
assign out = (current_state == STATE_B) ? 1'b1 : 1'b0;

endmodule
