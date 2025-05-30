`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
module reference_module (
	input clk,
	input x,
	input [2:0] y,
	output reg Y0,
	output reg z
);

	always_comb begin
		case ({y[2:0], x})
			4'h0: Y0 = 0;
			4'h1: Y0 = 1;
			4'h2: Y0 = 1;
			4'h3: Y0 = 0;
			4'h4: Y0 = 0;
			4'h5: Y0 = 1;
			4'h6: Y0 = 1;
			4'h7: Y0 = 0;
			4'h8: Y0 = 1;
			4'h9: Y0 = 0;
			default: Y0 = 1'bx;
		endcase
		
		case (y[2:0])
			3'h0: z = 0;
			3'h1: z = 0;
			3'h2: z = 0;
			3'h3: z = 1;
			3'h4: z = 1;
			default: z = 1'bx;
		endcase
	end
	
endmodule


module stimulus_gen (
	input clk,
	output logic x,
	output logic [2:0] y
);

	initial begin
		repeat(200) @(posedge clk, negedge clk) begin
			y <= $random;
			x <= $random;
		end
		
		#1 $finish;
	end
	
endmodule

module testbench;

	typedef struct packed {
		int errors;
		int errortime;
		int errors_Y0;
		int errortime_Y0;
		int errors_z;
		int errortime_z;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic x;
	logic [2:0] y;
	logic Y0_ref;
	logic Y0_dut;
	logic z_ref;
	logic z_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,x,y,Y0_ref,Y0_dut,z_ref,z_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.x,
		.y );
	reference_module good1 (
		.clk,
		.x,
		.y,
		.Y0(Y0_ref),
		.z(z_ref) );
		
	top_module top_module1 (
		.clk,
		.x,
		.y,
		.Y0(Y0_dut),
		.z(z_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_Y0) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "Y0", stats1.errors_Y0, stats1.errortime_Y0);
		else $display("Hint: Output '%s' has no mismatches.", "Y0");
		if (stats1.errors_z) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "z", stats1.errors_z, stats1.errortime_z);
		else $display("Hint: Output '%s' has no mismatches.", "z");

		if (stats1.errors == 0) begin
			$display("Your Design Passed");
		end else begin
			$display("Your Design Failed");
		end
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { Y0_ref, z_ref } === ( { Y0_ref, z_ref } ^ { Y0_dut, z_dut } ^ { Y0_ref, z_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (Y0_ref !== ( Y0_ref ^ Y0_dut ^ Y0_ref ))
		begin if (stats1.errors_Y0 == 0) stats1.errortime_Y0 = $time;
			stats1.errors_Y0 = stats1.errors_Y0+1'b1; end
		if (z_ref !== ( z_ref ^ z_dut ^ z_ref ))
		begin if (stats1.errors_z == 0) stats1.errortime_z = $time;
			stats1.errors_z = stats1.errors_z+1'b1; end

	end
endmodule
