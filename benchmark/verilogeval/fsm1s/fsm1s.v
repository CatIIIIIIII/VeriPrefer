module TopModule (
  input clk,
  input in,
  input reset,
  output out
);

  parameter A=1'b0, B=1'b1;
  reg state, next_state;

  always @(*) begin
    case (state)
      A: next_state = in ? A : B;
      B: next_state = in ? B : A;
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= B;
    end else begin
      state <= next_state;
    end
  end

  assign out = (state == B);

endmodule

