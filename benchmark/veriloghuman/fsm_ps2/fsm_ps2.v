
module top_module (
    input clk,
    input [7:0] in,
    input reset,
    output reg done
);

    // Define states
    typedef enum reg [1:0] {
        IDLE,
        BYTE1,
        BYTE2
    } state_t;

    // State register
    reg [1:0] state;

    // Internal signals
    reg [1:0] byte_count;

    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            byte_count <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (in[3] == 1) begin
                        state <= BYTE1;
                        byte_count <= 1;
                        done <= 0;
                    end
                end
                BYTE1: begin
                    if (byte_count == 1) begin
                        if (in[3] == 1) begin
                            state <= BYTE1;
                            byte_count <= 1;
                            done <= 0;
                        end else begin
                            state <= BYTE2;
                            byte_count <= 2;
                            done <= 0;
                        end
                    end else begin
                        state <= IDLE;
                        byte_count <= 0;
                        done <= 0;
                    end
                end
                BYTE2: begin
                    if (byte_count == 2) begin
                        if (in[3] == 1) begin
                            state <= BYTE1;
                            byte_count <= 1;
                            done <= 0;
                        end else begin
                            state <= IDLE;
                            byte_count <= 0;
                            done <= 1; // Signal done after receiving the third byte
                        end
                    end else begin
                        state <= IDLE;
                        byte_count <= 0;
                        done <= 0;
                    end
                end
                default: begin
                    state <= IDLE;
                    byte_count <= 0;
                    done <= 0;
                end
            endcase
        end
    end

endmodule
