`include "mips.h"

module clock_gen(output reg clock);
initial
  clock = 1'b0;
always
  begin
    #100; clock = ~clock;
  end
endmodule


module PC (input [31:0] new_pc, input clk, output reg [31:0] PC);
  initial begin
    PC = 32'h00400000;
  end
  always @(posedge clk)
    PC = new_pc;
  // always @(posedge clk) begin
  //   PC = PC + 4;
  // end
endmodule

module adder (input [31:0] a, input [31:0] b, output [31:0] out);
  assign out = a + b;
  // always @(out)
    // $display("adder out: %h", out);
endmodule

module memory (input [31:0] address, output [31:0] instruction);
  reg [31:0] mem [32'h0100000: 32'h0101000];
  initial begin
    $readmemh("jumps.in", mem);
  end
  always @(instruction)
    $display("memory address=%h, instruction=%h", address, instruction);

  assign instruction = mem[address[31:2]];
endmodule

module mux2_1 (input high_a, input [31:0] a, input [31:0] b, output [31:0] out);
  assign out = high_a ? a : b;
  always @(high_a) begin
    $display("high_a=%d, out=%h", high_a, out);
  end
endmodule

// -------------CONTROL-----------------------------------
module control (input [31:26] opcode, output reg regdst,jump,branch,memread,memtoreg,output reg [2:0] aluop, output reg memwrite,alusrc,regwrite);
  always @(opcode) begin
    // Regdst

    // Check or jump instructions
    jump <= (opcode == `J||opcode == `JAL) ? 1 : 0;

    // Only sw and beq/bne don't write to a reg (regdst=x, regwrite=0, memtoreg=x)
    regdst <= (opcode == `SW||opcode == `BEQ||opcode == `BNE) ? 0 : 1;

    // Only sw and lw use aluop

    //bne can't use and for aluop without checking for inverse of Zero
    $display("opcode=%b, jump=%b", opcode, jump);
  end
endmodule
// -------------------------------------------------------



module jump_address_constructor(input [25:0] instruction, input [31:28] PC_plus_4, output reg [31:0] out);
  always @(*)
    out = {PC_plus_4, (instruction<<2)};
endmodule

module test;
  wire clock;
  wire [31:0] adder_mux;
  wire [31:0] mux_pc;
  wire [31:0] instruction;
  reg [31:0] four;
  wire [31:0] address;
  //reg [31:0] jump_address;
  wire [31:0] jump_address;

  wire [2:0] aluop;
  wire regdst, jump, branch, memread, memtoreg, regwrite, alusrc, memwrite;


  clock_gen clk(clock);
  PC p_counter(mux_pc, clock, address);
  adder pc_incrementer(address, four, adder_mux);
  memory mem(address, instruction);
  control control(instruction[31:26], regdst, jump, branch, memread, memtoreg, aluop, regwrite, alusrc, memwrite);
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
