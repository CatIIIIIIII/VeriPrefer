
module top_module (
	input in1,
	input in2,
	input in3,
	output logic out
);

// Calculate the XOR of in1 and in2
logic xor_result;
xor_result = in1 ^ in2;

// Perform NOT operation on the XOR result
logic not_result;
not_result = ~xor_result;

// Calculate the final output by XORing the NOT result with in3
out = not_result ^ in3;

endmodule
