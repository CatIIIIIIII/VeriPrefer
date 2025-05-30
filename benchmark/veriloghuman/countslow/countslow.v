
module top_module(
    input clk,
    input slowena,
    input reset,
    output reg [3:0] q
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= 4'b0000; // Reset the counter to 0
    end else if (slowena) begin
        if (q == 4'b1001) begin
            q <= 4'b0000; // Wrap around to 0 after 9
        end else begin
            q <= q + 1; // Increment the counter
        end
    end
end

endmodule
