module TopModule (
  input c,
  input d,
  output [3:0] mux_in
);

  wire a, b;

  assign mux_in = {d, c, c, d};

endmodule

