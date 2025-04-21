module TopModule (
  input clk,
  input areset,
  input x,
  output z
);

  reg state, next_state;
  localparam A = 1'b0, B = 1'b1;

  always @(*) begin
    case (state)
      A: next_state = x ? B : A;
      B: next_state = x ? B : A;
      default: next_state = A;
    endcase
  end

  always @(posedge clk, posedge areset) begin
    if (areset)
      state <= A;
    else
      state <= next_state;
  end

  assign z = (state == A) ? ~x : x;

endmodule

