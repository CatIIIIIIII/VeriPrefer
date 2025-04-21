module TopModule (
  input clk,
  input in,
  output logic out
);

  logic d;
  logic q;

  assign d = in ^ q;

  always @(posedge clk) begin
    q <= d;
  end

  assign out = q;

endmodule

