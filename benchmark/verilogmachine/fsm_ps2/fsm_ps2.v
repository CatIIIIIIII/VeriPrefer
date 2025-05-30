
module top_module (
    input clk,
    input [7:0] in,
    input reset,
    output reg done
);

    // Define the states
    typedef enum reg [1:0] {
        BYTE1,
        BYTE2,
        BYTE3,
        DONE
    } state_t;

    // State register
    reg [1:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= BYTE1;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            BYTE1: begin
                if (in[2] == 1'b1) begin
                    next_state = BYTE2;
                end else begin
                    next_state = BYTE1;
                end
            end
            BYTE2: begin
                next_state = BYTE3;
            end
            BYTE3: begin
                next_state = DONE;
            end
            DONE: begin
                if (in[2] == 1'b0) begin
                    next_state = BYTE1;
                end else begin
                    next_state = BYTE2;
                end
            end
            default: begin
                next_state = BYTE1;
            end
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 1'b0;
        end else begin
            if (current_state == DONE) begin
                done <= 1'b1;
            end else begin
                done <= 1'b0;
            end
        end
    end

endmodule
