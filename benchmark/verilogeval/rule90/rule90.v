module TopModule (
  input clk,
  input load,
  input [511:0] data,
  output reg [511:0] q
);

  integer i;

  always @(posedge clk) begin
    if (load) begin
      q <= data;
    end else begin

      q[0] <= q[1] ^ q[511];
      q[1] <= q[2] ^ q[510];
      for (i = 2; i < 511; i = i + 1) begin
        q[i] <= q[i+1] ^ q[i-1];
      end
      q[511] <= q[0] ^ q[512];
    end
  end

endmodule

