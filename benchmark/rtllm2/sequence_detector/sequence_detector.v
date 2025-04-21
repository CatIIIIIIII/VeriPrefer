module sequence_detector(
     input  clk, 
     input  rst_n,
     input  data_in, 
     output sequence_detected				
     );
// State encoding
    localparam IDLE = 2'b00;
    localparam S1   = 2'b01;
    localparam S2   = 2'b10;
    localparam S3   = 2'b11;
    localparam S4   = 2'b11;

    reg [1:0] current_state, next_state;

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: next_state = (data_in) ? S1 : IDLE;
            S1:   next_state = (data_in) ? S2 : IDLE;
            S2:   next_state = (data_in) ? S2 : S3;
            S3:   next_state = (data_in) ? S4 : IDLE;
            S4:   next_state = (data_in) ? S1 : IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    assign sequence_detected = (current_state == S4);

endmodule