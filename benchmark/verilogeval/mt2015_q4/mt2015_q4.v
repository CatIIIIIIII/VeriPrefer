module TopModule (
  input x,
  input y,
  output z
);

  wire w1, w2, w3, w4, w5, w6;

  assign w1 = x | y;
  assign w2 = ~x & ~y;

  assign w3 = x & y;
  assign w4 = ~x | ~y;

  assign w5 = w1 | w2;
  assign w6 = w3 & w4;

  assign z = w5 ^ w6;

endmodule

