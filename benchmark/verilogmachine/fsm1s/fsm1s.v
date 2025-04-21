
module top_module (
	input clk,
	input in,
	input reset,
	output reg out
);

// Define the states
parameter A = 1'b0;
parameter B = 1'b1;

// Register to store the current state
reg state;

// Combinational logic to determine the next state
always @(*) begin
    case (state)
        A: begin
            if (in)
                state = A;
            else
                state = B;
        end
        B: begin
            if (in)
                state = B;
            else
                state = A;
        end
        default: state = B; // Default state is B
    endcase
end

// Sequential logic to update the state register
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= B; // Reset to initial state B
    else
        state <= state; // Update to the next state
end

// Assign the output based on the current state
assign out = state;

endmodule
