
module top_module(
    input a, 
    input b,
    input c,
    output out
);
    // Perform the OR operation on inputs a, b, and c
    assign out = a | b | c;
endmodule
