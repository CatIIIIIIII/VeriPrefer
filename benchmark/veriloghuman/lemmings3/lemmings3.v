
module top_module (
    input clk,
    input areset,
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging
);

    // Define states
    typedef enum reg [2:0] {
        WALK_LEFT,
        WALK_RIGHT,
        FALL,
        DIG_LEFT,
        DIG_RIGHT
    } state_t;

    state_t current_state, next_state;

    // State register
    always @(posedge clk or posedge areset) begin
        if (areset)
            current_state <= WALK_LEFT;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            WALK_LEFT: begin
                if (bump_left)
                    next_state = WALK_RIGHT;
                else if (bump_right)
                    next_state = WALK_LEFT;
                else if (!ground)
                    next_state = FALL;
                else if (dig)
                    next_state = DIG_LEFT;
            end
            WALK_RIGHT: begin
                if (bump_left)
                    next_state = WALK_RIGHT;
                else if (bump_right)
                    next_state = WALK_LEFT;
                else if (!ground)
                    next_state = FALL;
                else if (dig)
                    next_state = DIG_RIGHT;
            end
            FALL: begin
                if (ground)
                    next_state = (current_state == DIG_LEFT) ? WALK_RIGHT : WALK_LEFT;
            end
            DIG_LEFT: begin
                if (!ground)
                    next_state = FALL;
                else if (ground && !dig)
                    next_state = WALK_LEFT;
            end
            DIG_RIGHT: begin
                if (!ground)
                    next_state = FALL;
                else if (ground && !dig)
                    next_state = WALK_RIGHT;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        walk_left = 0;
        walk_right = 0;
        aaah = 0;
        digging = 0;

        case (current_state)
            WALK_LEFT: walk_left = 1;
            WALK_RIGHT: walk_right = 1;
            FALL: aaah = 1;
            DIG_LEFT: digging = 1;
            DIG_RIGHT: digging = 1;
        endcase
    end

endmodule
