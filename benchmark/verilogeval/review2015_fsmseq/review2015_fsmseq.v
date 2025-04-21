module TopModule (
  input clk,
  input reset,
  input data,
  output start_shifting
);

  reg start_shifting_r;
  assign start_shifting = start_shifting_r;

  localparam [2:0] init = 3'b000,
    s1 = 3'b001,
    s11 = 3'b011,
    s110 = 3'b010,
    s1101 = 3'b110;
  reg [2:0] state, next_state;

  always @ (*) begin
    case (state)
      init: begin
        if (data) begin
          next_state = s1;
        end else begin
          next_state = init;
        end
      end
      s1: begin
        if (data) begin
          next_state = s11;
        end else begin
          next_state = init;
        end
      end
      s11: begin
        if (data) begin
          next_state = s11;
        end else begin
          next_state = s110;
        end
      end
      s110: begin
        if (data) begin
          next_state = s1101;
        end else begin
          next_state = init;
        end
      end
      s1101: begin
        if (data) begin
          next_state = s11;
        end else begin
          next_state = init;
        end
      end
      default: begin
        next_state = init;
      end
    endcase
  end

  always @ (posedge clk) begin
    if (reset) begin
      state <= init;
      start_shifting_r <= 0;
    end else begin
      state <= next_state;
      if (next_state == s1101) begin
        start_shifting_r <= 1;
      end else begin
        start_shifting_r <= 0;
      end
    end
  end
endmodule

