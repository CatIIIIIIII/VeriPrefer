module TopModule (
  input clk,
  input resetn,
  input [1:0] byteena,
  input [15:0] d,
  output reg [15:0] q
);

  integer i;
  always @(posedge clk) begin
    if (!resetn) begin
      q <= 16'b0;
    end else begin
      for (i = 0; i < 16; i = i + 1) begin
        if (byteena[1] || byteena[0]) begin
          q[i] <= d[i];
        end
      end
    end
  end
endmodule

