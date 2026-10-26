# Verification and Waveforms

## Requirements

- Verilator
- GNU Make
- GTKWave to view VCD waveforms

On macOS, install GTKWave with Homebrew if it is not already installed:

```sh
brew install gtkwave
```

## Run checks

From the repository root:

```sh
make lint       # Elaborate/lint the CPU and datapath
make cpu        # Build and run the integrated CPU test
make test       # Run component tests and the CPU integration test
```

The CPU testbench loads a directed program, clocks the processor, and fails with
`$fatal` if its PC, register, memory, branch, jump, or reset checks do not match
expectations.

## Generate and inspect a waveform

Build and run the CPU test with tracing enabled:

```sh
make cpu_wave
```

This creates `build/cpu_wave/cpu.vcd`. Open it in GTKWave:

```sh
gtkwave build/cpu_wave/cpu.vcd
```

In GTKWave, expand `cpu_tb` and `dut` in the signal hierarchy and add signals
to the waveform pane. Useful signals to start with:

- `clk`, `rst`, and `pc_value` from the testbench
- `dut.instruction` and `dut.pc`
- `dut.datapath1.pc_next`, `dut.datapath1.pc_next_sel`, and
  `dut.datapath1.take_branch`
- `dut.datapath1.alu_result`, `dut.datapath1.reg_write_data`, and
  `dut.datapath1.mem_data`
- `dut.regWrite`, `dut.memWrite`, `dut.branch`, and `dut.jump`
- Register-file entries under `dut.datapath1.reg_file_inst.registers`
- Data-memory words under `dut.datapath1.data_mem_inst.mem`

Use the time controls to zoom into a clock edge, then compare the current PC and
instruction against the next-PC selection and state updates at that edge.
VCDs and build outputs are generated files and are ignored by Git; do not
commit them unless you intentionally want to publish a waveform artifact.

## Updating project status on GitHub

Keep the README's supported-instruction list and development checklist current
as features and tests are added. For each change, record what behavior was
implemented, which tests cover it, and any known limitations. Keep task-specific
design decisions or test procedures in this document, and link longer design
notes here from the README.

When ready to publish progress, review the changes, run `make test` and
`make lint`, then commit and push the source and documentation. Use GitHub Issues
for larger follow-up tasks and check off README items only after implementation
and verification are complete.
