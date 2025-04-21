module TopModule (
  input clk,
  input a,
  input b,
  output q,
  output state
);

  reg state_r;
  assign state = state_r;
  wire q_r = ~(a ^ state_r);
  assign q = q_r;
  always @(posedge clk) begin
    state_r <= q_r ^ b;
  end
endmodule

