
module top_module (
	input c,
	input d,
	output [3:0] mux_in
);

assign mux_in[0] = c | d;  // Logical OR of c and d
assign mux_in[1] = 1'b0;   // Second bit is always 0
assign mux_in[2] = ~d;     // Logical NOT of d
assign mux_in[3] = c & d;  // Logical AND of c and d

endmodule
