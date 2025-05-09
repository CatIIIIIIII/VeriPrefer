
module top_module(
    input [2:0] vec, 
    output [2:0] outv,
    output o2,
    output o1,
    output o0
);

    // Assign the 3-bit input vector to the 3-bit output vector
    assign outv = vec;

    // Split the 3-bit input vector into three separate 1-bit outputs
    assign o2 = vec[2];
    assign o1 = vec[1];
    assign o0 = vec[0];

endmodule
