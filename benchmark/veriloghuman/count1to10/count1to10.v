
module top_module(
    input clk,
    input reset,
    output reg [3:0] q
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= 4'b0001; // Reset to 1 (binary 0001)
    end else begin
        if (q == 4'b1010) begin // Check if the counter has reached 10 (binary 1010)
            q <= 4'b0001; // Reset to 1
        end else begin
            q <= q + 1; // Increment the counter
        end
    end
end

endmodule
