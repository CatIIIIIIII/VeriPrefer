module multi_booth_8bit (
    output reg [15:0] p,
    output reg rdy,
    input clk, 
    input reset, 
    input [7:0] a, 
    input [7:0] b
);

    // Internal registers
    reg [15:0] multiplicand;
    reg [15:0] multiplier;
    reg [4:0] ctr;
    reg [15:0] temp_product;

    // Booth multiplication algorithm
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers on reset
            multiplicand <= {{8{a[7]}}, a};  // Sign-extended multiplicand
            multiplier <= {{8{b[7]}}, b};    // Sign-extended multiplier
            temp_product <= 16'b0;
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end
        else begin
            if (ctr < 5'd16) begin
                // Booth multiplication logic
                case (multiplier[1:0])
                    2'b00: begin
                        // No addition or subtraction
                        temp_product <= temp_product;
                    end
                    2'b01: begin
                        // Add multiplicand
                        temp_product <= temp_product + multiplicand;
                    end
                    2'b10: begin
                        // Subtract multiplicand
                        temp_product <= temp_product - multiplicand;
                    end
                    2'b11: begin
                        // No addition or subtraction
                        temp_product <= temp_product;
                    end
                endcase

                // Right shift multiplier and product
                multiplier <= {temp_product[0], multiplier[15:1]};
                temp_product <= {temp_product[15], temp_product[15:1]};

                // Increment counter
                ctr <= ctr + 1'b1;

                // Assign final product when multiplication completes
                if (ctr == 5'd15) begin
                    p <= temp_product;
                    rdy <= 1'b1;
                end
            end
        end
    end

endmodule