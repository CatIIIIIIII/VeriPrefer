module TopModule (
  input clk,
  input d,
  output reg q
);

  reg q_bar;

  always @(posedge clk) begin
    q <= d;
    q_bar <= ~d;
  end

  always @(negedge clk) begin
    q <= q_bar;
  end

endmodule

