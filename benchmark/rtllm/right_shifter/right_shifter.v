module right_shifter(
    input wire clk,     // Clock signal
    input wire d,       // Input bit to be shifted in
    output reg [7:0] q  // 8-bit output register
);

    // Initialize the register to 0 during simulation
    initial begin
        q = 8'b0;
    end

    // Synchronous right shift operation on positive clock edge
    always @(posedge clk) begin
        // Right shift the register by 1 bit
        q <= {d, q[7:1]};
    end

endmodule