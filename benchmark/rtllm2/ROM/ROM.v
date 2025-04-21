module ROM (
    input wire [7:0] addr,        // 8-bit Address input
    output reg [15:0] dout        // 16-bit Data output
);

// Declare the ROM as a 2D register array
    reg [15:0] mem [0:255];

    // Initialize the ROM with some example data
    initial begin
        mem[0] = 16'hA0A0;
        mem[1] = 16'hB1B1;
        mem[2] = 16'hC2C2;
        mem[3] = 16'hD3D3;
        // You can add more initializations here
    end

    // Continuous assignment to read from ROM
    always @(*) begin
        dout = mem[addr];
    end

endmodule