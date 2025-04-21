module TopModule (
  input clk,
  input in,
  input reset,
  output out
);

  parameter A = 0, B = 1, C = 2, D = 3;
  reg [1:0] state, next_state;

  always @(*) begin
    case (state)
      A: begin
        if (in == 0) begin
          next_state = A;
        end else begin
          next_state = B;
        end
      end
      B: begin
        if (in == 0) begin
          next_state = C;
        end else begin
          next_state = B;
        end
      end
      C: begin
        if (in == 0) begin
          next_state = A;
        end else begin
          next_state = D;
        end
      end
      D: begin
        if (in == 0) begin
          next_state = C;
        end else begin
          next_state = B;
        end
      end
    endcase
  end

  always @(posedge clk) begin
    if (reset == 1) begin
      state <= A;
    end else begin
      state <= next_state;
    end
  end

  assign out = (state == D)? 1 : 0;

endmodule

