
module top_module
(
    input clk,
    input areset,
    input predict_valid,
    input predict_taken,
    output logic [31:0] predict_history,
    
    input train_mispredicted,
    input train_taken,
    input [31:0] train_history
);

    logic [31:0] next_predict_history;

    // Asynchronous reset
    always_ff @(posedge clk or posedge areset) begin
        if (areset) begin
            predict_history <= 32'b0;
        end else begin
            predict_history <= next_predict_history;
        end
    end

    // Determine the next state of the history register
    always_comb begin
        if (train_mispredicted) begin
            // Misprediction occurred, load the history after the mispredicted branch
            next_predict_history = {train_history[30:0], train_taken};
        end else if (predict_valid) begin
            // Prediction occurred, shift in the prediction result
            next_predict_history = {predict_history[30:0], predict_taken};
        end else begin
            // No prediction or misprediction, keep the current history
            next_predict_history = predict_history;
        end
    end

endmodule
