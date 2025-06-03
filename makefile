VSIM_PATH = ~/.intelFPGA/20.1/modelsim_ase/linuxaloem/vsim
QUARTUS_PATH = ~/.intelFPGA_lite/24.1std/quartus/bin/quartus_sh
PROJECT_NAME = stream_xbar

test:
	$(VSIM_PATH) -c -do ./tests/run_sim.do

compile:
	$(QUARTUS_PATH) --flow compile $(PROJECT_NAME)
