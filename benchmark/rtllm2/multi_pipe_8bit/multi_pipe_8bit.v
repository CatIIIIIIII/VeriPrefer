module multi_pipe_8bit#(
    parameter size = 8
)(
          clk,      
          rst_n,       
          mul_a,       
          mul_b, 
          mul_en_in,
 
          mul_en_out,      
          mul_out    
);
   input clk;           
   input rst_n; 
   input mul_en_in;      
   input [size-1:0] mul_a;       
   input [size-1:0] mul_b;       
 
   output reg mul_en_out;  
   output reg [size*2-1:0] mul_out;    
reg [size-1:0] mul_a_reg, mul_b_reg;
   reg [size-1:0] mul_en_out_reg;
   wire [size-1:0] temp [size-1:0];
   reg [size-1:0] sum [size-1:0];
   reg [size*2-1:0] mul_out_reg;

   integer i, j;

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         mul_en_out_reg <= 0;
         mul_a_reg <= 0;
         mul_b_reg <= 0;
      end else begin
         mul_en_out_reg <= {mul_en_out_reg[size-2:0], mul_en_in};
         mul_a_reg <= mul_a;
         mul_b_reg <= mul_b;
      end
   end

   assign mul_en_out = mul_en_out_reg[size-1];

   genvar k;
   generate
      for (k = 0; k < size; k = k + 1) begin : gen_temp
         assign temp[k] = mul_b_reg[k] ? mul_a_reg : {size{1'b0}};
      end
   endgenerate

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         for (i = 0; i < size; i = i + 1) begin
            sum[i] <= 0;
         end
      end else begin
         for (i = 0; i < size; i = i + 1) begin
            sum[i] <= (i == 0) ? temp[0] : (sum[i-1] + temp[i]);
         end
      end
   end

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         mul_out_reg <= 0;
      end else begin
         mul_out_reg <= sum[size-1];
      end
   end

   always @(*) begin
      if (mul_en_out) begin
         mul_out = mul_out_reg;
      end else begin
         mul_out = 0;
      end
   end

endmodule