# riscv_cpu
RV32I Pipelined CPU

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

The project is currently under active development.

Completed

* Project structure and Git workflow
* 32-bit combinational ALU
    * ADD
    * SUB
    * AND
    * OR
    * XOR
    * SLL
    * SRL
    * SRA
    * SLT
    * SLTU
* ALU testbench and functional verification

In Progress

* RV32I Immediate Generator

Upcoming

* Register File
* Program Counter logic
* Main Control Unit
* Instruction decoding
* Instruction and Data Memory
* Single-cycle RV32I datapath
* 5-stage pipeline
* Forwarding Unit
* Hazard Detection Unit
* Branch/Jump handling
* SystemVerilog Assertions
* Functional Coverage
* UVM verification environment

Verification

Each major RTL component is being verified individually before integration into the processor datapath.

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

Work in progress — currently developing the processor’s core RTL components.
