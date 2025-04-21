
module top_module (
    input [7:0] a,
    input [7:0] b,
    output [7:0] s,
    output overflow
);

    // Perform the addition
    assign s = a + b;

    // Detect overflow
    // Overflow occurs if the sign of the result is different from the sign of both operands
    // This can be detected by checking if the carry into the sign bit is different from the carry out of the sign bit
    assign overflow = (a[7] & b[7] & ~s[7]) | (~a[7] & ~b[7] & s[7]);

endmodule
