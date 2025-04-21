
module top_module (
    input clk,
    input reset,
    input in,
    output reg disc,
    output reg flag,
    output reg err
);

    // Define states
    typedef enum reg [2:0] {
        S0, S1, S2, S3, S4, S5, S6, S7
    } state_t;

    // State register
    state_t state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            S0: begin
                if (in == 1) begin
                    next_state = S1;
                end else begin
                    next_state = S0;
                end
            end
            S1: begin
                if (in == 1) begin
                    next_state = S2;
                end else begin
                    next_state = S0;
                end
            end
            S2: begin
                if (in == 1) begin
                    next_state = S3;
                end else begin
                    next_state = S0;
                end
            end
            S3: begin
                if (in == 1) begin
                    next_state = S4;
                end else begin
                    next_state = S0;
                end
            end
            S4: begin
                if (in == 1) begin
                    next_state = S5;
                end else begin
                    next_state = S0;
                end
            end
            S5: begin
                if (in == 1) begin
                    next_state = S6;
                end else begin
                    next_state = S0;
                end
            end
            S6: begin
                if (in == 1) begin
                    next_state = S7;
                end else if (in == 0) begin
                    next_state = S0;
                end
            end
            S7: begin
                if (in == 1) begin
                    next_state = S7;
                end else if (in == 0) begin
                    next_state = S0;
                end
            end
            default: begin
                next_state = S0;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        disc = 0;
        flag = 0;
        err = 0;

        case (state)
            S6: begin
                if (in == 0) begin
                    disc = 1;
                end
            end
            S7: begin
                err = 1;
            end
            default: begin
                // No action needed for other states
            end
        endcase
    end

endmodule
