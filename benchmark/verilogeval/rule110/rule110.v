module TopModule (
  input clk,
  input load,
  input [511:0] data,
  output reg [511:0] q
);

  reg [511:0] q_next;

  always @(posedge clk) begin
    if (load)
      q <= data;
    else
      q <= q_next;
  end

  integer i;
  always @(*) begin
    for (i = 0; i < 512; i = i + 1) begin
      if (q[i-1] == 1 && q[i] == 1 && q[i+1] == 1)
        q_next[i] = 0;
      else if (q[i-1] == 1 && q[i] == 1 && q[i+1] == 0)
        q_next[i] = 1;
      else if (q[i-1] == 1 && q[i] == 0 && q[i+1] == 1)
        q_next[i] = 1;
      else if (q[i-1] == 1 && q[i] == 0 && q[i+1] == 0)
        q_next[i] = 0;
      else if (q[i-1] == 0 && q[i] == 1 && q[i+1] == 1)
        q_next[i] = 1;
      else if (q[i-1] == 0 && q[i] == 1 && q[i+1] == 0)
        q_next[i] = 1;
      else if (q[i-1] == 0 && q[i] == 0 && q[i+1] == 1)
        q_next[i] = 1;
      else if (q[i-1] == 0 && q[i] == 0 && q[i+1] == 0)
        q_next[i] = 0;
    end
  end
endmodule

