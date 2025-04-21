module TopModule (
  input a,
  input b,
  input c,
  input d,
  output out_sop,
  output out_pos
);

  assign out_sop = (b & c & d) | (a & b & d) | (a & b & c);

  assign out_pos = (~a | ~b | c | ~d) & (~a | ~b | ~c | ~d) & (~a | ~c | ~d) & (~b | ~c | ~d) & (~a | ~b | ~c);

endmodule

