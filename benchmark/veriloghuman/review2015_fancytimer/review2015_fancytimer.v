
module top_module(
    input wire clk,
    input wire reset,
    input wire data,
    output reg [3:0] count,
    output reg counting,
    output reg done,
    input wire ack
);

    // State definitions
    typedef enum reg [2:0] {
        IDLE,
        SEARCHING,
        READING_DELAY,
        COUNTING,
        WAITING_FOR_ACK
    } state_t;

    state_t state, next_state;

    // Internal registers
    reg [3:0] delay;
    reg [11:0] counter; // 12-bit counter for 1000 clock cycles

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
                if (data == 1'b1) begin
                    next_state = SEARCHING;
                end
            end
            SEARCHING: begin
                if (data == 1'b1) begin
                    next_state = SEARCHING;
                end else if (data == 1'b0) begin
                    next_state = SEARCHING;
                end else if (data == 1'b1) begin
                    next_state = SEARCHING;
                end else if (data == 1'b0) begin
                    next_state = READING_DELAY;
                end
            end
            READING_DELAY: begin
                next_state = COUNTING;
            end
            COUNTING: begin
                if (counter == 0) begin
                    next_state = WAITING_FOR_ACK;
                end
            end
            WAITING_FOR_ACK: begin
                if (ack) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counting <= 0;
            done <= 0;
            count <= 4'b0000;
            delay <= 4'b0000;
            counter <= 12'b000000000000;
        end else begin
            case (state)
                IDLE: begin
                    counting <= 0;
                    done <= 0;
                    count <= 4'b0000;
                    delay <= 4'b0000;
                    counter <= 12'b000000000000;
                end
                SEARCHING: begin
                    counting <= 0;
                    done <= 0;
                    count <= 4'b0000;
                    delay <= 4'b0000;
                    counter <= 12'b000000000000;
                end
                READING_DELAY: begin
                    delay <= {delay[2:0], data};
                    counting <= 0;
                    done <= 0;
                    count <= 4'b0000;
                    counter <= 12'b000000000000;
                end
                COUNTING: begin
                    counting <= 1;
                    done <= 0;
                    count <= counter[11:8];
                    if (counter > 0) begin
                        counter <= counter - 1;
                    end
                end
                WAITING_FOR_ACK: begin
                    counting <= 0;
                    done <= 1;
                    count <= 4'b0000;
                    counter <= 12'b000000000000;
                end
            endcase
        end
    end

endmodule
