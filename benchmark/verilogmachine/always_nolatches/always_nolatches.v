
module top_module (
	input [15:0] scancode,
	output reg left,
	output reg down,
	output reg right,
	output reg up
);

always @(*) begin
    // Initialize all outputs to 0
    left = 0;
    down = 0;
    right = 0;
    up = 0;

    // Check the scancode and set the corresponding output to 1
    case (scancode)
        16'hE06B: left = 1;
        16'hE072: down = 1;
        16'hE074: right = 1;
        16'hE075: up = 1;
        default: ; // Do nothing for other scancodes
    endcase
end

endmodule
