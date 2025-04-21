module parallel2serial(
    input wire clk,
    input wire rst_n,
    input wire [3:0] d,
    output wire valid_out,
    output wire dout
);

    // Internal registers
    reg [3:0] data;       // Data register to hold parallel input
    reg [1:0] cnt;        // Counter to track conversion progress
    reg valid;            // Internal valid signal

    // Output assignments
    assign valid_out = valid;
    assign dout = data[3];  // Most significant bit is always output

    // Sequential logic block
    always @(posedge clk or negedge rst_n) begin
        // Active low reset
        if (!rst_n) begin
            data <= 4'b0;
            cnt <= 2'b0;
            valid <= 1'b0;
        end
        else begin
            // Check if we've completed 4-bit conversion
            if (cnt == 2'd3) begin
                // Load new parallel input
                data <= d;
                cnt <= 2'b0;
                valid <= 1'b1;
            end
            else begin
                // Shift data left
                data <= {data[2:0], 1'b0};
                cnt <= cnt + 1'b1;
                valid <= 1'b0;
            end
        end
    end

endmodule