
module top_module(
    input clk,
    input a, 
    input b,
    output out_assign,
    output reg out_always_comb,
    output reg out_always_ff
);

    // Perform XOR operation and assign to out_assign
    assign out_assign = a ^ b;

    // Always block to assign the same value to out_always_comb
    always @(a or b) begin
        out_always_comb = a ^ b;
    end

    // Always block triggered on the rising edge of clk to assign to out_always_ff
    always @(posedge clk) begin
        out_always_ff = a ^ b;
    end

endmodule
