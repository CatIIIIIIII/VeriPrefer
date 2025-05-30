module TopModule (
  input clk,
  input a,
  output reg [2:0] q
);

  always @(posedge clk) begin
    if (a == 1'b1) begin
      q <= q + 1'b1;
    end
  end

endmodule

