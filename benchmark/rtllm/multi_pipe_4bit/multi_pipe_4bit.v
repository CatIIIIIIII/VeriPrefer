multi_pipe_4bit #(.size(4)) multiplier_inst (
    .clk(clk),
    .rst_n(reset),
    .mul_a(4'b1010),  // Multiplicand
    .mul_b(4'b0011),  // Multiplier
    .mul_out()        // 8-bit product
);