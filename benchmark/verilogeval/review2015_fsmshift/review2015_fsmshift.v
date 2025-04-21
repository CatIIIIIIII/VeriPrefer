module TopModule (
  input clk,
  input reset,
  output shift_ena
);

  reg [2:0] cnt;
  reg ena;
  always @(posedge clk) begin
    if (reset) begin
      cnt <= 0;
      ena <= 1;
    end
    else begin
      if (cnt == 4) begin
        cnt <= 0;
        ena <= 0;
      end
      else begin
        cnt <= cnt + 1;
        ena <= 1;
      end
    end
  end
  assign shift_ena = ena;
endmodule

