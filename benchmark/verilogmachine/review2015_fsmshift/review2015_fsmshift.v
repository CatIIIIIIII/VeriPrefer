
module top_module(
    input clk,
    input reset,
    output reg shift_ena
);

    // Define the states
    typedef enum reg [1:0] {
        B0,
        B1,
        B2,
        B3,
        DONE
    } state_t;

    // Declare the state register
    reg [1:0] state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= B0;
            shift_ena <= 0;
        end else begin
            case (state)
                B0: begin
                    state <= B1;
                    shift_ena <= 1;
                end
                B1: begin
                    state <= B2;
                    shift_ena <= 1;
                end
                B2: begin
                    state <= B3;
                    shift_ena <= 1;
                end
                B3: begin
                    state <= DONE;
                    shift_ena <= 1;
                end
                DONE: begin
                    state <= DONE;
                    shift_ena <= 0;
                end
                default: begin
                    state <= DONE;
                    shift_ena <= 0;
                end
            endcase
        end
    end

endmodule
