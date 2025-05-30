
module top_module(
    input clk,
    input reset,
    output reg [9:0] q
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= 10'b0;  // Reset the counter to 0
    end else begin
        if (q == 10'd999) begin
            q <= 10'b0;  // Wrap around to 0 after reaching 999
        end else begin
            q <= q + 1;  // Increment the counter
        end
    end
end

endmodule
