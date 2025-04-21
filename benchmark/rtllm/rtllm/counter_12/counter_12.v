
module counter_12 
(
  input rst_n,
  input clk,
  input valid_count,

  output reg [3:0] out
);
  wire [3:0] out_next;
  wire done_count;

  assign done_count = (out == 4'd11);
  assign out_next = done_count ? 4'b0000 : out + 4'b0001;

  always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out <= 4'b0000;
    end
    else if (valid_count == 1'b1) begin
      out <= out_next;
    end
    else begin
      out <= out;
    end
  end

endmodule