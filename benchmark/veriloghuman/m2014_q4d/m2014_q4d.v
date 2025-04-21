
module top_module (
	input clk,
	input in,
	output logic out
);

// Internal signal to hold the XOR result
logic xor_result;

// XOR gate
assign xor_result = in ^ out;

// D flip-flop
always_ff @(posedge clk) begin
    out <= xor_result;
end

endmodule
