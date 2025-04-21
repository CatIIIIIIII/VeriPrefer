module TopModule (
  input clk,
  input load,
  input [9:0] data,
  output tc
);

  reg [9:0] cnt;
  reg tc_int;

  assign tc = tc_int;

  always @(posedge clk) begin
    if (load == 1'b1) begin
      cnt <= data;
    end
    else if (cnt != 10'd0) begin
      cnt <= cnt - 10'd1;
    end
  end

  always @(posedge clk) begin
    if (cnt == 10'd0) begin
      tc_int <= 1'b1;
    end
    else begin
      tc_int <= 1'b0;
    end
  end

endmodule

