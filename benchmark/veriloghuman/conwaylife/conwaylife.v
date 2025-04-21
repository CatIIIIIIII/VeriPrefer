
module top_module(
    input clk,
    input load,
    input [255:0] data,
    output reg [255:0] q
);

// Internal register to store the next state
reg [255:0] next_q;

// Function to count the number of alive neighbors for a given cell
function integer count_neighbors;
    input [255:0] grid;
    input [7:0] row;
    input [3:0] col;
    integer count;
    integer r, c;

    count = 0;
    for (r = -1; r <= 1; r = r + 1) begin
        for (c = -1; c <= 1; c = c + 1) begin
            if (r == 0 && c == 0) continue; // Skip the cell itself
            count = count + grid[((row + r) % 16) * 16 + ((col + c) % 16)];
        end
    end
    count_neighbors = count;
endfunction

// Process to update the grid state
always @(posedge clk) begin
    if (load) begin
        q <= data;
    end else begin
        for (integer i = 0; i < 16; i = i + 1) begin
            for (integer j = 0; j < 16; j = j + 1) begin
                integer neighbors = count_neighbors(q, i, j);
                if (neighbors == 3) begin
                    next_q[i * 16 + j] = 1;
                end else if (neighbors == 2) begin
                    next_q[i * 16 + j] = q[i * 16 + j];
                end else begin
                    next_q[i * 16 + j] = 0;
                end
            end
        end
        q <= next_q;
    end
end

endmodule
