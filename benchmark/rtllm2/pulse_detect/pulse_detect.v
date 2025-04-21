module pulse_detect(    
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);
reg [2:0] state;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= 3'b000;
        data_out <= 1'b0;
    end
    else begin
        case (state)
            3'b000: begin
                if (data_in) begin
                    state <= 3'b001;
                end
                else begin
                    state <= 3'b000;
                end
                data_out <= 1'b0;
            end
            3'b001: begin
                if (~data_in) begin
                    state <= 3'b010;
                end
                else begin
                    state <= 3'b001;
                end
                data_out <= 1'b0;
            end
            3'b010: begin
                if (data_in) begin
                    state <= 3'b011;
                end
                else begin
                    state <= 3'b000;
                end
                data_out <= 1'b1;
            end
            3'b011: begin
                if (~data_in) begin
                    state <= 3'b100;
                end
                else begin
                    state <= 3'b011;
                end
                data_out <= 1'b0;
            end
            3'b100: begin
                if (data_in) begin
                    state <= 3'b101;
                end
                else begin
                    state <= 3'b000;
                end
                data_out <= 1'b0;
            end
            3'b101: begin
                if (data_in) begin
                    state <= 3'b101;
                end
                else begin
                    state <= 3'b000;
                end
                data_out <= 1'b0;
            end
            default: begin
                state <= 3'b000;
                data_out <= 1'b0;
            end
        endcase
    end
end

endmodule