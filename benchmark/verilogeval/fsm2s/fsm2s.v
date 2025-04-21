module TopModule (
  input clk,
  input j,
  input k,
  input reset,
  output out
);

  parameter OFF = 0, ON = 1;
  reg state, next_state;

  always @(*) begin
    case (state)
      OFF: next_state = j ? ON : OFF;
      ON: next_state = k ? OFF : ON;
    endcase
  end

  always @(posedge clk) begin
    if (reset)
      state <= OFF;
    else
      state <= next_state;
  end

  assign out = (state == ON);

endmodule

