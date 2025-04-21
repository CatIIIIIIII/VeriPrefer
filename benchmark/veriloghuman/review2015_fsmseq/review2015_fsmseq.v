
module top_module(
    input clk,
    input reset,
    input data,
    output reg start_shifting
);

    // Define the states
    typedef enum reg [2:0] {
        IDLE,      // Initial state
        S1,        // State after seeing '1'
        S11,       // State after seeing '11'
        S110,      // State after seeing '110'
        MATCH      // State after seeing '1101'
    } state_t;

    // Declare the current and next state variables
    state_t current_state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            start_shifting <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (data == 1'b1) begin
                    next_state = S1;
                end
            end
            S1: begin
                if (data == 1'b1) begin
                    next_state = S11;
                end else begin
                    next_state = IDLE;
                end
            end
            S11: begin
                if (data == 1'b0) begin
                    next_state = S110;
                end else begin
                    next_state = S1;
                end
            end
            S110: begin
                if (data == 1'b1) begin
                    next_state = MATCH;
                end else begin
                    next_state = IDLE;
                end
            end
            MATCH: begin
                // Stay in MATCH state until reset
            end
        endcase
    end

    // Output logic
    always @(*) begin
        if (current_state == MATCH) begin
            start_shifting = 1;
        end else begin
            start_shifting = 0;
        end
    end

endmodule
