
module top_module (
	input [254:0] in,
	output reg [7:0] out
);

always_comb begin
    // Initialize the output to 0
    out = 8'b0;
    
    // Iterate through all the bits of the input signal
    for (int i = 0; i < 255; i = i + 1) begin
        // Increment the output by the value of the corresponding bit in the input signal
        out = out + in[i];
    end
end

endmodule
