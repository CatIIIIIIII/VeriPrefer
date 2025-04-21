
module top_module (
	input cpu_overheated,
	output reg shut_off_computer,
	input arrived,
	input gas_tank_empty,
	output reg keep_driving
);

	// Always block to control the "shut_off_computer" output
	always @(cpu_overheated) begin
		if (cpu_overheated) begin
			shut_off_computer = 1;
		end else begin
			shut_off_computer = 0;
		end
	end

	// Always block to control the "keep_driving" output
	always @(arrived, gas_tank_empty) begin
		if (!arrived) begin
			keep_driving = ~gas_tank_empty;
		end else begin
			keep_driving = 0;
		end
	end

endmodule
