module TopModule (
  input  [99:0] in,
  output [99:0] out_both,
  output [99:0] out_any,
  output [99:0] out_different
);

  assign out_both[99:0] = {in[99] & in[98], in[98:1] & in[97:0]};

  assign out_any[99:0] = {in[0] | in[1], in[99:2] | in[97:0]};

  assign out_different[99:0] = {in[99] ^ in[0], in[98:0] ^ in[97:1]};

endmodule

