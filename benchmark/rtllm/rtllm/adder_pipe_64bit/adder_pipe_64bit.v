
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
    reg [STG_WIDTH-1:0] i_en_pipe, i_en_pipe_sync;
    reg [DATA_WIDTH-1:0] adda_pipe  [STG_WIDTH-1:0];
    reg [DATA_WIDTH-1:0] addb_pipe  [STG_WIDTH-1:0];
    reg [DATA_WIDTH:0] sum_pipe   [STG_WIDTH-1:0];
    reg [DATA_WIDTH:0] result_pipe [STG_WIDTH-1:0];

    wire [DATA_WIDTH:0] sum_pipe_0;

    assign result = result_pipe[STG_WIDTH-1];

    genvar i;

    generate
        for (i = 0; i < STG_WIDTH; i = i + 1) begin: gen_adder_pipe
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    {i_en_pipe[i], adda_pipe[i], addb_pipe[i], sum_pipe[i], result_pipe[i]} <= 0;
                end
                else begin
                    i_en_pipe[i] <= i_en_pipe_sync[i];
                    adda_pipe[i] <= adda;
                    addb_pipe[i] <= addb;
                    sum_pipe[i] <= sum_pipe_0[i] + adda_pipe[i] + addb_pipe[i];
                    result_pipe[i] <= result_pipe[i-1];
                end
            end
        end
    endgenerate

    always @(*) begin
        i_en_pipe_sync = {STG_WIDTH{1'b0}};
        i_en_pipe_sync[0] = i_en;
    end

    assign sum_pipe_0 = {1'b0, adda} + {1'b0, addb};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_en <= 1'b0;
        end
        else begin
            o_en <= i_en_pipe[STG_WIDTH-1];
        end
    end

endmodule