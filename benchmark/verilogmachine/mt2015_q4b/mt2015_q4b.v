
module top_module(
    input x,
    input y,
    output z
);

    // Calculate the XOR of x and y
    wire xor_result = x ^ y;
    
    // The output z is the logical negation of the XOR result
    assign z = ~xor_result;

endmodule
