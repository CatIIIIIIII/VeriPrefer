module TopModule (
  input clk,
  input reset,
  input w,
  output z
);

  reg [3:0] state, next_state;
  localparam A = 0, B = 1, C = 2, D = 3, E = 4, F = 5;

  always @(*) begin
    case (state)
      A: next_state = w ? A : B;
      B: next_state = w ? D : C;
      C: next_state = w ? D : E;
      D: next_state = w ? D : F;
      E: next_state = w ? D : E;
      F: next_state = w ? D : C;
      default: next_state = A;
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= A;
    end else begin
      state <= next_state;
    end
  end

  assign z = (state == E);

endmodule

