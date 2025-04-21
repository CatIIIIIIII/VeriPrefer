module TopModule (
  input a,
  input b,
  input c,
  input d,
  output q
);

  wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32;

  assign w1 = a & b;
  assign w2 = c | d;
  assign w3 = w1 & w2;
  assign w4 = a ^ b;
  assign w5 = c ^ d;
  assign w6 = w4 & w5;
  assign w7 = w3 | w6;
  assign w8 = a | b;
  assign w9 = c & d;
  assign w10 = w8 & w9;
  assign w11 = a & d;
  assign w12 = b | c;
  assign w13 = w11 & w12;
  assign w14 = w10 | w13;
  assign w15 = a ^ d;
  assign w16 = b ^ c;
  assign w17 = w15 & w16;
  assign w18 = w14 | w17;
  assign w19 = a & c;
  assign w20 = b & d;
  assign w21 = w19 | w20;
  assign w22 = w18 & w21;
  assign w23 = w7 | w22;
  assign w24 = a ^ c;
  assign w25 = b ^ d;
  assign w26 = w24 & w25;
  assign w27 = w23 | w26;
  assign w28 = a | c;
  assign w29 = b | d;
  assign w30 = w28 & w29;
  assign w31 = w27 & w30;
  assign w32 = w2 | w31;

  assign q = w32;

endmodule

