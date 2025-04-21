module counter_12 (
  input rst_n,
  input clk,
  input valid_count,

  output reg [3:0] out
);

  // Sequential logic block for counter operation
  always @(posedge clk or negedge rst_n) begin
    // Active low reset condition
    if (!rst_n) begin
      // Reset counter to 0 when reset is active
      out <= 4'b0000;
    end
    else begin
      // Check if counting is enabled
      if (valid_count) begin
        // Check if counter has reached maximum value (11)
        if (out == 4'd11) begin
          // Wrap around to 0 when maximum is reached
          out <= 4'b0000;
        end
        else begin
          // Increment counter
          out <= out + 1'b1;
        end
      end
      // If valid_count is 0, maintain previous count value
    end
  end

endmodule