module edge_detect_tb();
    reg clk, rst_n, a;
    wire rise, down;

    // Instantiate the module
    edge_detect uut(
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .rise(rise),
        .down(down)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize
        rst_n = 0;
        a = 0;

        // Release reset
        #10 rst_n = 1;

        // Test rising edge
        #10 a = 1;
        #10 a = 0;

        // Test falling edge
        #10 a = 1;
        #10 a = 0;

        #20 $finish;
    end

    // Optional: Waveform dump
    initial begin
        $dumpfile("edge_detect_tb.vcd");
        $dumpvars(0, edge_detect_tb);
    end
endmodule