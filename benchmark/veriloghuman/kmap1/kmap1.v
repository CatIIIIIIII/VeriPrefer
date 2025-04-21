
module top_module(
    input a, 
    input b,
    input c,
    output out
);
    // Boolean expression derived from the Karnaugh map
    assign out = ~(a & b & c);
endmodule
