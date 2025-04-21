
module top_module (
    input clk,
    input aresetn,
    input x,
    output reg z
);

    // Define the states
    typedef enum reg [1:0] {
        S0, // Initial state
        S1, // State after detecting '1'
        S2  // State after detecting '10'
    } state_t;

    // State register
    reg [1:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or negedge aresetn) begin
        if (!aresetn) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            S0: begin
                if (x == 1'b1) begin
                    next_state = S1;
                end else begin
                    next_state = S0;
                end
            end
            S1: begin
                if (x == 1'b0) begin
                    next_state = S2;
                end else begin
                    next_state = S1;
                end
            end
            S2: begin
                if (x == 1'b1) begin
                    next_state = S1;
                end else begin
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
        case (current_state)
            S0, S1, S2: begin
                z = 1'b0;
            end
            default: begin
                z = 1'b0;
            end
        endcase
    end

    // Detect the sequence "101" and assert z
    always @(posedge clk or negedge aresetn) begin
        if (!aresetn) begin
            z <= 1'b0;
        end else if (current_state == S2 && x == 1'b1) begin
            z <= 1'b1;
        end else begin
            z <= 1'b0;
        end
    end

endmodule
