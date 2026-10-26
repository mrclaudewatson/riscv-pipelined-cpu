# riscv_cpu
Single-cycle RISC-V CPU (pipeline planned)

A 32-bit RISC-V processor implemented in SystemVerilog, targeting the RV32I base integer instruction set.

This project is being developed from the ground up as a hands-on exploration of CPU microarchitecture, RTL design, pipelining, and hardware verification. Development begins with individually designed and verified processor components and will progress toward a complete 5-stage pipelined processor.

Project Goals

The final processor will implement a classic 5-stage pipeline:

Instruction Fetch (IF) → Instruction Decode (ID) → Execute (EX) → Memory (MEM) → Write Back (WB)

Planned features include:

* RV32I base integer instruction support
* 32-bit datapath
* 5-stage pipelined architecture
* Data forwarding
* Hazard detection and pipeline stalls
* Branch and jump handling
* Pipeline flushing
* SystemVerilog assertions
* Functional coverage
* Automated verification and regression testing
* UVM-based verification environment

Current Status

The current integration is a **single-cycle processor**, not a pipelined CPU.
The `cpu` module in `rtl/cpu.sv` is the synthesizable top-level design; it
connects the controller, ALU decoder, and datapath. The datapath includes the
program counter, instruction and data memories, register file, ALU, and
branch/jump selection.

Implemented instruction behaviors are a partial RV32I subset:

* Register-register integer ALU operations: ADD, SUB, AND, OR, XOR, SLL, SRL,
  SRA, SLT, and SLTU.
* Immediate integer ALU operations: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI,
  SLTI, and SLTIU.
* LUI and AUIPC.
* JAL and JALR.
* BEQ, BNE, BLT, BGE, BLTU, and BGEU.
* LW and SW using aligned 32-bit word accesses only.

This is not full RV32I or an ISA-compliant implementation yet. Byte and
halfword loads/stores, FENCE, SYSTEM instructions and traps are not implemented.
The M, A, and C extensions are also out of scope. Some invalid instruction
encodings are not strictly rejected by the current decoder.

`tb/cpu_tb.sv` is the integrated functional testbench. It initializes the
instruction/data memories and register file in the testbench, then checks PC
flow, register and memory results, branches, jumps, and reset. No additional
top module is needed to begin simulation: run `make cpu` for the integrated
test or `make test` for the component and integration suite. Run `make lint` to
check RTL elaboration. Run `make cpu_wave` to generate a VCD waveform at
`build/cpu_wave/cpu.vcd`; open it with GTKWave. See
[`docs/verification.md`](docs/verification.md) for setup and signal-navigation
guidance.

Each memory contains 256 words (1 KiB). Data memory currently supports aligned
word accesses only; byte/halfword accesses and address/alignment traps remain
future work. Memory contents are supplied by the testbench for simulation.

Verification

RTL components are tested individually and together through directed
SystemVerilog testbenches. The CPU integration test is an initial functional
test, not a complete architectural compliance suite.

Verification will progressively include:

* Directed SystemVerilog testbenches
* Self-checking tests
* Edge-case testing
* SystemVerilog Assertions (SVA)
* Functional coverage
* Constrained-random verification
* Reference-model/scoreboard checking
* Regression testing

Tools

* SystemVerilog
* Verilator
* GTKWave
* Yosys
* Git / GitHub
* Visual Studio Code

Repository Structure

riscv-pipelined-cpu/
├── rtl/        # Synthesizable processor RTL
├── tb/         # Testbenches and verification
└── README.md

The repository structure will expand as additional processor and verification components are implemented.

Development Approach

The processor is being developed incrementally:

1. Design and verify individual RTL components
2. Integrate components into a single-cycle RV32I processor
3. Convert the datapath to a 5-stage pipeline
4. Implement forwarding and hazard handling
5. Expand verification using assertions and functional coverage
6. Develop a UVM-based verification environment
7. Perform synthesis and final design analysis

Status

Work in progress — the current milestone is a tested single-cycle instruction
subset. The five-stage pipeline and its forwarding, hazard, and flush logic are
future work.

## Development checklist

- [x] Integrate the current single-cycle instruction subset.
- [x] Add a self-checking CPU-level testbench.
- [x] Document the supported subset and simulation workflow.
- [ ] Expand CPU tests to cover every implemented ALU operation and immediate form.
- [ ] Tighten instruction decoding and define behavior for unsupported encodings.
- [ ] Load programs from image files instead of only initializing memories hierarchically in the testbench.
- [ ] Complete and verify full RV32I behavior, including byte/halfword memory accesses and required traps.
- [ ] Design and verify the five-stage pipeline, forwarding, stalls, and flushes.
