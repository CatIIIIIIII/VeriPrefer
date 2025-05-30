
module top_module (
	input [99:0] in,
	output [98:0] out_both,
	output [99:1] out_any,
	output [99:0] out_different
);

// Generate out_both
genvar i;
generate
	for (i = 0; i < 99; i = i + 1) begin : gen_out_both
		assign out_both[i] = in[i] & in[i + 1];
	end
endgenerate

// Generate out_any
generate
	for (i = 0; i < 99; i = i + 1) begin : gen_out_any
		assign out_any[i + 1] = in[i] | in[i + 1];
	end
endgenerate

// Generate out_different
generate
	for (i = 0; i < 99; i = i + 1) begin : gen_out_different
		assign out_different[i] = in[i] ^ in[i + 1];
	end
	assign out_different[99] = in[99] ^ in[0]; // Wrap around for the last bit
endgenerate

endmodule
