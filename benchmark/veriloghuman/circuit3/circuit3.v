module top_module (
	input a, 
	input b, 
	input c, 
	input d,
	output q
);


q = d | (c & ~d) | (b & c & ~d);
