module TopModule (
  input clk,
  input reset,
  input in,
  output disc,
  output flag,
  output err
);

  reg [3:0] state, next_state;

  always @(*) begin
    case (state)
      4'b0000: next_state = in ? 4'b0001 : 4'b0000;
      4'b0001: next_state = in ? 4'b0010 : 4'b0000;
      4'b0010: next_state = in ? 4'b0011 : 4'b0000;
      4'b0011: next_state = in ? 4'b0100 : 4'b0000;
      4'b0100: next_state = in ? 4'b0101 : 4'b0000;
      4'b0101: next_state = in ? 4'b0110 : 4'b0000;
      4'b0110: next_state = in ? 4'b0111 : 4'b0000;
      4'b0111: next_state = in ? 4'b1000 : 4'b0000;
      4'b1000: next_state = in ? 4'b1000 : 4'b0000;
      4'b1001: next_state = in ? 4'b1001 : 4'b0000;
      default: next_state = 4'b0000;
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= 4'b0000;
    end else begin
      state <= next_state;
    end
  end

  assign disc = (state == 4'b0110);
  assign flag = (state == 4'b1000) || (state == 4'b1001);
  assign err = (state == 4'b1001);

endmodule

