
module top_module(
    input clk,
    input d,
    output reg q
);

    // Initial block to set the initial value of the register q
    initial begin
        q = 1'hx; // Unknown or undefined value
    end

    // Always block triggered by the rising edge of the clock signal
    always @(posedge clk) begin
        q <= d; // Set the register q to the value of the data signal d
    end

endmodule
