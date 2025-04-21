
module top_module (
    input clk,
    input aresetn,
    input x,
    output reg z
);

    // Define the states
    typedef enum reg [2:0] { S, S1, S10 } state_t;
    state_t state, next_state;

    // State transition logic
    always @(posedge clk or negedge aresetn) begin
        if (!aresetn) begin
            state <= S;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            S: begin
                if (x == 0) begin
                    next_state = S;
                end else begin
                    next_state = S1;
                end
            end
            S1: begin
                if (x == 0) begin
                    next_state = S10;
                end else begin
                    next_state = S1;
                end
            end
            S10: begin
                if (x == 0) begin
                    next_state = S;
                end else begin
                    next_state = S1;
                end
            end
            default: next_state = S;
        endcase
    end

    // Output logic
    always @(*) begin
        case (state)
            S, S1: z = 0;
            S10: z = x;
            default: z = 0;
        endcase
    end

endmodule
