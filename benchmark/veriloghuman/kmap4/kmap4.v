
module top_module (
    input a, 
    input b,
    input c,
    input d,
    output reg out
);

always @(*) begin
    // Calculate the XOR for the groups
    reg group1 = b ^ d;
    reg group2 = a ^ c;
    
    // The output is the OR of the two groups
    out = group1 | group2;
end

endmodule
