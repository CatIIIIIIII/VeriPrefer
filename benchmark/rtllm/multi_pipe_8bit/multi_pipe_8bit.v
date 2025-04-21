module multi_pipe_8bit #(
    parameter size = 8
)(
    input wire clk,           
    input wire rst_n, 
    input wire mul_en_in,      
    input wire [size-1:0] mul_a,       
    input wire [size-1:0] mul_b,       

    output reg mul_en_out,  
    output reg [size*2-1:0] mul_out    
);

    // Internal signals and registers
    reg [3:0] mul_en_out_reg;
    reg [size-1:0] mul_a_reg;
    reg [size-1:0] mul_b_reg;
    
    // Partial product generation wires
    wire [size*2-1:0] temp [size-1:0];
    
    // Partial sum registers
    reg [size*2-1:0] sum [size-1:0];
    reg [size*2-1:0] mul_out_reg;

    // Generate partial products
    genvar i, j;
    generate
        for (i = 0; i < size; i = i + 1) begin : partial_product_gen
            assign temp[i] = mul_b_reg[i] ? (mul_a_reg << i) : {size*2{1'b0}};
        end
    endgenerate

    // Pipeline stage 1: Input registration and partial product generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_a_reg <= {size{1'b0}};
            mul_b_reg <= {size{1'b0}};
            mul_en_out_reg <= 4'b0;
        end else if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
            mul_en_out_reg <= {mul_en_out_reg[2:0], mul_en_in};
        end
    end

    // Pipeline stage 2: Partial sum calculation
    generate
        for (i = 0; i < size; i = i + 1) begin : partial_sum_stage
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    sum[i] <= {size*2{1'b0}};
                end else begin
                    sum[i] <= temp[i];
                end
            end
        end
    endgenerate

    // Pipeline stage 3: Final product accumulation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= {size*2{1'b0}};
            mul_en_out <= 1'b0;
        end else begin
            // Accumulate partial sums
            mul_out_reg <= sum[0] + sum[1] + sum[2] + sum[3] +
                           sum[4] + sum[5] + sum[6] + sum[7];
            
            // Generate output enable signal
            mul_en_out <= mul_en_out_reg[3];
        end
    end

    // Output assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= {size*2{1'b0}};
        end else begin
            mul_out <= mul_en_out ? mul_out_reg : {size*2{1'b0}};
        end
    end

endmodule