
.PHONY: modelsim sim clean

TEST_DESIGN = accu

modelsim:
		vlib work
		vlog +acc -work work -sv 2012_q1g.v testbench.v

sim:
		vsim -c -do "run -all; quit" testbench

clean:
		rm -rf *.log  work transcript vsim.wlf *.vcd
