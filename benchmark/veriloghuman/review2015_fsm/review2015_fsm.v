
module top_module(
    input clk,
    input reset,
    input data,
    output reg shift_ena,
    output reg counting,
    input done_counting,
    output reg done,
    input ack
);

    // Define the states
    typedef enum reg [2:0] {
        IDLE,
        SEARCH_1,
        SEARCH_11,
        SEARCH_110,
        SHIFT,
        COUNT,
        NOTIFY,
        WAIT_ACK
    } state_t;

    state_t state, next_state;

    // State register
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
                if (data == 1'b1) begin
                    next_state = SEARCH_1;
                end
            end

            SEARCH_1: begin
                if (data == 1'b1) begin
                    next_state = SEARCH_11;
                end else if (data == 1'b0) begin
                    next_state = IDLE;
                end
            end

            SEARCH_11: begin
                if (data == 1'b0) begin
                    next_state = SEARCH_110;
                end else if (data == 1'b1) begin
                    next_state = SEARCH_1;
                end else if (data == 1'b0) begin
                    next_state = IDLE;
                end
            end

            SEARCH_110: begin
                if (data == 1'b1) begin
                    next_state = SHIFT;
                end else if (data == 1'b1) begin
                    next_state = SEARCH_1;
                end else if (data == 1'b0) begin
                    next_state = IDLE;
                end
            end

            SHIFT: begin
                next_state = COUNT;
            end

            COUNT: begin
                if (done_counting) begin
                    next_state = NOTIFY;
                end
            end

            NOTIFY: begin
                if (ack) begin
                    next_state = WAIT_ACK;
                end
            end

            WAIT_ACK: begin
                if (ack) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        shift_ena = 0;
        counting = 0;
        done = 0;

        case (state)
            SHIFT: begin
                shift_ena = 1;
            end

            COUNT: begin
                counting = 1;
            end

            NOTIFY: begin
                done = 1;
            end

            default: begin
                shift_ena = 0;
                counting = 0;
                done = 0;
            end
        endcase
    end

endmodule
