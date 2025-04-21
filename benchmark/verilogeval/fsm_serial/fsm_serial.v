module TopModule (
  input clk,
  input in,
  input reset,
  output done
);

  parameter Idle = 3'd0, StartBit = 3'd1, Data = 3'd2, StopBit = 3'd3, Wait = 3'd4;
  reg [2:0] state, next_state;
  reg [3:0] cnt;

  always @(*) begin
    case (state)
      Idle: next_state = in ? Idle : StartBit;
      StartBit: next_state = Data;
      Data: begin
        if (cnt == 4'd8)
          next_state = StopBit;
        else
          next_state = Data;
      end
      StopBit: next_state = in ? Wait : StartBit;
      Wait: next_state = in ? Idle : Wait;
      default: next_state = Idle;
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= Idle;
      cnt <= 4'd0;
    end
    else if (state == Data) begin
      state <= next_state;
      cnt <= cnt + 1'b1;
    end
    else if (state == Wait) begin
      state <= next_state;
      cnt <= 4'd0;
    end
    else begin
      state <= next_state;
      cnt <= 4'd0;
    end
  end

  assign done = (state == StopBit) ? 1'b1 : 1'b0;

endmodule

