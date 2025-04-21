
module top_module (
	input [4:0] x,  // Corrected to 5-bit input
	output logic f
);

always_comb begin
	case (x)
		5'b00000: f = 1;  // x = 0x0
		5'b00001: f = 1;  // x = 0x1
		5'b00010: f = 0;  // x = 0x2
		5'b00011: f = 0;  // x = 0x3
		5'b00100: f = 1;  // x = 0x4
		5'b00101: f = 1;  // x = 0x5
		5'b00110: f = 1;  // x = 0x6
		5'b00111: f = 0;  // x = 0x7
		5'b01000: f = 0;  // x = 0x8
		5'b01001: f = 0;  // x = 0x9
		5'b01010: f = 0;  // x = 0xA
		5'b01011: f = 0;  // x = 0xB
		5'b01100: f = 1;  // x = 0xC
		5'b01101: f = 0;  // x = 0xD
		5'b01110: f = 1;  // x = 0xE
		5'b01111: f = 1;  // x = 0xF
		default: f = 0;   // Default case, though not strictly necessary for a 16-state block
	endcase
end

endmodule
