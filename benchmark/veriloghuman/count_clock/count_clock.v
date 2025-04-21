
module top_module(
    input clk,
    input reset,
    input ena,
    output reg pm,
    output reg [7:0] hh,
    output reg [7:0] mm,
    output reg [7:0] ss
);

// Internal signals
reg [3:0] hour, minute, second;

// Clock process
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset to 12:00 AM
        pm <= 0;
        hour <= 4'b0001; // 1 in BCD
        minute <= 4'b0000; // 0 in BCD
        second <= 4'b0000; // 0 in BCD
    end else if (ena) begin
        // Increment seconds
        if (second == 4'b1001) begin // 9 in BCD
            second <= 4'b0000; // 0 in BCD
            // Increment minutes
            if (minute == 4'b1001) begin // 9 in BCD
                minute <= 4'b0000; // 0 in BCD
                // Increment hours
                if (hour == 4'b1001) begin // 9 in BCD
                    hour <= 4'b0001; // 1 in BCD
                    pm <= ~pm; // Toggle AM/PM
                end else begin
                    hour <= hour + 1;
                end
            end else begin
                minute <= minute + 1;
            end
        end else begin
            second <= second + 1;
        end
    end
end

// Assign BCD outputs
assign hh = {hour, 4'b0000};
assign mm = {minute, 4'b0000};
assign ss = {second, 4'b0000};

endmodule
