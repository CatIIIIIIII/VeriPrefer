module TopModule (
  input clk,
  input [7:0] d,
  input reset,
  output reg [7:0] q
);



  always @(negedge clk) begin
    if (reset) q[0] <= 8'h34;
    else q[0] <= d[0];
  end

  always @(negedge clk) begin
    if (reset) q[1] <= 8'h34;
    else q[1] <= d[1];
  end

  always @(negedge clk) begin
    if (reset) q[2] <= 8'h34;
    else q[2] <= d[2];
  end

  always @(negedge clk) begin
    if (reset) q[3] <= 8'h34;
    else q[3] <= d[3];
  end

  always @(negedge clk) begin
    if (reset) q[4] <= 8'h34;
    else q[4] <= d[4];
  end

  always @(negedge clk) begin
    if (reset) q[5] <= 8'h34;
    else q[5] <= d[5];
  end

  always @(negedge clk) begin
    if (reset) q[6] <= 8'h34;
    else q[6] <= d[6];
  end

  always @(negedge clk) begin
    if (reset) q[7] <= 8'h34;
    else q[7] <= d[7];
  end

endmodule

