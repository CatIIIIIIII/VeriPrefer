module TopModule (
  input clock,
  input a,
  output reg p,
  output reg q
);

  reg d1, d2;

  always @(posedge clock) begin
    d1 <= a;
    d2 <= d1;
    p <= d2;
    q <= p;
  end

endmodule

