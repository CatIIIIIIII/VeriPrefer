
module top_module (
  input in,
  input [3:0] state,
  output reg [3:0] next_state,
  output reg out
);

// State transition logic
always @(*) begin
  case (state)
    4'b0001: // State A
      next_state = in ? 4'b0010 : 4'b0001;
    4'b0010: // State B
      next_state = in ? 4'b0010 : 4'b0100;
    4'b0100: // State C
      next_state = in ? 4'b1000 : 4'b0001;
    4'b1000: // State D
      next_state = in ? 4'b0010 : 4'b0100;
    default:
      next_state = 4'b0001; // Default to state A
  endcase
end

// Output logic
always @(*) begin
  case (state)
    4'b0001: // State A
      out = 1'b0;
    4'b0010: // State B
      out = 1'b0;
    4'b0100: // State C
      out = 1'b0;
    4'b1000: // State D
      out = 1'b1;
    default:
      out = 1'b0; // Default output
  endcase
end

endmodule
