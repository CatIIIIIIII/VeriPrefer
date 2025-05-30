module TopModule (
  input clk,
  input areset,
  input load,
  input ena,
  input [3:0] data,
  output reg [3:0] q
);

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      q <= 4'b0000;
    end else if (load) begin
      q <= data[3:0];
    end else if (ena) begin
      q <= {q[2:0], 1'b0};
    end
  end

endmodule

