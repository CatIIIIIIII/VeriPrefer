module fsm(
    input wire IN,
    input wire CLK,
    input wire RST,
    output reg MATCH
);

    // Define state encoding
    localparam [2:0] 
        S0 = 3'b000,
        S1 = 3'b001,
        S2 = 3'b010,
        S3 = 3'b011,
        S4 = 3'b100,
        S5 = 3'b101;

    // State register
    reg [2:0] current_state, next_state;

    // State transition and output logic
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            // Reset state
            current_state <= S0;
            MATCH <= 1'b0;
        end
        else begin
            // State transition
            current_state <= next_state;
            
            // Output logic (Mealy machine)
            case(current_state)
                S5: MATCH <= (IN == 1'b1);
                default: MATCH <= 1'b0;
            endcase
        end
    end

    // Next state and output logic
    always @(*) begin
        // Default next state
        next_state = current_state;
        
        case(current_state)
            S0: begin
                if (IN == 1'b1)
                    next_state = S1;
            end
            
            S1: begin
                if (IN == 1'b0)
                    next_state = S2;
                else
                    next_state = S1;
            end
            
            S2: begin
                if (IN == 1'b0)
                    next_state = S3;
                else
                    next_state = S1;
            end
            
            S3: begin
                if (IN == 1'b1)
                    next_state = S4;
                else
                    next_state = S0;
            end
            
            S4: begin
                if (IN == 1'b1)
                    next_state = S5;
                else
                    next_state = S0;
            end
            
            S5: begin
                if (IN == 1'b1)
                    next_state = S1;
                else
                    next_state = S0;
            end
            
            default: 
                next_state = S0;
        endcase
    end

endmodule