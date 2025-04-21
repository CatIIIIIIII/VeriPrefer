
module top_module (
	input clk,
	input x,
	output z
);

// Define the 3-bit register s with initial value 0
reg [2:0] s = 3'b000;

// Always block to update the register s on the rising edge of clk
always @(posedge clk) begin
	// Statement 1: Update the MSB of s
	s[2] <= x ^ s[2];
	s[0] <= x;

	// Statement 2: Update the middle bit of s
	s[1] <= ~s[1] & x;

	// Statement 3: Update the LSB of s
	s[0] <= ~s[0] | x;
end

// Assign output z
assign z = ~(s[2] | s[1] | s[0]);

endmodule
