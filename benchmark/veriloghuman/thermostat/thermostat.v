
module top_module(
	input mode,
	input too_cold, 
	input too_hot,
	input fan_on,
	output heater,
	output aircon,
	output fan
);

assign heater = (mode == 1) && (too_cold == 1);
assign aircon = (mode == 0) && (too_hot == 1);
assign fan = (heater || aircon || fan_on);

endmodule
