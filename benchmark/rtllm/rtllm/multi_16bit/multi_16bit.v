
module multi_16bit(
    input clk,          // Chip clock signal.
    input rst_n,        // Active-low reset signal. Defined as 0 for chip reset; defined as 1 for reset signal inactive.
    input start,        // Chip enable signal. 
    input [15:0] ain,   // Input a (multiplicand) with a data width of 16 bits.
    input [15:0] bin,   // Input b (multiplier) with a data width of 16 bits.

    output [31:0] yout, // Product output with a data width of 32 bits.
    output done         // Chip output flag signal. Defined as 1 indicates multiplication operation completion.
);
    reg [4:0] i;    

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            i <= 0;
        else if(start && i < 17) 
            i <= i + 1;
        else if(!start)
            i <= 0;
    end

    reg done_r;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            done_r <= 0;
        else if(i == 16) 
            done_r <= 1;
        else if(i == 17) 
            done_r <= 0;
    end

    reg [15:0] areg, breg;
    reg [31:0] yout_r;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            areg <= 0;
            breg <= 0;
            yout_r <= 0;
        end
        else if(start) begin
            if(i == 0) begin 
                areg <= ain;
                breg <= bin;
            end
            else if(i > 0 && i < 17) begin 
                if(areg[i-1]) 
                    yout_r <= yout_r + ({breg,17'b0} >> i);
            end
        end
        else begin 
            areg <= 0;
            breg <= 0;
            yout_r <= 0;
        end
    end

    assign done = done_r;
    assign yout = yout_r;

endmodule