module TopModule (
  input [3:0] x,
  output logic f
);

  always @(*) begin
    case ({x[3:2], x[1:0]})
      4'b0000, 4'b0010, 4'b1001, 4'b1011: f = 0;
      4'b0001, 4'b0011, 4'b0100, 4'b0101, 4'b1100, 4'b1101, 4'b1110, 4'b1111: f = 1;
      default: f = 1;
    endcase
  end

endmodule

