module pulse_detect(    
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

    // State definitions
    localparam IDLE       = 3'b000;
    localparam FIRST_HIGH = 3'b001;
    localparam SECOND_HIGH= 3'b010;
    localparam FIRST_LOW  = 3'b011;
    localparam SECOND_LOW = 3'b100;

    // State register
    reg [2:0] state, next_state;

    // State transition and output logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            state <= IDLE;
            data_out <= 1'b0;
        end else begin
            // State transition
            state <= next_state;
            
            // Output logic
            if (state == SECOND_LOW)
                data_out <= 1'b1;
            else
                data_out <= 1'b0;
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                // Wait for first high
                if (data_in)
                    next_state = FIRST_HIGH;
                else
                    next_state = IDLE;
            end
            
            FIRST_HIGH: begin
                // Confirm high for at least one cycle
                if (data_in)
                    next_state = SECOND_HIGH;
                else
                    next_state = IDLE;
            end
            
            SECOND_HIGH: begin
                // Wait for first low
                if (!data_in)
                    next_state = FIRST_LOW;
                else
                    next_state = SECOND_HIGH;
            end
            
            FIRST_LOW: begin
                // Confirm low for at least one cycle
                if (!data_in)
                    next_state = SECOND_LOW;
                else
                    next_state = SECOND_HIGH;
            end
            
            SECOND_LOW: begin
                // Reset to IDLE after pulse detection
                next_state = IDLE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule