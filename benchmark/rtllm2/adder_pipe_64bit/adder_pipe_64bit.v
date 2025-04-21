module adder_pipe_64bit
#(
    parameter DATA_WIDTH = 64,
    parameter STG_WIDTH = 16
)
(
    input clk,
    input rst_n,
    input i_en,
    input [DATA_WIDTH-1:0] adda,
    input [DATA_WIDTH-1:0] addb,
    output [DATA_WIDTH:0] result,
    output reg o_en
);
reg [DATA_WIDTH-1:0] adda_r1, addb_r1;
reg i_en_r1, i_en_r2, i_en_r3;

wire [DATA_WIDTH:0] sum_stg1, sum_stg2, sum_stg3, sum_stg4;

// Pipeline stage 1
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_r1 <= 0;
        addb_r1 <= 0;
        i_en_r1 <= 0;
    end else begin
        adda_r1 <= adda;
        addb_r1 <= addb;
        i_en_r1 <= i_en;
    end
end

// Pipeline stage 2
assign sum_stg1 = i_en_r1 ? {1'b0, adda_r1} + {1'b0, addb_r1} : 0;

// Pipeline stage 3
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i_en_r2 <= 0;
    end else begin
        i_en_r2 <= i_en_r1;
    end
end

// Pipeline stage 4
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i_en_r3 <= 0;
    end else begin
        i_en_r3 <= i_en_r2;
    end
end

// Output stage
assign result = i_en_r3 ? sum_stg1 : 0;

// Output enable signal
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        o_en <= 0;
    end else begin
        o_en <= i_en_r3;
    end
end

endmodule