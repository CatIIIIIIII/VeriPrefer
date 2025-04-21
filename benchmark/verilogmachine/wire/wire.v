
module top_module(
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal
    output reg [7:0] data_out, // Data output
    output reg valid_out     // Valid output
);

    // Internal signals
    reg [1:0] state;        // State signal (2 bits for 4 states: 00, 01, 10, 11)
    reg [7:0] counter;      // Counter signal (8 bits)

    // State definitions
    parameter IDLE = 2'b00;
    parameter WAIT = 2'b01;
    parameter PROCESS = 2'b10;
    parameter DONE = 2'b11;

    // State machine logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            counter <= 8'b0;
            data_out <= 8'b0;
            valid_out <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    counter <= 8'b0;
                    data_out <= 8'b0;
                    valid_out <= 1'b0;
                    if (clk) begin
                        state <= WAIT;
                    end
                end
                WAIT: begin
                    counter <= counter + 1;
                    data_out <= 8'b0;
                    if (counter == 100) begin // Threshold value for counter
                        state <= PROCESS;
                    end
                end
                PROCESS: begin
                    data_out <= in; // Assuming 'in' is the data to be processed
                    state <= DONE;
                end
                DONE: begin
                    valid_out <= 1'b1;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
