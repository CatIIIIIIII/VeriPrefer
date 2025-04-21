
module top_module (
    input c,
    input d,
    output [3:0] mux_in
);

    // Outputs for each ab combination
    wire out_ab00;
    wire out_ab01;
    wire out_ab11;
    wire out_ab10;

    // 2-to-1 multiplexers for each ab combination
    assign out_ab00 = (c & ~d); // 1 if cd = 10
    assign out_ab01 = (c | d);  // 1 if cd = 01 or cd = 11
    assign out_ab11 = (~c | d); // 1 if cd = 00 or cd = 11
    assign out_ab10 = (~c & ~d); // 1 if cd = 00 or cd = 10

    // Assign the outputs to the mux_in array
    assign mux_in[0] = out_ab00;
    assign mux_in[1] = out_ab01;
    assign mux_in[2] = out_ab11;
    assign mux_in[3] = out_ab10;

endmodule
