
module top_module(
    input clk, 
    input load, 
    input [9:0] data, 
    output reg tc
);

reg [9:0] counter;

always @(posedge clk) begin
    if (load) begin
        // Load the counter with the new data
        counter <= data;
        // Clear the terminal count signal
        tc <= 0;
    end else if (counter > 0) begin
        // Decrement the counter if it is greater than 0
        counter <= counter - 1;
    end else begin
        // Assert the terminal count signal when counter reaches 0
        tc <= 1;
    end
end

endmodule
