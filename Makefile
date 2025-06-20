# RISC-V Superscalar Processor Makefile

# Package files
PKG_FILES = ./src/pkg/riscv_pkg.sv

# Source files
SRC_FILES = ./src/core_model.sv \
           ./src/superscalar_core.sv \
           ./src/instruction_memory.sv \
           ./src/data_memory.sv \
           ./src/fetch_stage.sv \
           ./src/issue_unit.sv \
           ./src/decoder.sv \
           ./src/hazard_unit.sv \
           ./src/register_file.sv \
           ./src/datapath_a.sv \
           ./src/datapath_b.sv \
           ./src/alu.sv

# Testbench files
TB_FILES = ./tb/tb.sv

# All SystemVerilog files
SV_FILES = ${PKG_FILES} ${SRC_FILES}
ALL_FILES = ${SV_FILES} ${TB_FILES}

lint:
	@echo "Running lint checks..."
	verilator --lint-only -Wall --timing -Wno-UNUSED -Wno-CASEINCOMPLETE ${ALL_FILES}

build:
	verilator --binary ${SV_FILES} ${TB_FILES} --top tb -j 0 --trace -Wno-CASEINCOMPLETE 

run: build
	obj_dir/Vtb

wave: run
	gtkwave --dark dump.vcd

clean:
	@echo "Cleaning temp files..."
	rm -f dump.vcd
	rm -rf obj_dir

help:
	@echo "Available targets:"
	@echo "  lint  - Run Verilator lint checks"
	@echo "  build - Build the simulation"
	@echo "  run   - Run the simulation"
	@echo "  wave  - Open waveform viewer"
	@echo "  clean - Clean temporary files"
	@echo "  help  - Show this help"

.PHONY: lint build run wave clean help