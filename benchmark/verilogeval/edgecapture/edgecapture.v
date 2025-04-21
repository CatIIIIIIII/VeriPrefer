module TopModule (
  input clk,
  input reset,
  input [31:0] in,
  output reg [31:0] out
);

  reg [31:0] delay_in;

  always @(posedge clk) begin
    if (reset) begin
      delay_in <= 32'b0;
    end else begin
      delay_in <= in;
    end
  end

  integer i;
  always @(posedge clk) begin
    if (reset) begin
      out <= 32'b0;
    end else begin
      for (i = 0; i < 32; i = i + 1) begin
        if (in[i] == 1 && delay_in[i] == 0) begin
          out[i] <= 1;
        end else begin
          out[i] <= 0;
        end
      end
    end
  end

endmodule

