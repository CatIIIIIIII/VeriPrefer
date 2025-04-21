module TopModule (
  input clk,
  input [7:0] in,
  input reset,
  output [23:0] out_bytes,
  output done
);

  reg [2:0] state, next_state;
  reg [23:0] out_bytes_reg;
  reg done_reg;

  always @(posedge clk) begin
    if (reset) begin
      state <= 3'b000;
    end else begin
      state <= next_state;
    end
  end

  always @(*) begin
    case (state)
      3'b000: begin
        if (in[3] == 1) begin
          next_state = 3'b001;
        end else begin
          next_state = 3'b000;
        end
      end
      3'b001: begin
        next_state = 3'b010;
      end
      3'b010: begin
        next_state = 3'b011;
      end
      3'b011: begin
        next_state = 3'b000;
      end
      default: begin
        next_state = 3'b000;
      end
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      out_bytes_reg <= 24'b0;
      done_reg <= 1'b0;
    end else begin
      if (state == 3'b011) begin
        out_bytes_reg <= {out_bytes_reg[15:0], in};
        done_reg <= 1'b1;
      end else begin
        out_bytes_reg <= out_bytes_reg;
        done_reg <= 1'b0;
      end
    end
  end

  assign out_bytes = out_bytes_reg;
  assign done = done_reg;

endmodule

