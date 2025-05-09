module TopModule (
  input clk,
  input reset,
  output reg [3:0] q
);

  always @(posedge clk) begin
    if(reset)begin
      q <= 4'd1;
    end
    else begin
      if(q == 4'd10)begin
        q <= 4'd1;
      end
      else begin
        q <= q + 4'd1;
      end
    end
  end
endmodule

