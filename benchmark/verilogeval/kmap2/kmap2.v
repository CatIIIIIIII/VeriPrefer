module TopModule (
  input a,
  input b,
  input c,
  input d,
  output out
);

  wire[3:0] f;
  assign f[0] = ~a & ~b & ~c & ~d;
  assign f[1] = ~a & ~b & ~c & d;
  assign f[2] = ~a & ~b & c & d;
  assign f[3] = ~a & b & ~c & ~d;
  assign f[4] = ~a & b & ~c & d;
  assign f[5] = ~a & b & c & d;
  assign f[6] = a & b & c & ~d;
  assign f[7] = a & b & c & d;

  assign out = ~|f;

endmodule

