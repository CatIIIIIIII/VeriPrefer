module TopModule (
  input clk,
  input [7:0] in,
  output reg [7:0] pedge
);

  reg [7:0] in_reg;

  always @(posedge clk) begin
    in_reg <= in;
  end

  always @(posedge clk) begin
    pedge <= (in_reg & ~in) | (in & ~in_reg);
  end
endmodule

