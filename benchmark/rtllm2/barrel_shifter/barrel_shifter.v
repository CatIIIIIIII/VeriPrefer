module barrel_shifter (in, ctrl, out);
  input  [7:0] in;
  input [2:0] ctrl;
  output [7:0] out;
  wire [7:0] x,y;
wire [7:0] z;

  mux2X1 mux1 (.a(in), .b({in[3:0], in[7:4]}), .sel(ctrl[2]), .out(x));
  mux2X1 mux2 (.a(x), .b({x[5:0], x[7:6]}), .sel(ctrl[1]), .out(y));
  mux2X1 mux3 (.a(y), .b({y[6:0], y[7]}), .sel(ctrl[0]), .out(z));

  assign out = z;
endmodule

module mux2X1 (a, b, sel, out);
  input [7:0] a, b;
  input sel;
  output [7:0] out;

  assign out = sel ? b : a;
endmodule