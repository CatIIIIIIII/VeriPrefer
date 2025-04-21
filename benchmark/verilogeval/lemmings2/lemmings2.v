module TopModule (
  input clk,
  input areset,
  input bump_left,
  input bump_right,
  input ground,
  output walk_left,
  output walk_right,
  output aaah
);

  parameter W_LEFT  = 0;
  parameter W_RIGHT = 1;
  parameter F_LEFT  = 2;
  parameter F_RIGHT = 3;

  reg [1:0] state, next_state;

  always @(*) begin
    case (state)
      W_LEFT: begin
        if (~ground)
          next_state = F_LEFT;
        else if (bump_left)
          next_state = W_RIGHT;
        else
          next_state = W_LEFT;
      end
      W_RIGHT: begin
        if (~ground)
          next_state = F_RIGHT;
        else if (bump_right)
          next_state = W_LEFT;
        else
          next_state = W_RIGHT;
      end
      F_LEFT: begin
        if (ground)
          next_state = W_RIGHT;
        else
          next_state = F_LEFT;
      end
      F_RIGHT: begin
        if (ground)
          next_state = W_LEFT;
        else
          next_state = F_RIGHT;
      end
    endcase
  end

  always @(posedge clk, posedge areset) begin
    if (areset)
      state <= W_LEFT;
    else
      state <= next_state;
  end

  assign walk_left = (state == W_LEFT) ? 1'b1 : 1'b0;
  assign walk_right = (state == W_RIGHT) ? 1'b1 : 1'b0;
  assign aaah = (state == F_LEFT || state == F_RIGHT) ? 1'b1 : 1'b0;

endmodule

