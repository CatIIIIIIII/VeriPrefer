module TopModule (
  input clk,
  input reset,
  output [3:1] ena,
  output reg [15:0] q
);

  reg [3:0] ones;
  reg [3:0] tens;
  reg [3:0] hundreds;
  reg [3:0] thousands;

  always @(posedge clk) begin
    if (reset) begin
      ones <= 4'b0000;
      tens <= 4'b0000;
      hundreds <= 4'b0000;
      thousands <= 4'b0000;
    end else begin
      if (ones == 9) begin
        ones <= 0;
        if (tens == 9) begin
          tens <= 0;
          if (hundreds == 9) begin
            hundreds <= 0;
            if (thousands == 9) begin
              thousands <= 0;
            end else begin
              thousands <= thousands + 1;
            end
          end else begin
            hundreds <= hundreds + 1;
          end
        end else begin
          tens <= tens + 1;
        end
      end else begin
        ones <= ones + 1;
      end
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      q <= 16'b0000_0000_0000_0000;
    end else begin
      q[3:0] <= ones;
      q[7:4] <= tens;
      q[11:8] <= hundreds;
      q[15:12] <= thousands;
    end
  end

  assign ena[1] = (ones == 9) ? 1'b1 : 1'b0;
  assign ena[2] = (ones == 9 && tens == 9) ? 1'b1 : 1'b0;
  assign ena[3] = (ones == 9 && tens == 9 && hundreds == 9) ? 1'b1 : 1'b0;

endmodule

