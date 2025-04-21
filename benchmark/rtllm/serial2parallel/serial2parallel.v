module serial2parallel(
    input clk,
    input rst_n,
    input din_serial,
    input din_valid,
    output reg [7:0] dout_parallel,
    output reg dout_valid
);

    // Internal counter to track number of serial bits received
    reg [2:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        // Active low reset logic
        if (!rst_n) begin
            cnt <= 3'b000;
            dout_parallel <= 8'b0;
            dout_valid <= 1'b0;
        end
        else begin
            // When input data is valid
            if (din_valid) begin
                // Shift in the serial input bit from MSB to LSB
                dout_parallel <= {dout_parallel[6:0], din_serial};
                
                // Increment counter
                cnt <= cnt + 1'b1;
                
                // When 8 bits are received
                if (cnt == 3'b111) begin
                    dout_valid <= 1'b1;  // Set output valid flag
                    cnt <= 3'b000;       // Reset counter
                end
                else begin
                    dout_valid <= 1'b0;  // Output not valid yet
                end
            end
            else begin
                dout_valid <= 1'b0;  // No input data valid
            end
        end
    end

endmodule