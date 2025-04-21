
module top_module (
	input clk,
	input areset,
	input bump_left,
	input bump_right,
	output walk_left,
	output walk_right
);

// Define the states
parameter WL = 2'b00; // Walk Left
parameter WR = 2'b01; // Walk Right

// State register
reg [1:0] state;

// Next state logic
always @(*) begin
    case (state)
        WL: begin
            if (bump_left)
                state = WR;
            else
                state = WL;
        end
        WR: begin
            if (bump_right)
                state = WL;
            else
                state = WR;
        end
        default: state = WL; // Default state
    endcase
end

// State transition on rising edge of clk
always @(posedge clk or posedge areset) begin
    if (areset)
        state <= WL; // Reset to initial state
    else
        state <= state; // Hold current state
end

// Output logic
always @(*) begin
    case (state)
        WL: begin
            walk_left = 1'b1;
            walk_right = 1'b0;
        end
        WR: begin
            walk_left = 1'b0;
            walk_right = 1'b1;
        end
        default: begin
            walk_left = 1'b0;
            walk_right = 1'b0;
        end
    endcase
end

endmodule
