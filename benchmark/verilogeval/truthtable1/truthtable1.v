module TopModule (
  input x3,
  input x2,
  input x1,
  output f
);

  wire n1, n2, n3, n4, n5;

  assign n1 = ~x3 & ~x2 & x1;
  assign n2 = ~x3 & x2 & ~x1;
  assign n3 = x3 & ~x2 & ~x1;
  assign n4 = x3 & x2 & x1;
  assign n5 = n1 | n2 | n3 | n4;

  assign f = n5;

endmodule

