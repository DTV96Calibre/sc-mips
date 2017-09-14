# sc-mips
A single cycle MIPS processor implemented with Icarus Verilog

## Design
This processor implementation generally follows the Patterson & Hennessy single cycle CPU, seen below.

![alt text][cpu_diagram]

Most elements in the block diagram are implemented with modules. Exceptions include cases such as the "Shift left 2" elements, which are instead implemented directly with standard verilog syntax. These simplifications take advantage of the capabilities verilog offers.

### ALU
The ALU is easily implemented with a case statement that checks the ALU operation code from the ALU control module and applies the matching operation to the data inputs. These operations are native to verilog and were easily implemented. In order to set the Zero signal, the ALU operation was used to set the ALU result, which could then be compared to zero sequentially.

### ALU control
The ALU control accepts an aluop code from the

### Control
The control module supplies signals controlling the execution of the data pipeline. This module examines the instruction's top six bits (the opcode), and sets the appropriate control signals. Generally this could be done with case statements, though in some cases it was easier to implement with simpler conditional logic.

Additions made to this module that aren't reflected in the above diagram include an "invertzero" signal that causes the ALU Zero signal to be inverted. This allows for the implementation of a number of instructions that requires the ability to detect when two values are not equal, such as in the BNE operation.
<!-- An "alucontrol" signal was also added to allow the detection of R type instructions and the appropriate multiplexing of the aluop code. -->

### Instruction memory
The instruction memory module stores the program to be executed. When running the simulation, a file containing instructions is read into this module's memory, which is than fed into the rest of the processor. This module uses the program counter (PC) to select an instruction set the output.

## Compilation

## Execution

## Testing

[cpu_diagram]: https://lh5.googleusercontent.com/NwP8dOkuRLI_ZRfyuvTKvwxYIAPsh-5ybUH5nD7E9MHUPgUhMHwgy5FYApsfa04WxQVWCCVFi3B92G23vY2J-C6IBIPD_jbU87XDDT4sSBBx3Cg_Al6wVIbieDD8Be8fdw8Upr6UK7KhsTl5rg "Patterson & Hennessy single cycle CPU"
