module TopModule (
  input clk,
  input areset,
  input bump_left,
  input bump_right,
  input ground,
  input dig,
  output walk_left,
  output walk_right,
  output aaah,
  output digging
);

  parameter W_LEFT = 2'd0;
  parameter W_RIGHT = 2'd1;
  parameter F_LEFT = 2'd2;
  parameter F_RIGHT = 2'd3;
  parameter D_LEFT = 2'd4;
  parameter D_RIGHT = 2'd5;

  reg [2:0] state, next_state;
  reg [4:0] count;

  always @(*) begin
    case (state)
      W_LEFT: begin
        if (ground == 0)
          next_state = F_LEFT;
        else if (dig == 1)
          next_state = D_LEFT;
        else if (bump_left == 1)
          next_state = W_RIGHT;
        else
          next_state = W_LEFT;
      end
      W_RIGHT: begin
        if (ground == 0)
          next_state = F_RIGHT;
        else if (dig == 1)
          next_state = D_RIGHT;
        else if (bump_right == 1)
          next_state = W_LEFT;
        else
          next_state = W_RIGHT;
      end
      F_LEFT: begin
        if (ground == 1 && count < 20)
          next_state = F_LEFT;
        else if (ground == 1 && count >= 20)
          next_state = W_RIGHT;
        else
          next_state = F_LEFT;
      end
      F_RIGHT: begin
        if (ground == 1 && count < 20)
          next_state = F_RIGHT;
        else if (ground == 1 && count >= 20)
          next_state = W_LEFT;
        else
          next_state = F_RIGHT;
      end
      D_LEFT: begin
        if (ground == 0)
          next_state = F_LEFT;
        else
          next_state = D_LEFT;
      end
      D_RIGHT: begin
        if (ground == 0)
          next_state = F_RIGHT;
        else
          next_state = D_RIGHT;
      end
      default: next_state = W_LEFT;
    endcase
  end

  always @(posedge clk or posedge areset) begin
    if (areset == 1)
      state <= W_LEFT;
    else if (state == F_LEFT || state == F_RIGHT) begin
      if (count >= 20)
        state <= 0;
      else
        state <= next_state;
    end else
      state <= next_state;
  end

  always @(posedge clk or posedge areset) begin
    if (areset == 1)
      count <= 0;
    else if (state == F_LEFT || state == F_RIGHT) begin
      if (ground == 1)
        count <= count + 1;
      else
        count <= 0;
    end else
      count <= 0;
  end

  assign walk_left = (state == W_LEFT ? 1 : 0);
  assign walk_right = (state == W_RIGHT ? 1 : 0);
  assign aaah = (state == F_LEFT || state == F_RIGHT ? 1 : 0);
  assign digging = (state == D_LEFT || state == D_RIGHT ? 1 : 0);

endmodule

