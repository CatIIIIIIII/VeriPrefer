module TopModule (
  input a,
  input b,
  input c,
  input d,
  output q
);

  wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10;

  assign w1 = ~a | ~d;
  assign w2 = ~b | ~c;
  assign w3 = ~w1 | ~w2;
  assign w4 = ~w3 | ~c;
  assign w5 = ~w4 | ~d;
  assign w6 = ~b | ~w5;
  assign w7 = ~w6 | ~w1;
  assign w8 = ~w7 | w2;
  assign w9 = ~w8 | w1;
  assign w10 = ~w9 | w2;

  assign q = w10;

endmodule

