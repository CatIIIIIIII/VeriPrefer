module signal_generator(
  input clk,
  input rst_n,
  output reg [4:0] wave
);

  // Internal state register to control wave direction
  reg state;

  // Always block for synchronous logic with reset
  always @(posedge clk or negedge rst_n) begin
    // Active-low reset condition
    if (!rst_n) begin
      wave <= 5'b0;   // Reset wave to 0
      state <= 1'b0;  // Reset state to 0 (incrementing mode)
    end
    else begin
      // State machine for triangle wave generation
      case (state)
        // Incrementing state
        1'b0: begin
          if (wave == 5'd31) begin
            // Reached maximum, switch to decrementing
            state <= 1'b1;
            wave <= wave - 1'b1;
          end
          else begin
            // Continue incrementing
            wave <= wave + 1'b1;
          end
        end
        
        // Decrementing state
        1'b1: begin
          if (wave == 5'd0) begin
            // Reached minimum, switch to incrementing
            state <= 1'b0;
            wave <= wave + 1'b1;
          end
          else begin
            // Continue decrementing
            wave <= wave - 1'b1;
          end
        end
      endcase
    end
  end

endmodule