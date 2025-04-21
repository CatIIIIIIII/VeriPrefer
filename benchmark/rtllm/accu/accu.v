module accu(
    input               clk         ,   
    input               rst_n       ,
    input       [7:0]   data_in     ,
    input               valid_in    ,
 
    output  reg         valid_out   ,
    output  reg [9:0]   data_out
);

    // Internal registers
    reg [1:0]   count;          // Counter to track number of inputs
    reg [9:0]   accumulator;    // Accumulator to store sum

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all internal states
            count <= 2'b00;
            accumulator <= 10'd0;
            valid_out <= 1'b0;
            data_out <= 10'd0;
        end
        else begin
            // Default assignments
            valid_out <= 1'b0;

            // Check if input is valid
            if (valid_in) begin
                // Accumulate input data
                accumulator <= accumulator + {2'b00, data_in};
                
                // Increment counter
                count <= count + 1'b1;
                
                // When 4 inputs are accumulated
                if (count == 2'b11) begin
                    // Output accumulated sum
                    data_out <= accumulator + {2'b00, data_in};
                    valid_out <= 1'b1;
                    
                    // Reset accumulator and counter
                    accumulator <= 10'd0;
                    count <= 2'b00;
                end
            end
        end
    end

endmodule