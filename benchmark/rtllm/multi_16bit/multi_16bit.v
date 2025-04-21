module multi_16bit(
    input clk,          // Chip clock signal.
    input rst_n,        // Active-low reset signal. Defined as 0 for chip reset; defined as 1 for reset signal inactive.
    input start,        // Chip enable signal. 
    input [15:0] ain,   // Input a (multiplicand) with a data width of 16 bits.
    input [15:0] bin,   // Input b (multiplier) with a data width of 16 bits.

    output [31:0] yout, // Product output with a data width of 32 bits.
    output done         // Chip output flag signal. Defined as 1 indicates multiplication operation completion.
);

    // Internal registers
    reg [15:0] areg;    // Multiplicand register
    reg [15:0] breg;    // Multiplier register
    reg [31:0] yout_r;  // Product register
    reg [4:0] i;        // Shift count register
    reg done_r;         // Multiplication completion flag register

    // Output assignments
    assign yout = yout_r;
    assign done = done_r;

    // Main sequential logic block
    always @(posedge clk or negedge rst_n) begin
        // Reset condition
        if (!rst_n) begin
            areg <= 16'b0;
            breg <= 16'b0;
            yout_r <= 32'b0;
            i <= 5'b0;
            done_r <= 1'b0;
        end
        else begin
            // Start multiplication process
            if (start) begin
                // Initialize registers on first cycle
                if (i == 5'b0) begin
                    areg <= ain;
                    breg <= bin;
                    yout_r <= 32'b0;
                    done_r <= 1'b0;
                end

                // Shift and accumulate
                if (i > 5'b0 && i < 5'd17) begin
                    // Check if corresponding bit in multiplicand is 1
                    if (areg[i-1'b1]) begin
                        yout_r <= yout_r + (breg << (i-1'b1));
                    end
                end

                // Increment shift count
                if (i < 5'd17) begin
                    i <= i + 1'b1;
                end

                // Set done flag when multiplication completes
                if (i == 5'd16) begin
                    done_r <= 1'b1;
                end

                // Reset done flag in the next cycle
                if (i == 5'd17) begin
                    done_r <= 1'b0;
                    i <= 5'b0;
                end
            end
            else begin
                // Reset shift count when start is low
                i <= 5'b0;
            end
        end
    end

endmodule