module TopModule (
  input a,
  input b,
  input c,
  output out
);

  assign out = ~b & ~c | ~b & c | a & b & ~c | a & b & c;

endmodule

