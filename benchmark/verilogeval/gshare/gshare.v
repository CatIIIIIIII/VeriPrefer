module TopModule (
  input clk,
  input areset,

  input predict_valid,
  input [6:0] predict_pc,
  output predict_taken,
  output [6:0] predict_history,

  input train_valid,
  input train_taken,
  input train_mispredicted,
  input [6:0] train_history,
  input [6:0] train_pc
);

  reg [1:0] PHT [127:0];
  reg [6:0] global_history;
  wire [6:0] predict_index, train_index;

  assign predict_index = predict_pc ^ global_history;
  assign train_index = train_pc ^ train_history;

  assign predict_taken = PHT[predict_index][1];
  assign predict_history = global_history;

  always @(posedge clk) begin
    if (train_valid) begin
      PHT[train_index] <= train_taken ? (PHT[train_index] == 3 ? 3 : PHT[train_index] + 1) : (PHT[train_index] == 0 ? 0 : PHT[train_index] - 1);
      if (train_mispredicted) begin
        global_history <= train_history;
      end
    end
    if (predict_valid) begin
      global_history <= global_history ^ {1'b1, global_history[6:1]};
    end
  end

endmodule

