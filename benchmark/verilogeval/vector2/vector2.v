module TopModule (
  input [31:0] in,
  output [31:0] out
);

  assign out = {in[23:16], in[31:24], in[7:0], in[15:8]};

endmodule

