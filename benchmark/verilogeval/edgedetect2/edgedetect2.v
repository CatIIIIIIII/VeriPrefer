module TopModule (
  input clk,
  input [7:0] in,
  output reg [7:0] anyedge
);

  reg [7:0] in_ff;

  always @(posedge clk) begin
    in_ff <= in;
  end

  always @(posedge clk) begin
    anyedge <= (in & ~in_ff) | (~in & in_ff);
  end

endmodule

