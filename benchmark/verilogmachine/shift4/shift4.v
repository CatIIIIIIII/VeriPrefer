
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
        q <= 4'b0000; // Set the register to 0 on asynchronous reset
    end else if (load) begin
        q <= data; // Load the data input into the register
    end else if (ena) begin
        q <= {q[2:0], 1'b0}; // Shift the register left by 1 bit
    end
    // If none of the signals are active, the register remains unchanged
end

endmodule
