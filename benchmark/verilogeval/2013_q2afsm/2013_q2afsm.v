module TopModule (
  input clk,
  input resetn,
  input  [2:0] r,
  output [2:0] g
);

  parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011;
  reg [1:0] state, next_state;
  reg [2:0] g_reg;

  always @(*) begin
    case (state)
      A: begin
           if (r[0] == 1'b0 && r[1] == 1'b0 && r[2] == 1'b0) begin
             next_state = A;
           end else if (r[0] == 1'b1) begin
             next_state = B;
           end else if (r[1] == 1'b1) begin
             next_state = C;
           end else begin
             next_state = D;
           end
         end
      B: begin
           if (r[0] == 1'b1) begin
             next_state = B;
           end else begin
             next_state = A;
           end
         end
      C: begin
           if (r[1] == 1'b1) begin
             next_state = C;
           end else begin
             next_state = A;
           end
         end
      D: begin
           if (r[2] == 1'b1) begin
             next_state = D;
           end else begin
             next_state = A;
           end
         end
      default: begin
                 next_state = A;
               end
    endcase
  end

  always @(posedge clk) begin
    if (resetn == 1'b0) begin
      state <= A;
    end else begin
      state <= next_state;
    end
  end

  always @(*) begin
    if (state == A) begin
      g_reg = 3'b000;
    end else if (state == B) begin
      g_reg = 3'b100;
    end else if (state == C) begin
      g_reg = 3'b010;
    end else begin
      g_reg = 3'b001;
    end
  end

  assign g = g_reg;

endmodule

