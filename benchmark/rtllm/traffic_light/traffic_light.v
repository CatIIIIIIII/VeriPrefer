module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output wire [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

    // State encoding
    localparam 
        IDLE = 2'b00,
        S1_RED = 2'b01,
        S2_YELLOW = 2'b10,
        S3_GREEN = 2'b11;

    // Internal registers
    reg [7:0] cnt;
    reg [1:0] state;
    reg p_red, p_yellow, p_green;

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            p_red <= 1'b0;
            p_yellow <= 1'b0;
            p_green <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    state <= S1_RED;
                    p_red <= 1'b1;
                    p_yellow <= 1'b0;
                    p_green <= 1'b0;
                end

                S1_RED: begin
                    if (cnt == 0) begin
                        state <= S3_GREEN;
                        p_red <= 1'b0;
                        p_yellow <= 1'b0;
                        p_green <= 1'b1;
                    end
                end

                S2_YELLOW: begin
                    if (cnt == 0) begin
                        state <= S1_RED;
                        p_red <= 1'b1;
                        p_yellow <= 1'b0;
                        p_green <= 1'b0;
                    end
                end

                S3_GREEN: begin
                    if (cnt == 0) begin
                        state <= S2_YELLOW;
                        p_red <= 1'b0;
                        p_yellow <= 1'b1;
                        p_green <= 1'b0;
                    end
                end
            endcase
        end
    end

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10;
        end
        else begin
            if (pass_request && green) begin
                // Shorten green time to 10 clocks if requested
                cnt <= (cnt > 10) ? 8'd10 : cnt;
            end
            else begin
                case (state)
                    S1_RED:    cnt <= (p_red && cnt == 0) ? 8'd10 : cnt - 1;
                    S2_YELLOW: cnt <= (p_yellow && cnt == 0) ? 8'd5 : cnt - 1;
                    S3_GREEN:  cnt <= (p_green && cnt == 0) ? 8'd60 : cnt - 1;
                    default:   cnt <= 8'd10;
                endcase
            end
        end
    end

    // Output signals
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red <= 1'b0;
            yellow <= 1'b0;
            green <= 1'b0;
        end
        else begin
            red <= p_red;
            yellow <= p_yellow;
            green <= p_green;
        end
    end

    // Clock output assignment
    assign clock = cnt;

endmodule