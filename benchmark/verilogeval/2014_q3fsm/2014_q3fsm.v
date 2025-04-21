module TopModule (
  input clk,
  input reset,
  input s,
  input w,
  output reg z
);

  reg [2:0] state, next_state;
  reg [1:0] count;

  parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= A;
      count <= 2'b00;
    end else begin
      state <= next_state;
      if (state == B) begin
        count <= count + 1;
      end else begin
        count <= 2'b00;
      end
    end
  end

  always @(*) begin
    case (state)
      A: begin
        if (s) begin
          next_state = B;
        end else begin
          next_state = A;
        end
      end
      B: begin
        if (count == 2'b00 && w) begin
          next_state = C;
        end else if (count == 2'b01 && w) begin
          next_state = D;
        end else if (count == 2'b10 && w) begin
          next_state = E;
        end else begin
          next_state = B;
        end
      end
      C: begin
        if (count == 2'b01 && w) begin
          next_state = D;
        end else if (count == 2'b10 && w) begin
          next_state = E;
        end else begin
          next_state = C;
        end
      end
      D: begin
        if (count == 2'b10 && w) begin
          next_state = E;
        end else begin
          next_state = D;
        end
      end
      E: begin
        next_state = A;
      end
      default: begin
        next_state = A;
      end
    endcase
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      z <= 1'b0;
    end else begin
      if (state == C || state == D || state == E) begin
        z <= 1'b1;
      end else begin
        z <= 1'b0;
      end
    end
  end

endmodule

