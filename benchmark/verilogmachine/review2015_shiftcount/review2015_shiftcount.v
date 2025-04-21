
module top_module(
    input clk,
    input shift_ena,
    input count_ena,
    input data,
    output reg [3:0] q
);

always @(posedge clk) begin
    if (shift_ena) begin
        // Shift data into the register
        q <= {data, q[3:1]};
    end else if (count_ena) begin
        // Decrement the register
        q <= q - 1;
    end
    // If both enable signals are low, the register remains unchanged
end

endmodule
