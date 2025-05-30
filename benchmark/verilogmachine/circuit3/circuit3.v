
module top_module (
    input a, 
    input b, 
    input c, 
    input d,
    output q
);
    // Intermediate signals for the OR operations
    wire or_ab;
    wire or_cd;

    // Bitwise OR of inputs a and b
    assign or_ab = a | b;

    // Bitwise OR of inputs c and d
    assign or_cd = c | d;

    // Bitwise AND of the two OR results
    assign q = or_ab & or_cd;
endmodule
