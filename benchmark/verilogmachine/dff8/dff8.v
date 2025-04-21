
module top_module(
    input clk,
    input [7:0] d,
    output reg [7:0] q
);

    // Initial block to set the default value of the output
    initial begin
        q = 8'h0; // Set the output to 0 initially
    end

    // Always block triggered on the rising edge of the clock
    always @(posedge clk) begin
        q <= d; // Store the data input in the register
    end

endmodule
