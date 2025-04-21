
module top_module(
    input clk,
    input areset,
    input train_valid,
    input train_taken,
    output logic [1:0] state
);

    // Internal state register
    logic [1:0] state_reg;

    // Synchronous process to update the state
    always_ff @(posedge clk or posedge areset) begin
        if (areset) begin
            // Asynchronous reset to weakly not-taken (2'b01)
            state_reg <= 2'b01;
        end else begin
            if (train_valid) begin
                if (train_taken) begin
                    // Increment the counter, saturate at 3 (2'b11)
                    state_reg <= (state_reg == 2'b11) ? 2'b11 : state_reg + 1;
                end else begin
                    // Decrement the counter, saturate at 0 (2'b00)
                    state_reg <= (state_reg == 2'b00) ? 2'b00 : state_reg - 1;
                end
            end else begin
                // Keep the counter value unchanged
                state_reg <= state_reg;
            end
        end
    end

    // Assign the output
    assign state = state_reg;

endmodule
