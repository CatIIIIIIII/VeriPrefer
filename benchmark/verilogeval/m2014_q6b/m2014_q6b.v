module TopModule (
  input [2:0] y,
  input w,
  output reg Y1
);

  always @(*) begin
    case(y)
      3'b000: Y1 = 1'b0;
      3'b001: Y1 = 1'b0;
      3'b010: Y1 = 1'b1;
      3'b011: Y1 = 1'b1;
      3'b100: Y1 = 1'b0;
      3'b101: Y1 = 1'b1;
    endcase
  end

endmodule

