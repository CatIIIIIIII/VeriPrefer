module TopModule (
  input  [5:0] y,
  input        w,
  output       Y1,
  output       Y3
);

  wire Y2;
  wire Y4;

  assign Y1 = y[0] | (y[3] & w);
  assign Y3 = (y[1] & w) | (y[2] & w) | (y[4] & w) | (y[5] & w);
  assign Y2 = y[1];
  assign Y4 = y[3];

endmodule

