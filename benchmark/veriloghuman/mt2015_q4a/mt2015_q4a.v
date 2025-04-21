
module top_module(
    input x,
    input y,
    output z
);
    // Calculate the XOR of x and y
    wire xor_result = x ^ y;
    
    // Calculate the AND of xor_result and x
    assign z = xor_result & x;
endmodule
