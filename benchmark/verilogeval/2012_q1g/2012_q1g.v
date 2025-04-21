module TopModule (
  input [3:0] x,
  output logic f
);



  always @(*) begin
    case ({x[2], x[0]})
      2'b00: f = x[1];
      2'b01: f = 0;
      2'b11: f = x[1] | x[3];
      2'b10: f = x[1] | x[3];
    endcase
  end

endmodule

