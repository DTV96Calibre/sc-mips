`include "processor.v"
`include "mips.h"

module test;
  wire clock;
  wire [31:0] adder_mux;
  wire [31:0] mux_pc;
  wire [31:0] instruction;
  reg [31:0] four;
  wire [31:0] address;
  //reg [31:0] jump_address;
  wire [31:0] jump_address;

  wire [3:0] aluop;
  wire regdst, jump, branch, memread, memtoreg, regwrite, alusrc, memwrite, invertzero;


  clock_gen clk(clock);
  PC p_counter(mux_pc, clock, address);
  adder pc_incrementer(address, four, adder_mux);
  instruction_memory imem(address, instruction);
  control control(instruction[31:26], regdst, jump, branch, memread, memtoreg, aluop, regwrite, alusrc, memwrite, invertzero);
  mux2_1 jump_mux(jump, jump_address, adder_mux, mux_pc);
  jump_address_constructor jump_constructor(instruction[25:0], adder_mux[31:28], jump_address);

  initial begin
    four = 4;
    //jump_address = 32'h00400000;
    $dumpfile("jumps.vcd");
    $dumpvars(0, test);
    $monitor("instruction: %h\n", instruction);
    #2000; $finish;
  end
  always @(instruction) begin
    if (instruction == 0)
      $finish;
    else;
  end
endmodule
