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

  parameter LEFT = 0, RIGHT = 1, FALL_L = 2, FALL_R = 3, DIG_L = 4, DIG_R = 5;
  reg [2:0] state, next_state;

  always @(*) begin
    case (state)
      LEFT: begin
        if (ground) begin
          if (dig) begin
            next_state = DIG_L;
          end
          else begin
            next_state = bump_left ? RIGHT : LEFT;
          end
        end
        else begin
          next_state = FALL_L;
        end
      end
      RIGHT: begin
        if (ground) begin
          if (dig) begin
            next_state = DIG_R;
          end
          else begin
            next_state = bump_right ? LEFT : RIGHT;
          end
        end
        else begin
          next_state = FALL_R;
        end
      end
      FALL_L: begin
        if (ground) begin
          next_state = LEFT;
        end
        else begin
          next_state = FALL_L;
        end
      end
      FALL_R: begin
        if (ground) begin
          next_state = RIGHT;
        end
        else begin
          next_state = FALL_R;
        end
      end
      DIG_L: begin
        if (ground) begin
          next_state = DIG_L;
        end
        else begin
          next_state = FALL_L;
        end
      end
      DIG_R: begin
        if (ground) begin
          next_state = DIG_R;
        end
        else begin
          next_state = FALL_R;
        end
      end
    endcase
  end

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= LEFT;
    end
    else begin
      state <= next_state;
    end
  end

  assign walk_left = (state == LEFT) ? 1'b1 : 1'b0;
  assign walk_right = (state == RIGHT) ? 1'b1 : 1'b0;
  assign aaah = (state == FALL_L || state == FALL_R) ? 1'b1 : 1'b0;
  assign digging = (state == DIG_L || state == DIG_R) ? 1'b1 : 1'b0;

endmodule

