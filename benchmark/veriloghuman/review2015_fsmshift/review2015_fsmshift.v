
module top_module(
    input clk,
    input reset,
    output reg shift_ena
);

    // Define the states
    typedef enum reg [1:0] {
        IDLE,
        COUNT_1,
        COUNT_2,
        COUNT_3,
        COUNT_4
    } state_t;

    // State register
    state_t state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (reset) begin
                    next_state = COUNT_1;
                end
            end
            COUNT_1: next_state = COUNT_2;
            COUNT_2: next_state = COUNT_3;
            COUNT_3: next_state = COUNT_4;
            COUNT_4: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(*) begin
        case (state)
            IDLE: shift_ena = 0;
            COUNT_1: shift_ena = 1;
            COUNT_2: shift_ena = 1;
            COUNT_3: shift_ena = 1;
            COUNT_4: shift_ena = 1;
            default: shift_ena = 0;
        endcase
    end

endmodule
