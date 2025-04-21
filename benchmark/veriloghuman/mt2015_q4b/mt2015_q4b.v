
module top_module(
    input x,
    input y,
    output z
);

    // Logic to match the given waveform
    assign z = (x & y) | (~x & ~y);

endmodule
