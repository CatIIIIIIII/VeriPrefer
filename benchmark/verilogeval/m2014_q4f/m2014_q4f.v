module TopModule (
  input in1,
  input in2,
  output logic out
);

  wire w1;

  assign w1 = in1 & in2;

  assign out = w1;

endmodule

