module TopModule (
  input clk,
  input resetn,
  input x,
  input y,
  output f,
  output g
);

  reg f_reg, g_reg;
  reg [2:0] state;

  assign f = f_reg;
  assign g = g_reg;

  always @(posedge clk) begin
    case (state)
      0: begin 
           f_reg <= 0;
           g_reg <= 0;
           if (resetn == 0)
             state <= 0;
           else
             state <= 1;
         end
      1: begin 
           f_reg <= 1;
           state <= 2;
         end
      2: begin 
           f_reg <= 0;
           if (x == 1)
             state <= 3;
         end
      3: begin 
           f_reg <= 0;
           if (x == 0)
             state <= 4;
         end
      4: begin 
           f_reg <= 0;
           if (x == 1)
             state <= 5;
         end
      5: begin 
           f_reg <= 0;
           g_reg <= 1;
           state <= 6;
         end
      6: begin 
           if (y == 1)
             state <= 7;
         end
      7: begin 
           g_reg <= 1;
           if (y == 1)
             state <= 8;
         end
      8: begin 
           g_reg <= 1;
           if (y == 0)
             state <= 9;
         end
      9: begin 
           g_reg <= 0;
           state <= 0;
         end
    endcase
  end
endmodule

