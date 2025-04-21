
module multi_booth_8bit (p, rdy, clk, reset, a, b);
   input clk, reset;
   input [7:0] a, b;
   output [15:0] p;
   output rdy;
   reg [15:0] multiplier, multiplicand, product;
   reg [4:0]  ctr;
   reg 	     rdy;

   output [15:0] p;

   assign p = product;

   always @(posedge clk or posedge reset) begin
      if (reset) begin
	 multiplier <= {{8{a[7]}}, a};
	 multiplicand <= {{8{b[7]}}, b};
	 product <= 0;
	 ctr <= 0;
	 rdy <= 0;
      end
      else begin
	 if (ctr < 16) begin
	    multiplicand <= multiplicand << 1;
	    if (multiplier[ctr]) 
	      product <= product + multiplicand;
	    ctr <= ctr + 1;
	 end
	 else begin
	    rdy <= 1;
	 end
      end 
   end 
endmodule