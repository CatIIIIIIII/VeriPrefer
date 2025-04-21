
module top_module(
    input clk,
    input [7:0] in,
    output reg [7:0] pedge
);

    reg [7:0] prev_in; // Register to store the previous state of the input

    always @(posedge clk) begin
        prev_in <= in; // Update the previous state with the current state
        pedge <= 8'b0; // Initialize the output to 0

        // Detect positive edges for each bit
        for (int i = 0; i < 8; i = i + 1) begin
            if (prev_in[i] == 1'b0 && in[i] == 1'b1) begin
                pedge[i] <= 1'b1; // Set the output bit if a positive edge is detected
            end
        end
    end

endmodule
