
module top_module (
	input clk,
	input in,
	input areset,
	output reg out
);

// State encoding
parameter [1:0] B = 2'b10;
parameter [1:0] A = 2'b00;

// Internal state register
reg [1:0] current_state, next_state;

// State transition logic
always @(*) begin
    case (current_state)
        B: begin
            if (in == 1'b0)
                next_state = A;
            else
                next_state = B;
        end
        A: begin
            if (in == 1'b0)
                next_state = B;
            else
                next_state = A;
        end
        default: next_state = B; // Default state is B
    endcase
end

// State register with asynchronous reset
always @(posedge clk or posedge areset) begin
    if (areset)
        current_state <= B;
    else
        current_state <= next_state;
end

// Output logic (Moore machine, output depends only on the current state)
always @(*) begin
    case (current_state)
        B: out = 1'b1;
        A: out = 1'b0;
        default: out = 1'b1; // Default output is 1
    endcase
end

endmodule
