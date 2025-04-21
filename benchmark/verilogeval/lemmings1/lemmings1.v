module TopModule (
  input clk,
  input areset,
  input bump_left,
  input bump_right,
  output walk_left,
  output walk_right
);

  reg state;
  reg next_state;
  reg walk;

  always @(*) begin
    case (state)
      0: begin
        if (bump_left) begin
          next_state = 1;
          walk = 1;
        end
        else if (bump_right) begin
          next_state = 0;
          walk = 0;
        end
        else begin
          next_state = 0;
          walk = 1;
        end
      end
      1: begin
        if (bump_left) begin
          next_state = 1;
          walk = 0;
        end
        else if (bump_right) begin
          next_state = 0;
          walk = 1;
        end
        else begin
          next_state = 1;
          walk = 0;
        end
      end
    endcase
  end

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= 0;
    end
    else begin
      state <= next_state;
    end
  end

  assign walk_left = walk & (state == 0);
  assign walk_right = walk & (state == 1);

endmodule

