
module top_module (
	input a,
	input b,
	input c,
	input d,
	output out_sop,
	output out_pos
);

// SOP (Sum of Products)
assign out_sop = (~a & b & ~c & ~d) | (~a & b & c & d) | (a & b & c & d);

// POS (Product of Sums)
assign out_pos = (a | b | c | d) & (a | b | c | ~d) & (a | ~b | c | d) & (a | ~b | c | ~d) & (a | ~b | ~c | d) & (~a | b | c | ~d) & (~a | b | ~c | d) & (~a | ~b | c | ~d) & (~a | ~b | ~c | d);

endmodule
