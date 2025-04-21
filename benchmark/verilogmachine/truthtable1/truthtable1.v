
module top_module (
	input x3,
	input x2,
	input x1,
	output f
);

assign f = ( (~x3 & x2 & ~x1) |  // First condition
             (~x3 & x2 & x1)  |  // Second condition
             (x3 & ~x2 & x1)  |  // Third condition
             (x3 & x2 & x1) );   // Fourth condition

endmodule
