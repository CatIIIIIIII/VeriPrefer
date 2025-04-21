module pe(
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] c
);

    // Temporary wire to store multiplication result
    wire [63:0] mult_result;

    // Multiply input operands
    assign mult_result = a * b;

    // Always block for synchronous operations
    always @(posedge clk or posedge rst) begin
        // Check if reset is active high
        if (rst) begin
            // Reset the accumulator register to 0
            c <= 32'b0;
        end
        else begin
            // Accumulate the multiplication result
            // Truncate the multiplication result to 32 bits
            c <= c + mult_result[31:0];
        end
    end

endmodule