module float_multi(clk, rst, a, b, z);

input clk, rst;
input [31:0] a, b;
output reg [31:0] z;
reg [2:0] counter;
reg [23:0] a_mantissa, b_mantissa, z_mantissa;
reg [9:0] a_exponent, b_exponent, z_exponent;
reg a_sign, b_sign, z_sign;
reg [49:0] product;
reg guard_bit, round_bit, sticky;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 3'b000;
    end else begin
        case (counter)
            3'b000: begin
                a_sign <= a[31];
                b_sign <= b[31];
                a_exponent <= a[30:23];
                b_exponent <= b[30:23];
                a_mantissa <= {1'b1, a[22:0]};
                b_mantissa <= {1'b1, b[22:0]};
                counter <= counter + 1;
            end
            3'b001: begin
                // Check for special cases (NaN and Infinity)
                if ((a_exponent == 8'hFF && a_mantissa != 0) || (b_exponent == 8'hFF && b_mantissa != 0)) begin
                    z <= 32'h7FC00000; // NaN
                end else if (a_exponent == 8'hFF) begin
                    z <= {a_sign, 8'hFF, 23'b0}; // Infinity
                end else if (b_exponent == 8'hFF) begin
                    z <= {b_sign, 8'hFF, 23'b0}; // Infinity
                end else begin
                    counter <= counter + 1;
                end
            end
            3'b010: begin
                // Normalize the mantissas
                if (a_mantissa[23] == 1'b1) begin
                    a_mantissa <= a_mantissa >> 1;
                    a_exponent <= a_exponent + 1;
                end
                if (b_mantissa[23] == 1'b1) begin
                    b_mantissa <= b_mantissa >> 1;
                    b_exponent <= b_exponent + 1;
                end
                counter <= counter + 1;
            end
            3'b011: begin
                // Multiply the mantissas
                product <= a_mantissa * b_mantissa;
                z_exponent <= a_exponent + b_exponent - 1023;
                counter <= counter + 1;
            end
            3'b100: begin
                // Extract rounding bits
                guard_bit <= product[23];
                round_bit <= product[22];
                sticky <= |product[21:0];
                
                // Round the result
                if (guard_bit && (round_bit || sticky || product[24])) begin
                    z_mantissa <= product[49:26] + 1;
                    if (z_mantissa[23]) begin
                        z_exponent <= z_exponent + 1;
                    end
                end else begin
                    z_mantissa <= product[49:26];
                end
                
                // Adjust the exponent if necessary
                if (z_mantissa[23]) begin
                    z_mantissa <= z_mantissa >> 1;
                    z_exponent <= z_exponent + 1;
                end
                
                // Combine sign, exponent, and mantissa
                z_sign <= a_sign ^ b_sign;
                z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                
                // Check for overflow/underflow
                if (z_exponent[9:8] == 2'b11) begin
                    z <= z_exponent[9] ? {z_sign, 8'hFF, 23'b0} : {z_sign, 8'h00, 23'b0};
                end
                
                counter <= 3'b000;
            end
        endcase
    end
end

endmodule