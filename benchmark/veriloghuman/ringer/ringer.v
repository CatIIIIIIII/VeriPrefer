
module top_module(
    input ring, 
    input vibrate_mode,
    output reg ringer,
    output reg motor
);

always @(*) begin
    if (vibrate_mode) begin
        // If vibrate mode is enabled, turn on the motor and turn off the ringer
        motor = 1;
        ringer = 0;
    end else begin
        // If vibrate mode is disabled, turn on the ringer and turn off the motor
        motor = 0;
        ringer = ring;
    end
end

endmodule
