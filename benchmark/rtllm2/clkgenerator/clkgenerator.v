module clkgenerator (
    output reg clk
);

    parameter PERIOD = 10; // Clock period in time units
initial begin
        clk = 0;
    end

    always begin
        #(PERIOD/2) clk = ~clk;
    end

endmodule