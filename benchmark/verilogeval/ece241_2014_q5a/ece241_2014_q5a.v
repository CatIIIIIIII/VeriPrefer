module TopModule (
  input clk,
  input areset,
  input x,
  output z
);

  localparam  S0 = 0, S1 = 1, S2 = 2;

  reg [1:0] state, next_state;
  reg out;

  always @(*) begin
    case (state)
      S0: begin
        if (x == 1'b0) begin
          next_state = S0;
          out = 1'b0;
        end
        else begin
          next_state = S1;
          out = 1'b0;
        end
      end
      S1: begin
        if (x == 1'b0) begin
          next_state = S2;
          out = 1'b0;
        end
        else begin
          next_state = S1;
          out = 1'b1;
        end
      end
      S2: begin
        if (x == 1'b0) begin
          next_state = S0;
          out = 1'b1;
        end
        else begin
          next_state = S1;
          out = 1'b1;
        end
      end
      default: begin
        next_state = S0;
        out = 1'b0;
      end
    endcase
  end

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= S0;
    end
    else begin
      state <= next_state;
    end
  end

  assign z = out;

endmodule

