module TopModule (
  input clk,
  input reset,
  input w,
  output z
);

  reg _z;
  reg [31:0] state;
  reg [31:0] next_state;

  localparam A = 4'b0000;
  localparam B = 4'b0001;
  localparam C = 4'b0010;
  localparam D = 4'b0011;
  localparam E = 4'b0100;
  localparam F = 4'b0101;

  always @(*) begin
    case (state)
      A: begin
        if (w) begin
          next_state = B;
        end else begin
          next_state = A;
        end
      end
      B: begin
        if (w) begin
          next_state = C;
        end else begin
          next_state = D;
        end
      end
      C: begin
        if (w) begin
          next_state = E;
        end else begin
          next_state = D;
        end
      end
      D: begin
        if (w) begin
          next_state = F;
        end else begin
          next_state = A;
        end
      end
      E: begin
        if (w) begin
          next_state = E;
        end else begin
          next_state = D;
        end
      end
      F: begin
        if (w) begin
          next_state = C;
        end else begin
          next_state = D;
        end
      end
      default: begin
        next_state = 0;
      end
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= A;
    end else begin
      state <= next_state;
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      _z <= 0;
    end else begin
      case (state)
        A: begin
          _z <= 0;
        end
        B: begin
          _z <= 0;
        end
        C: begin
          _z <= 0;
        end
        D: begin
          _z <= 0;
        end
        E: begin
          _z <= 1;
        end
        F: begin
          _z <= 1;
        end
        default: begin
          _z <= 0;
        end
      endcase
    end
  end

  assign z = _z;

endmodule

