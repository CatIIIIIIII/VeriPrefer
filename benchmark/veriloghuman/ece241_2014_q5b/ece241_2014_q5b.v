
module top_module (
	input clk,
	input areset,
	input x,
	output reg z
);

// Define the states using one-hot encoding
reg [1:0] state, next_state;

// State encoding:
// 00 - State A
// 01 - State B

// State transition logic
always @(posedge clk or posedge areset) begin
    if (areset) begin
        state <= 2'b00; // Reset to State A
    end else begin
        state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (state)
        2'b00: begin // State A
            if (x == 0) begin
                next_state = 2'b00; // Stay in State A
                z = 0;
            end else begin
                next_state = 2'b01; // Transition to State B
                z = 1;
            end
        end
        2'b01: begin // State B
            if (x == 0) begin
                next_state = 2'b01; // Stay in State B
                z = 1;
            end else begin
                next_state = 2'b01; // Stay in State B
                z = 0;
            end
        end
        default: begin
            next_state = 2'b00; // Default to State A
            z = 0;
        end
    endcase
end

endmodule
