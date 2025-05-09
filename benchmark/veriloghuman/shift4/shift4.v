
module top_module(
    input clk,
    input areset,
    input load,
    input ena,
    input [3:0] data,
    output reg [3:0] q
);

always @(posedge clk or posedge areset) begin
    if (areset) begin
        q <= 4'b0000;  // Reset shift register to zero
    end else if (load) begin
        q <= data;    // Load shift register with data[3:0]
    end else if (ena) begin
        q <= {1'b0, q[3:1]};  // Shift right (q[3] becomes zero, q[0] is shifted out)
    end
end

endmodule
