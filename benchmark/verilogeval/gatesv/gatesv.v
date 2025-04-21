module TopModule (
  input  [3:0] in,
  output [3:0] out_both,
  output [3:0] out_any,
  output [3:0] out_different
);

  assign out_both[3:1] = in[3:1] & in[2:0];
  assign out_both[0] = in[0] & in[3];

  assign out_any[3:1] = in[3:1] | in[2:0];
  assign out_any[0] = in[0] | in[3];

  assign out_different[3:1] = in[3:1] ^ in[2:0];
  assign out_different[0] = in[0] ^ in[3];

endmodule

