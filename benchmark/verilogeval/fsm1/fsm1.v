module TopModule (
  input clk,
  input in,
  input areset,
  output out
);

  parameter A = 0, B = 1;
  reg state, next_state;

  always @(*) begin
    case (state)
      A: next_state = in ? A : B;
      B: next_state = in ? B : A;
    endcase
  end

  always @(posedge clk, posedge areset) begin
    if (areset) state <= B;
    else state <= next_state;
  end

  assign out = (state == A);

endmodule

