
module top_module(
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

	// 128-entry table of two-bit saturating counters
	reg [1:0] pht [0:127];
	// 7-bit global branch history register
	reg [6:0] global_history;

	// Initialize the PHT and global history register on reset
	always @(posedge areset or posedge clk) begin
		if (areset) begin
			for (integer i = 0; i < 128; i = i + 1) begin
				pht[i] <= 2'b00;
			end
			global_history <= 7'b0000000;
		end else begin
			// Update global history register on the next positive clock edge
			if (train_valid) begin
				if (train_taken) begin
					global_history <= {global_history[5:0], 1'b1};
				end else begin
					global_history <= {global_history[5:0], 1'b0};
				end
			end
		end
	end

	// Prediction logic
	always @(*) begin
		if (predict_valid) begin
			// Calculate the index using XOR of PC and global history
			int index = predict_pc ^ global_history;
			// Get the prediction from the PHT
			case (pht[index])
				2'b00: predict_taken = 1'b0;
				2'b01: predict_taken = 1'b0;
				2'b10: predict_taken = 1'b1;
				2'b11: predict_taken = 1'b1;
			endcase
			// Output the current global history for the prediction
			predict_history = global_history;
		end else begin
			predict_taken = 1'b0;
			predict_history = 7'b0000000;
		end
	end

	// Training logic
	always @(posedge clk) begin
		if (train_valid) begin
			// Calculate the index using XOR of PC and global history
			int index = train_pc ^ train_history;
			// Update the PHT based on the actual outcome
			if (train_taken) begin
				if (pht[index] < 2'b11) begin
					pht[index] <= pht[index] + 1;
				end
			end else begin
				if (pht[index] > 2'b00) begin
					pht[index] <= pht[index] - 1;
				end
			end
			// If mispredicted, recover the global history register
			if (train_mispredicted) begin
				global_history <= train_history;
			end
		end
	end

endmodule
