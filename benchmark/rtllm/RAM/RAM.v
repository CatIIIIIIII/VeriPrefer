module RAM #(
    parameter WIDTH = 6,
    parameter DEPTH = 8
)(
    input clk,
    input rst_n,
    
    input write_en,
    input [DEPTH-1:0] write_addr,
    input [WIDTH-1:0] write_data,
    
    input read_en,
    input [DEPTH-1:0] read_addr,
    output reg [WIDTH-1:0] read_data
);

    // RAM Array declaration
    reg [WIDTH-1:0] RAM [(1 << DEPTH) - 1:0];

    // Initialization block
    integer i;
    initial begin
        for (i = 0; i < (1 << DEPTH); i = i + 1) begin
            RAM[i] = {WIDTH{1'b0}}; // Initialize all memory locations to 000000
        end
    end

    // Write Operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all memory locations to 0 when rst_n is low
            for (i = 0; i < (1 << DEPTH); i = i + 1) begin
                RAM[i] <= {WIDTH{1'b0}};
            end
        end else begin
            // Write operation
            if (write_en) begin
                RAM[write_addr] <= write_data;
            end
        end
    end

    // Read Operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear read_data when rst_n is low
            read_data <= {WIDTH{1'b0}};
        end else begin
            // Read operation
            if (read_en) begin
                read_data <= RAM[read_addr];
            end else begin
                read_data <= {WIDTH{1'b0}};
            end
        end
    end

endmodule