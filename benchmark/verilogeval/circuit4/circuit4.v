module TopModule (
  input a,
  input b,
  input c,
  input d,
  output q
);

  wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11;

  assign w1 = ~a;
  assign w2 = ~b;
  assign w3 = ~c;
  assign w4 = ~d;
  assign w5 = w1 & w2;
  assign w6 = w3 & w4;
  assign w7 = w5 | w6;
  assign w8 = w1 & w3;
  assign w9 = w2 | w4;
  assign w10 = w8 & w9;
  assign w11 = w7 | w10;
  assign q = w11;

endmodule

