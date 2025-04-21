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

    // Internal signals
    reg [DATA_WIDTH-1:0] adda_stg [3:0];
    reg [DATA_WIDTH-1:0] addb_stg [3:0];
    reg [DATA_WIDTH:0] sum_stg [3:0];
    reg [3:0] en_stg;
    
    // Stage 0 - Input Stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_stg[0] <= 'b0;
            addb_stg[0] <= 'b0;
            en_stg[0] <= 1'b0;
        end else begin
            adda_stg[0] <= adda;
            addb_stg[0] <= addb;
            en_stg[0] <= i_en;
        end
    end

    // Stage 1 - First Partial Addition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_stg[1] <= 'b0;
            addb_stg[1] <= 'b0;
            sum_stg[1] <= 'b0;
            en_stg[1] <= 1'b0;
        end else begin
            adda_stg[1] <= adda_stg[0];
            addb_stg[1] <= addb_stg[0];
            sum_stg[1] <= adda_stg[0][STG_WIDTH-1:0] + addb_stg[0][STG_WIDTH-1:0];
            en_stg[1] <= en_stg[0];
        end
    end

    // Stage 2 - Second Partial Addition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_stg[2] <= 'b0;
            addb_stg[2] <= 'b0;
            sum_stg[2] <= 'b0;
            en_stg[2] <= 1'b0;
        end else begin
            adda_stg[2] <= adda_stg[1];
            addb_stg[2] <= addb_stg[1];
            sum_stg[2] <= {1'b0, sum_stg[1][STG_WIDTH-1:0], adda_stg[1][STG_WIDTH-1:0] + addb_stg[1][STG_WIDTH-1:0]};
            en_stg[2] <= en_stg[1];
        end
    end

    // Stage 3 - Final Addition and Output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_stg[3] <= 'b0;
            o_en <= 1'b0;
        end else begin
            sum_stg[3] <= sum_stg[2][DATA_WIDTH:0] + {adda_stg[2][DATA_WIDTH-1:STG_WIDTH], addb_stg[2][DATA_WIDTH-1:STG_WIDTH]};
            o_en <= en_stg[2];
        end
    end

    // Output assignment
    assign result = sum_stg[3];

endmodule