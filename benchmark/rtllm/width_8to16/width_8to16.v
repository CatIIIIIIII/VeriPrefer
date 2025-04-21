module width_8to16(
    input               clk,
    input               rst_n,
    input               valid_in,
    input   [7:0]       data_in,
 
    output  reg         valid_out,
    output  reg [15:0]  data_out
);

    // Internal registers
    reg [7:0]   data_lock;      // Temporarily stores the first input data
    reg         flag;            // Flag to track first/second data input

    // Sequential logic block
    always @(posedge clk or negedge rst_n) begin
        // Active low reset
        if (!rst_n) begin
            data_out <= 16'd0;
            data_lock <= 8'd0;
            flag <= 1'b0;
            valid_out <= 1'b0;
        end
        else begin
            // Reset output signals
            valid_out <= 1'b0;

            // Process input data
            if (valid_in) begin
                if (!flag) begin
                    // First valid input - store in data_lock
                    data_lock <= data_in;
                    flag <= 1'b1;
                end
                else begin
                    // Second valid input - generate output
                    data_out <= {data_lock, data_in};
                    valid_out <= 1'b1;
                    flag <= 1'b0;  // Reset flag for next pair
                end
            end
        end
    end

endmodule