module TopModule (
  input a,
  input b,
  output q
);

  wire delay_a, delay_b, delay_c;

  assign delay_a = a;
  assign delay_b = b;
  assign delay_c = delay_a & delay_b;

  assign q = delay_c;

endmodule

