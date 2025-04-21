
module top_module (
    input clk,
    input areset,
    input bump_left,
    input bump_right,
    input ground,
    output reg walk_left,
    output reg walk_right,
    output reg aaah
);

    // Define states
    typedef enum reg [1:0] {
        WALK_LEFT,
        WALK_RIGHT,
        FALL
    } state_t;

    // State register
    reg [1:0] state, next_state;

    // State transition logic
    always @(posedge clk or posedge areset) begin
        if (areset)
            state <= WALK_LEFT;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (state)
            WALK_LEFT: begin
                if (bump_left || bump_right)
                    next_state = WALK_RIGHT;
                else if (!ground)
                    next_state = FALL;
                else
                    next_state = WALK_LEFT;
            end

            WALK_RIGHT: begin
                if (bump_left || bump_right)
                    next_state = WALK_LEFT;
                else if (!ground)
                    next_state = FALL;
                else
                    next_state = WALK_RIGHT;
            end

            FALL: begin
                if (ground)
                    next_state = (state == WALK_LEFT) ? WALK_LEFT : WALK_RIGHT;
                else
                    next_state = FALL;
            end

            default: next_state = WALK_LEFT;
        endcase
    end

    // Output logic
    always @(*) begin
        walk_left = 0;
        walk_right = 0;
        aaah = 0;

        case (state)
            WALK_LEFT: walk_left = 1;
            WALK_RIGHT: walk_right = 1;
            FALL: aaah = 1;
        endcase
    end

endmodule
