# OTBN Vectorized ISA Testbench
The modules enabling the vectorized computations are tested individually with a QuestaSim 2023.4 testbench.
These testbenches cover the basic operations.

## How to build and run the testbenches
To compile any testbench run the compile script with QuestaSim
```
questa-2023.4 vsim -do "compile.tcl ./<dut>/dut_file.list ./<dut>/tb_file.list"
```
where `<dut>` is the folder of the tested module (i.e. `otbn_vec_adder_tb`).
The order of the `file.list` parameters is fix.

Then run the simulation in QuestaSim with
```
do runsim.tcl <testbench>
```
where `<testbench>` is the name of the testbench (i.e. `otbn_vec_adder_tb`)

## Details of testbenches
There are following common elements
- `clk_rst_gen.sv`: This module generates clean clock and reset signals using the `rst_gen.sv` module.
- `rst_gen.sv`: Synchronous Reset Generator which generates reset signals synchronous to a reference clock.

### File lists
The file lists are relative to the path of vsim invocation despite they are located inside the module testbench directory.
In this case from `otbn/pre_dv`.
