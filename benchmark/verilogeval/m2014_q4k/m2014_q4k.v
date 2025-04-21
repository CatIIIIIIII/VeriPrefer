module TopModule (
  input clk,
  input resetn,
  input in,
  output out
);

  reg d1, d2, d3, d4;

  always @(posedge clk) begin
    if (!resetn) begin
      d1 <= 1'b0;
      d2 <= 1'b0;
      d3 <= 1'b0;
      d4 <= 1'b0;
    end else begin
      d1 <= in;
      d2 <= d1;
      d3 <= d2;
      d4 <= d3;
    end
  end

  assign out = d4;

endmodule

