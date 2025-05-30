
module top_module (
	input clk,
	input reset,
	input w,
	output reg z
);

// Define state codes
parameter [2:0] A = 3'b000;
parameter [2:0] B = 3'b001;
parameter [2:0] C = 3'b010;
parameter [2:0] D = 3'b011;
parameter [2:0] E = 3'b100;
parameter [2:0] F = 3'b101;

// State register
reg [2:0] current_state, next_state;

// State transition logic
always @(*) begin
    case (current_state)
        A: begin
            if (w == 1'b1)
                next_state = B;
            else
                next_state = A;
        end
        B: begin
            if (w == 1'b1)
                next_state = C;
            else
                next_state = D;
        end
        C: begin
            if (w == 1'b1)
                next_state = E;
            else
                next_state = D;
        end
        D: begin
            if (w == 1'b1)
                next_state = F;
            else
                next_state = A;
        end
        E: begin
            if (w == 1'b1)
                next_state = E;
            else
                next_state = D;
        end
        F: begin
            if (w == 1'b1)
                next_state = C;
            else
                next_state = D;
        end
        default: next_state = A;
    endcase
end

// State flip-flops
always @(posedge clk or posedge reset) begin
    if (reset)
        current_state <= A;
    else
        current_state <= next_state;
end

// Output logic
always @(*) begin
    case (current_state)
        A: z = 1'b0;
        B: z = 1'b0;
        C: z = 1'b0;
        D: z = 1'b0;
        E: z = 1'b1;
        F: z = 1'b0;
        default: z = 1'b0;
    endcase
end

endmodule
