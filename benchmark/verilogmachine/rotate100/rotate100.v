
module top_module(
    input clk,
    input load,
    input [1:0] ena,
    input [99:0] data,
    output reg [99:0] q
);

always @(posedge clk) begin
    if (load) begin
        // Load data into the output register
        q <= data;
    end else if (ena == 2'h1) begin
        // Shift left
        q <= {q[98:0], 1'b0};
    end else if (ena == 2'h2) begin
        // Shift right
        q <= {1'b0, q[99:1]};
    end
end

endmodule
