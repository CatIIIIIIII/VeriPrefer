
module top_module (
	input clk,
	input reset,
	input w,
	output reg z
);

// Define the states using a 3-bit register
reg [2:0] state;

// Define the state encoding
parameter [2:0] A = 3'b000;
parameter [2:0] B = 3'b001;
parameter [2:0] C = 3'b010;
parameter [2:0] D = 3'b011;
parameter [2:0] E = 3'b100;
parameter [2:0] F = 3'b101;

// State transition logic
always @(posedge clk or posedge reset) begin
	if (reset) begin
		state <= A; // Reset to initial state A
	end else begin
		case (state)
			A: state <= (w) ? B : A;
			B: state <= (w) ? C : D;
			C: state <= (w) ? E : D;
			D: state <= (w) ? F : A;
			E: state <= (w) ? E : D;
			F: state <= (w) ? C : D;
			default: state <= A; // Default case to ensure safety
		endcase
	end
end

// Output logic
always @(*) begin
	case (state)
		E: z = 1;
		F: z = 1;
		default: z = 0;
	endcase
end

endmodule
