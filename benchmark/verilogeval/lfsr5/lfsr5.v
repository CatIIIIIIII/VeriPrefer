module TopModule (
  input clk,
  input reset,
  output reg [4:0] q
);

  wire lfsr_in;
  assign lfsr_in = q[4] ^ q[2];

  always @(posedge clk) begin
    if(reset) begin
      q <= 5'b00001;
    end
    else begin
      q <= {q[3:0], lfsr_in};
    end
  end

endmodule

