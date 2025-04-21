
module top_module(
    input clk,
    input reset,
    input [31:0] in,
    output reg [31:0] out
);

reg [31:0] prev_in;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        out <= 32'b0;
        prev_in <= 32'b0;
    end else begin
        out <= (prev_in & ~in); // Capture changes from 1 to 0
        prev_in <= in; // Update previous input
    end
end

endmodule
