# sc-mips
A single cycle MIPS processor implemented with Icarus Verilog

## Design
This processor implementation generally follows the Patterson & Hennessy single cycle CPU, seen below.

![alt text][cpu_diagram]

Most elements in the block diagram are implemented with modules. Exceptions include cases such as the "Shift left 2" elements, which are instead implemented directly with standard verilog syntax. These simplifications take advantage of the capabilities verilog offers.

### ALU
The ALU is easily implemented with a case statement that checks the ALU operation code from the ALU control module and applies the matching operation to the data inputs. These operations are native to verilog and were easily implemented. In order to set the Zero signal, the ALU operation was used to set the ALU result, which could then be compared to zero sequentially.

### ALU control
The ALU control examines an "rtype" signal from the Control module in order to select either the aluop code it receives
from the Control module or the aluop code it generates from the functioncode it receives from the instruction. This 
aluop code selection is then sent to the ALU. This module also examines the functioncode and uses it to determine if the
instruction is a syscall. In that case, it sends a 1 over the syscall wire to the Registers module where the syscall is
executed.

### Control
The control module supplies signals controlling the execution of the data pipeline. This module examines the instruction's top six bits (the opcode), and sets the appropriate control signals. Generally this could be done with case statements, though in some cases it was easier to implement with simpler conditional logic.

Additions made to this module that aren't reflected in the above diagram include an "invertzero" signal that causes the ALU Zero signal to be inverted. This allows for the implementation of a number of instructions that requires the ability to detect when two values are not equal, such as in the BNE operation.
An "rtype" signal was also added to allow the detection of R type instructions and the appropriate multiplexing of the aluop code. rtype is 1 when the functioncode should be used to control the alu, and 0 when the aluop code should be gotten from the control module.

### Instruction memory
The instruction memory module stores the program to be executed. When running the simulation, a file containing instructions is read into this module's memory, which is than fed into the rest of the processor. This module uses the program counter (PC) to select an instruction set the output.

### Registers
The registers module contains the register file where the registers are stored. On the clock, registers examines it's
inputs and reads and/or writes to the register file (reg_file). After each write, the zero register is set back to 0
incase it was written to. On initialization the 0 is stored in all the registers. The registers module also includes
logic for executing syscall execution. This allows easy access to a0 and v0 registers, reducing complexity. In the future
this logic will be in a module that is instantiated within the registers module.

### Data memory
Another memory module. Accepts a 32 bit address and data and stores the data when MemWrite is 1. When MemRead is 1, outputs
the data found at the address.

### Add
Adds two 32 bit signals and outputs the result. Used to generate PC+4, but may be used for arbitrary addition.

### and
Ands two 1bit signals and outputs the result. Used to check if both branch and zero is 1, but may be used arbitrarily.

### inverter
A 1bit, signal controlled inverter gate. If and only if the control signal is high, the output is the inverse of the input.

### mux32_2
A 2 input, 32bit multiplexer used throughout the processor to toggle between different signals in the datapath.

### mux1_2
A 2 input, 1bit multiplexer.

### jump_address_constructor
This module accepts the PC+4 signal from the pc_incrementer adder and the 25-0 bits from the instruction. It shifts the
instruction bits to the left by 2 and concatenates on the left and the shift left result on the right. This signal is then
sent to the jump_mux and is used in jump instructions to update the program counter to the new jump address.


## Compilation
Compiling the iverilog simulations requires a valid installation of iverilog on your path. Use the command "iverilog 
tests.v -o tests" to compile the processor and create an executable called "tests". The tests.v file is the main
testing file and uses include statements to include the other relevant verilog files.

## Execution
Execute the tests executable generated 
The processor expects the presence of an input file "add_test.vim" in the directory in which the processor executable is run from. "add_test.vim" is loaded into instruction memory at initialization and the program counter is then used to access the instructions. 

## Testing
Tests are located in the tests.v file. Simply use iverilog to compile this file and execute the output.
The first test, add_test, uses addi to load 1 and 2 into two registers and add to find their sum. add_test
stores the result in a0, which is read by the print syscall. addi is used to set the v0 register
indicating the syscall code, 1 being the print code. The syscall instruction is then executed,
which causes the value in a0 to be printed. The expected result is 3.

[cpu_diagram]: https://lh5.googleusercontent.com/NwP8dOkuRLI_ZRfyuvTKvwxYIAPsh-5ybUH5nD7E9MHUPgUhMHwgy5FYApsfa04WxQVWCCVFi3B92G23vY2J-C6IBIPD_jbU87XDDT4sSBBx3Cg_Al6wVIbieDD8Be8fdw8Upr6UK7KhsTl5rg "Patterson & Hennessy single cycle CPU"
