
module top_module (
    input [4:1] x,
    output logic f
);
    // Simplified Boolean expression
    assign f = x[3];
endmodule
