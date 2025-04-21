module TopModule (
  input [4:0] a,
  input [4:0] b,
  input [4:0] c,
  input [4:0] d,
  input [4:0] e,
  input [4:0] f,
  output [7:0] w,
  output [7:0] x,
  output [7:0] y,
  output [7:0] z
);

  wire [31:0] in;
  wire [31:0] out;

  assign in = {a, b, c, d, e, f};

  assign out = {in, 2'b01};

  assign w = out[31:24];
  assign x = out[23:16];
  assign y = out[15:8];
  assign z = out[7:0];

endmodule

