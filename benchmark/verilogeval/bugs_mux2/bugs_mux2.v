module TopModule (
  input sel,
  input [7:0] a,
  input [7:0] b,
  output reg [7:0] out
);

  always @(*) begin
      out = (~sel) ? a : b;
  end

endmodule

