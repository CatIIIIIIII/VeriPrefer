module TopModule (
  input clk,
  input x,
  output z
);

  wire d0, d1, d2; 
  reg q0, q1, q2; 
  wire n0, n1, n2; 

  assign d0 = x ^ q0; 
  assign d1 = x & ~q1; 
  assign d2 = x | ~q2; 

  always @(posedge clk) begin
    q0 <= d0;
    q1 <= d1;
    q2 <= d2;
  end

  assign n0 = ~(q0 | q1);
  assign n1 = ~(q0 & q2);
  assign n2 = ~(q0 ^ q1);
  assign z = ~(n0 & n1 & n2);

endmodule

