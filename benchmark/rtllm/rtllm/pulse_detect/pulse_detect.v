
module pulse_detect(    
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);
    reg [2:0] state;
    reg [2:0] next_state;
    parameter s0 = 3'b000;
    parameter s1 = 3'b001;
    parameter s2 = 3'b010;
    parameter s3 = 3'b011;
    parameter s4 = 3'b100;
    parameter s5 = 3'b101;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= s0;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            s0: begin
                if (data_in == 1) begin
                    next_state = s1;
                end
                else begin
                    next_state = s0;
                end
            end
            s1: begin
                if (data_in == 0) begin
                    next_state = s2;
                end
                else begin
                    next_state = s1;
                end
            end
            s2: begin
                if (data_in == 1) begin
                    next_state = s3;
                end
                else begin
                    next_state = s0;
                end
            end
            s3: begin
                if (data_in == 0) begin
                    next_state = s4;
                end
                else begin
                    next_state = s1;
                end
            end
            s4: begin
                if (data_in == 1) begin
                    next_state = s5;
                end
                else begin
                    next_state = s0;
                end
            end
            s5: begin
                if (data_in == 0) begin
                    next_state = s2;
                end
                else begin
                    next_state = s1;
                end
            end
            default: begin
                next_state = s0;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            data_out <= 0;
        end
        else begin
            if (state == s5 && next_state == s2) begin
                data_out <= 1;
            end
            else begin
                data_out <= 0;
            end
        end
    end

endmodule