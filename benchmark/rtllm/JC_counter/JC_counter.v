module JC_counter(
   input                clk,
   input                rst_n,
 
   output reg [63:0]    Q  
);

    // Sequential logic for counter update
    always @(posedge clk or negedge rst_n) begin
        // Active-low reset condition
        if (!rst_n) begin
            Q <= 64'b0;  // Reset counter to all zeros
        end
        else begin
            // Check the least significant bit to determine shift direction
            if (Q[0] == 1'b0) begin
                // If LSB is 0, shift right and append 1 at MSB
                Q <= {1'b1, Q[63:1]};
            end
            else begin
                // If LSB is 1, shift right and append 0 at MSB
                Q <= {1'b0, Q[63:1]};
            end
        end
    end

endmodule