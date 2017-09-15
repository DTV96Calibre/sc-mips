`include "processor.v"
`include "mips.h"

module complete_processor;
  wire clock;
  wire [31:0] pc_adder_mux, branch_adder_mux;
  wire [31:0] mux_pc;
  wire [31:0] instruction;
  reg [31:0] four;
  wire [31:0] address;
  //reg [31:0] jump_address;
  wire [31:0] jump_address, branch_address;

  wire [3:0] aluop;
  wire regdst, jump, branch, memread, memtoreg, rtype, regwrite, alusrc, memwrite, invertzero;
  wire branch_zero_and, branch_mux_control;

  clock_gen clk(clock);
  PC p_counter(mux_pc, clock, address);
  adder pc_incrementer(address, four, pc_adder_mux);
  instruction_memory imem(address, instruction);
  control control(instruction[31:26], regdst, jump, branch, memread, memtoreg, aluop, rtype, memwrite, alusrc, regwrite, invertzero);
  mux32_2 jump_mux(jump_address, branch_address, jump, mux_pc);
  jump_address_constructor jump_constructor(instruction[25:0], pc_adder_mux[31:28], jump_address);

  and branch_zero_and(branch, zero, branch_zero_and);
  inverter invertzero_inverter(branch_zero_and, invertzero, branch_mux_control);
  mux32_2 branch_mux(branch_adder_mux, pc_adder_mux, branch_mux_control, branch_address);
  adder branch_adder(pc_adder_mux, {16'h0, instruction[15:0]}<<2, branch_adder_mux);

  initial begin
    four = 4;
    //jump_address = 32'h00400000;
    $dumpfile("processor.vcd");
    $dumpvars(0, complete_processor);
    $monitor("instruction: %h\n", instruction);
    #2000; $finish;
  end
  always @(instruction) begin
    if (instruction == 0)
      $finish;
    else;
  end
endmodule
