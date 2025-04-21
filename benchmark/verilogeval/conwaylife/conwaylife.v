module TopModule (
  input clk,
  input load,
  input [255:0] data,
  output reg [255:0] q
);

  reg [255:0] next_q;

  function [3:0] count_neighbours;
    input [255:0] q;
    input [3:0] x;
    input [3:0] y;
    reg [3:0] sum;
    reg [3:0] i;
    reg [3:0] j;
    begin
      sum = 0;
      for (i = y - 1; i <= y + 1; i = i + 1) begin
        for (j = x - 1; j <= x + 1; j = j + 1) begin
          if (i == y && j == x) begin
            next_neighbour = next_neighbour + 1;
          end else begin
            if (i < 16 && j < 16) begin
              sum = sum + q[i * 16 + j];
            end else begin
              if (i == 16) begin
                i = 0;
              end
              if (j == 16) begin
                j = 0;
              end
              sum = sum + q[i * 16 + j];
            end
          end
        end
      end
      count_neighbours = sum;
    end
  endfunction

  integer i;
  integer j;

  always @(posedge clk) begin
    if (load) begin
      q <= data;
    end else begin
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
          case (count_neighbours(q, j, i))
            0, 1: next_q[i * 16 + j] = 0;
            2: next_q[i * 16 + j] = q[i * 16 + j];
            3: next_q[i * 16 + j] = 1;
            default: next_q[i * 16 + j] = 0;
          endcase
        end
      end
      q <= next_q;
    end
  end

endmodule

