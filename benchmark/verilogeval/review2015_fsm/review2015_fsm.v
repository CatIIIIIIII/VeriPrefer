module TopModule (
  input clk,
  input reset,
  input data,
  output reg shift_ena,
  output reg counting,
  input done_counting,
  output reg done,
  input ack
);

  parameter IDLE = 0, SHIFT = 1, COUNT = 2, DONE = 3;
  reg [1:0] state, next_state;

  always @(*) begin
    case (state)
      IDLE: begin
        if (data == 1 && next_data == 1 && data_after_next == 0 && data_after_after_next == 1) begin
          next_state = SHIFT;
        end else begin
          next_state = IDLE;
        end
      end
      SHIFT: begin
        next_state = (shift_cnt == 4) ? COUNT : SHIFT;
      end
      COUNT: begin
        next_state = (done_counting) ? DONE : COUNT;
      end
      DONE: begin
        next_state = (ack) ? IDLE : DONE;
      end
      default: next_state = IDLE;
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always @(posedge clk) begin
    case (next_state)
      IDLE: begin
        shift_ena <= 0;
        counting <= 0;
        done <= 0;
      end
      SHIFT: begin
        shift_ena <= 1;
      end
      COUNT: begin
        shift_ena <= 0;
        counting <= 1;
      end
      DONE: begin
        shift_ena <= 0;
        counting <= 0;
        done <= 1;
      end
    endcase
  end

endmodule

