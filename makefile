QUARTUS_PATH = ~/.intelFPGA_lite/24.1std/quartus/bin/
PROJECT_NAME = crossbar
DEVICE = 5CEBA2F17A7

test:
	~/.intelFPGA/20.1/modelsim_ase/linuxaloem/vsim -c -do run_sim.do

compile:
	$(QUARTUS_PATH)/quartus_sh --flow compile $(PROJECT_NAME).qpf

reports:
	cat ./output_files/*.summary

synthesis: compile reports
