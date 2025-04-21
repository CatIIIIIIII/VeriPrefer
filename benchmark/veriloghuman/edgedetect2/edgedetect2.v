
module top_module(
    input clk,
    input [7:0] in,
    output reg [7:0] anyedge
);

    reg [7:0] prev_in;

    always @(posedge clk) begin
        prev_in <= in;  // Store the previous input value
        anyedge <= in ^ prev_in;  // Detect any edge by XORing the current and previous inputs
    end

endmodule
