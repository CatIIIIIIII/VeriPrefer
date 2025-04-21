module up_down_counter (
    input wire clk,
    input wire reset,
    input wire up_down,
    output reg [15:0] count
);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        count <= 16'b0;
    end else begin
        if (up_down) begin
            count <= count + 1'b1;
        end else begin
            count <= count - 1'b1;
        end
    end
end

endmodule