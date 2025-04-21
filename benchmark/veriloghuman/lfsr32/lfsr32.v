
module top_module(
    input clk,
    input reset,
    output reg [31:0] q
);

    // Define the taps for the Galois LFSR
    parameter TAP_1 = 31; // Bit position 32 (0-based index)
    parameter TAP_2 = 21; // Bit position 22 (0-based index)
    parameter TAP_3 = 1;  // Bit position 2 (0-based index)
    parameter TAP_4 = 0;  // Bit position 1 (0-based index)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the LFSR to the initial value 32'h1
            q <= 32'h1;
        end else begin
            // Calculate the feedback bit using XOR of the tapped bits
            reg feedback_bit;
            feedback_bit = q[TAP_1] ^ q[TAP_2] ^ q[TAP_3] ^ q[TAP_4];

            // Shift the register to the right and insert the feedback bit at the MSB
            q <= {feedback_bit, q[31:1]};
        end
    end

endmodule
