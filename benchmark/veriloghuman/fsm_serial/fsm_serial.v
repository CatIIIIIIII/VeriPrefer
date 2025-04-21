
module top_module (
    input clk,
    input in,
    input reset,
    output reg done
);

    // Define states
    typedef enum reg [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT
    } state_t;

    state_t state, next_state;
    reg [7:0] data;
    reg [2:0] bit_count;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            data <= 8'b0;
            bit_count <= 3'b0;
            done <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    if (in == 0) begin
                        next_state <= START_BIT;
                    end else begin
                        next_state <= IDLE;
                    end
                end
                START_BIT: begin
                    if (bit_count == 3'b111) begin
                        next_state <= DATA_BITS;
                    end else begin
                        next_state <= START_BIT;
                    end
                end
                DATA_BITS: begin
                    if (bit_count == 3'b1111) begin
                        next_state <= STOP_BIT;
                    end else begin
                        next_state <= DATA_BITS;
                    end
                end
                STOP_BIT: begin
                    if (in == 1) begin
                        next_state <= IDLE;
                        done <= 1'b1;
                    end else begin
                        next_state <= STOP_BIT;
                    end
                end
                default: next_state <= IDLE;
            endcase
        end
    end

    // Bit counting and data shifting
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_count <= 3'b0;
            data <= 8'b0;
        end else begin
            case (state)
                START_BIT: begin
                    if (bit_count < 3'b111) begin
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 3'b0;
                    end
                end
                DATA_BITS: begin
                    if (bit_count < 3'b1111) begin
                        data <= {in, data[7:1]};
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 3'b0;
                    end
                end
                STOP_BIT: begin
                    bit_count <= 3'b0;
                end
                default: begin
                    bit_count <= 3'b0;
                    data <= 8'b0;
                end
            endcase
        end
    end

endmodule
