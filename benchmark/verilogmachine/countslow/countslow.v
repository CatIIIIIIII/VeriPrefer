
module top_module(
    input clk,
    input slowena,
    input reset,
    output reg [3:0] q
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= 4'b0000;  // Reset the counter to 0
    end else if (slowena) begin
        if (q == 4'b1001) begin  // Check if the counter is equal to 9 (1001 in binary)
            q <= 4'b0000;  // Reset the counter to 0
        end else begin
            q <= q + 1;  // Increment the counter by 1
        end
    end
    // If slowena is not asserted, the counter does not increment
end

endmodule
