.PHONY: modelsim sim clean

TEST_DESIGN = comparator_3bit

modelsim:
	vlib work
	vlog +acc -work work -sv ${TEST_DESIGN}.v testbench.v

sim:
	vsim -c -do "run -all; quit" testbench

clean:
	rm -rf *.log work transcript vsim.wlf *.vcd
