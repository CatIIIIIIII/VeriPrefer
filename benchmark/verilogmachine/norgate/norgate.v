
module top_module(
    input a, 
    input b,
    output out
);
    // Logical OR of inputs a and b
    wire or_result;
    assign or_result = a | b;
    
    // Logical negation of the OR result
    assign out = ~or_result;
endmodule
