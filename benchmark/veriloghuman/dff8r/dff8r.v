
module top_module(
    input clk,
    input [7:0] d,
    input reset,
    output reg [7:0] q
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= 8'b00000000; // Set all outputs to zero on reset
    end else begin
        q <= d; // Load the input data into the flip-flops
    end
end

endmodule
