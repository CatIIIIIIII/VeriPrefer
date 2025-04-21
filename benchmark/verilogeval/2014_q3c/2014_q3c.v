module TopModule (
  input clk,
  input x,
  input [2:0] y,
  output reg Y0,
  output reg z
);

  reg [2:0] Y;

  always @(posedge clk) begin
    Y <= (x == 0) ? Y[2:0] : Y[2:0] ^ 3'b001;
    z <= (x == 0) ? 0 : Y[2];
    Y0 <= Y[0];
  end
endmodule

