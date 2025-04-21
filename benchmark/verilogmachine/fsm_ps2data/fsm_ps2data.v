
module top_module (
    input clk,
    input [7:0] in,
    input reset,
    output reg [23:0] out_bytes,
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
    state_t current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= BYTE1;
            done <= 0;
            out_bytes <= 24'b0;
        end else begin
            current_state <= next_state;
            if (current_state == DONE) begin
                done <= 1;
                out_bytes <= out_bytes;
            end else begin
                done <= 0;
                out_bytes <= {out_bytes[15:0], in};
            end
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            BYTE1: begin
                if (in[2]) begin
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
                if (in[2]) begin
                    next_state = BYTE2;
                end else begin
                    next_state = BYTE1;
                end
            end
            default: begin
                next_state = BYTE1;
            end
        endcase
    end

endmodule
