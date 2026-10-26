VERILATOR = verilator

BUILD_DIR = build

.PHONY: alu alu_control reg_file controlUnit pc immediate_gen cpu cpu_wave lint test clean

alu:
	mkdir -p $(BUILD_DIR)/alu
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/alu \
		--top-module alu_tb \
		rtl/alu.sv tb/alu_tb.sv
	./$(BUILD_DIR)/alu/Valu_tb

alu_control:
	mkdir -p $(BUILD_DIR)/alu_control
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/alu_control \
		--top-module alu_control_tb \
		rtl/alu_op.sv tb/alu_control_tb.sv
	./$(BUILD_DIR)/alu_control/Valu_control_tb

reg_file:
	mkdir -p $(BUILD_DIR)/reg_file
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/reg_file \
		--top-module reg_file_tb \
		rtl/reg_file.sv tb/reg_file_tb.sv
	./$(BUILD_DIR)/reg_file/Vreg_file_tb

controlUnit:
	mkdir -p $(BUILD_DIR)/controlUnit
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/controlUnit \
		--top-module controlUnit_tb \
		rtl/controlUnit.sv rtl/alu_op.sv tb/controlUnit_tb.sv
	./$(BUILD_DIR)/controlUnit/VcontrolUnit_tb

pc:
	mkdir -p $(BUILD_DIR)/pc
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/pc \
		--top-module pc_tb \
		rtl/pc.sv tb/pc_tb.sv
	./$(BUILD_DIR)/pc/Vpc_tb

immediate_gen:
	mkdir -p $(BUILD_DIR)/immediate_gen
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/immediate_gen \
		--top-module immediate_gen_tb \
		rtl/immediate_gen.sv tb/immediate_gen_tb.sv
	./$(BUILD_DIR)/immediate_gen/Vimmediate_gen_tb

cpu:
	mkdir -p $(BUILD_DIR)/cpu
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/cpu \
		--top-module cpu_tb \
		rtl/*.sv tb/cpu_tb.sv
	./$(BUILD_DIR)/cpu/Vcpu_tb

cpu_wave:
	mkdir -p $(BUILD_DIR)/cpu_wave
	$(VERILATOR) --binary --timing --trace -DWAVES \
		--Mdir $(BUILD_DIR)/cpu_wave \
		--top-module cpu_tb \
		rtl/*.sv tb/cpu_tb.sv
	./$(BUILD_DIR)/cpu_wave/Vcpu_tb

lint:
	$(VERILATOR) --lint-only --top-module cpu rtl/*.sv
	$(VERILATOR) --lint-only --top-module datapath rtl/*.sv

test: alu alu_control reg_file controlUnit pc immediate_gen cpu

clean:
	rm -rf $(BUILD_DIR)
