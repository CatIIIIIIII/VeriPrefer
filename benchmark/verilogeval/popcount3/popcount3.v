module TopModule (
  input [2:0] in,
  output [1:0] out
);

  wire a, b, c;
  assign a = in[0];
  assign b = in[1];
  assign c = in[2];

  assign out[0] = (a & ~b & ~c) | (~a & b & ~c) | (~a & ~b & c);
  assign out[1] = (a & b & ~c) | (a & ~b & c) | (~a & b & c);

endmodule

