module TopModule (
  input mode,
  input too_cold,
  input too_hot,
  input fan_on,
  output heater,
  output aircon,
  output fan
);

  wire w1, w2, w3, w4, w5, w6;

  assign w1 = mode & too_cold & ~fan_on;
  assign w2 = mode & too_cold & fan_on;
  assign w3 = ~mode & too_hot & ~fan_on;
  assign w4 = ~mode & too_hot & fan_on;
  assign w5 = ~mode & ~too_hot & ~too_cold & ~fan_on;
  assign w6 = ~mode & ~too_hot & ~too_cold & fan_on;

  assign heater = w1 | w2;
  assign aircon = w3 | w4;
  assign fan = w1 | w2 | w3 | w4 | w5 | w6;

endmodule

