module radix2_div(
    input wire clk,
    input wire rst,
    input wire [7:0] dividend,    
    input wire [7:0] divisor,    
    input wire sign,       

    input wire opn_valid,   
    output reg res_valid,   
    input wire res_ready,   
    output wire [15:0] result
);

    // Internal signals
    reg [16:0] SR;      // Shift register (1 extra bit for sign/carry)
    reg [16:0] NEG_DIVISOR;
    reg [3:0] cnt;      // Counter for division steps
    reg start_cnt;      // Flag to start division process
    
    // Intermediate signals for dividend and divisor processing
    wire [7:0] abs_dividend;
    wire [7:0] abs_divisor;
    wire dividend_sign, divisor_sign;

    // Handle signed division preprocessing
    assign dividend_sign = sign ? dividend[7] : 1'b0;
    assign divisor_sign = sign ? divisor[7] : 1'b0;
    
    // Take absolute values for signed division
    assign abs_dividend = sign && dividend[7] ? -dividend : dividend;
    assign abs_divisor = sign && divisor[7] ? -divisor : divisor;

    // Result assignment
    assign result = SR[15:0];

    // Division process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all internal registers
            SR <= 17'b0;
            NEG_DIVISOR <= 17'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
        end
        else begin
            // Start division when operation is valid and not already processing
            if (opn_valid && !res_valid) begin
                // Prepare shift register with dividend shifted left
                SR <= {1'b0, abs_dividend, 8'b0};
                
                // Prepare negated divisor
                NEG_DIVISOR <= {1'b1, ~abs_divisor + 1'b1, 8'b0};
                
                // Initialize division control signals
                cnt <= 4'b0001;
                start_cnt <= 1'b1;
                res_valid <= 1'b0;
            end
            
            // Division process
            else if (start_cnt) begin
                // Subtract NEG_DIVISOR from SR
                SR <= SR + NEG_DIVISOR;
                
                // Shift left and insert carry/borrow
                SR <= {SR[16:1], ~SR[16]};
                
                // Increment counter
                cnt <= cnt + 1'b1;
                
                // Check if division is complete
                if (cnt == 4'b1000) begin
                    start_cnt <= 1'b0;
                    res_valid <= 1'b1;
                    
                    // Handle sign correction for signed division
                    if (sign) begin
                        // Correct quotient sign based on dividend and divisor signs
                        if (dividend_sign ^ divisor_sign)
                            SR[8:1] <= -SR[8:1];
                        
                        // Correct remainder sign
                        if (dividend_sign)
                            SR[16:9] <= -SR[16:9];
                    end
                end
            end
            
            // Reset res_valid when result is consumed
            if (res_valid && res_ready) begin
                res_valid <= 1'b0;
            end
        end
    end
endmodule