module TopModule (
  input clk,
  input j,
  input k,
  output reg Q
);

  reg Qold;

  always @(posedge clk) begin
    case ({j, k})
      2'b00: Q <= Qold;
      2'b01: Q <= 1'b0;
      2'b10: Q <= 1'b1;
      2'b11: Q <= ~Qold;
    endcase
  end

endmodule

