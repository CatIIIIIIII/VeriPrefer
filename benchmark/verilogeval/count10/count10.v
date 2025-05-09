module TopModule (
  input clk,
  input reset,
  output reg [3:0] q
);

  always @(posedge clk) begin
    if (reset) begin
      q <= 0;
    end else begin
      if (q == 9) begin
        q <= 0;
      end else begin
        q <= q + 1;
      end
    end
  end

endmodule

