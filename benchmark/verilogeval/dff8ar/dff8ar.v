module TopModule (
  input clk,
  input [7:0] d,
  input areset,
  output reg [7:0] q
);

  reg [7:0] d_ffs;

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      d_ffs <= 8'b0;
    end else begin
      d_ffs <= d;
    end
  end

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      q <= 8'b0;
    end else begin
      q <= d_ffs;
    end
  end

endmodule

