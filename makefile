VERILATOR = verilator

BUILD_DIR = build

.PHONY: alu reg_file test clean

alu:
	mkdir -p $(BUILD_DIR)/alu
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/alu \
		--top-module alu_tb \
		rtl/alu.sv tb/alu_tb.sv
	./$(BUILD_DIR)/alu/Valu_tb

reg_file:
	mkdir -p $(BUILD_DIR)/reg_file
	$(VERILATOR) --binary --timing \
		--Mdir $(BUILD_DIR)/reg_file \
		--top-module reg_file_tb \
		rtl/reg_file.sv tb/reg_file_tb.sv
	./$(BUILD_DIR)/reg_file/Vreg_file_tb

test: alu reg_file

clean:
	rm -rf $(BUILD_DIR)