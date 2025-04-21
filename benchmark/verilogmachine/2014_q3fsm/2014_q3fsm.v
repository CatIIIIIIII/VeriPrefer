
module top_module (
    input clk,
    input reset,
    input s,
    input w,
    output reg z
);

    // Define the states
    typedef enum reg [3:0] {
        A   = 4'b0000,
        B   = 4'b0001,
        C   = 4'b0010,
        S10 = 4'b0011,
        S11 = 4'b0100,
        S20 = 4'b0101,
        S21 = 4'b0110,
        S22 = 4'b0111
    } state_t;

    // Declare the current and next state
    state_t current_state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= A;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            A: begin
                if (s)
                    next_state = B;
                else
                    next_state = A;
            end
            B: begin
                if (w)
                    next_state = S11;
                else
                    next_state = S10;
            end
            C: begin
                if (w)
                    next_state = S11;
                else
                    next_state = S10;
            end
            S10: begin
                if (w)
                    next_state = S21;
                else
                    next_state = S20;
            end
            S11: begin
                if (w)
                    next_state = S22;
                else
                    next_state = S21;
            end
            S20: begin
                next_state = B;
            end
            S21: begin
                if (w)
                    next_state = C;
                else
                    next_state = B;
            end
            S22: begin
                if (w)
                    next_state = B;
                else
                    next_state = C;
            end
            default: begin
                next_state = A;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        case (current_state)
            A, B, C, S10, S11, S20, S21, S22: begin
                z = 1'b0; // Default output
            end
            default: begin
                z = 1'b0; // Default output
            end
        endcase
    end

endmodule
