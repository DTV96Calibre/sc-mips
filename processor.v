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
module control (input [31:26] opcode, output reg regdst,jump,branch,memread,memtoreg,output reg [3:0] aluop, output reg memwrite,alusrc,regwrite,invertzero);
  always @(opcode) begin
    // Regdst (there are fewer 0s than 1s so checked for 0s)--------VVVVVVV
    regdst <= (opcode == `ADDI || opcode == `ORI || opcode == `LW) ? 0 : 1;

    // Check or jump instructions
    jump <= (opcode == `J||opcode == `JAL) ? 1 : 0;

    // branch
    branch <= (opcode ==`BEQ||opcode == `BNE) ? 1 : 0;

    // memread
    memread <= (opcode ==`LW) ? 1 : 0;

    // memtoreg
    memtoreg <= (opcode == `LW) ? 1 : 0;

    // aluop
    case(opcode)
      `AND: aluop = `ALU_AND;
      `OR: aluop = `ALU_OR;
      `ORI: aluop = `ALU_OR;
      `ADD: aluop = `ALU_add;
      `ADDI: aluop = `ALU_add;
      `LW: aluop = `ALU_add;
      `SW: aluop = `ALU_add;
      `SUB: aluop = `ALU_sub;
      `BEQ: aluop = `ALU_sub;
      `BNE: aluop = `ALU_sub;
      `SLT: aluop = `ALU_slt;
      default: aluop = `ALU_undef;
    endcase;

    // memwrite
    memwrite <= (opcode ==`SW) ? 1 : 0;

    // alusrc
    alusrc <= (opcode==`ADDI||opcode==`ORI||opcode==`LW||opcode==`SW)?1:0;

    // Only sw and beq/bne don't write to a reg (regdst=x, regwrite=0, memtoreg=x)
    regdst <= (opcode == `SW||opcode == `BEQ||opcode == `BNE) ? 0 : 1;

    // Invert ALU Zero signal?
    // Subtract OP results in Zero=1 when ==, so flip Zero when checking !=
    invertzero <= (opcode == `BNE) ? 1 : 0;

    $display("opcode=%b, jump=%b", opcode, jump);
  end
endmodule
// -------------------------------------------------------

// --------- ALU ------------ //
module ALU (input [3:0] aluop, input [31:0] a, b, output reg [31:0] out, output reg zero);
  always @(*) begin
    case (aluop)
      `ALU_AND: out = a & b;
      `ALU_OR: out = a | b;
      `ALU_add: out = a + b;
      `ALU_sub: out = a - b;
      `ALU_slt: out = a < b;
      default: out = `undefined;
    endcase
    zero = (out == 32'h0000);
  end
endmodule

module ALU_control (input [3:0] aluop_from_control, input [5:0] functioncode, output [3:0] aluop_out);

endmodule
// -------------------------- //

module registers(input [25:21] read_reg1, input [20:16] read_reg2, input [15:11] write_reg, input [31:0] write_data, input clk, output reg [31:0] read_data1, read_data2);

endmodule

// -------- Memory ---------- //
module data_memory(input [31:0] address, write_data, input memwrite, memread, clk, output reg [31:0] read_data);
  reg [31:0] mem[0:255];
endmodule

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

  wire [3:0] aluop;
  wire regdst, jump, branch, memread, memtoreg, regwrite, alusrc, memwrite, invertzero;


  clock_gen clk(clock);
  PC p_counter(mux_pc, clock, address);
  adder pc_incrementer(address, four, adder_mux);
  memory mem(address, instruction);
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

// module test;
//   wire clock;
//   wire [31:0] adder_mux;
//   wire [31:0] mux_pc;
//   wire [31:0] instruction;
//   reg [31:0] four;
//   wire [31:0] address;
//   //reg [31:0] jump_address;
//   wire [31:0] jump_address;
//
//   wire [3:0] aluop;
//   wire regdst, jump, branch, memread, memtoreg, regwrite, alusrc, memwrite, invertzero;
//
//
//   clock_gen clk(clock);
//   PC p_counter(mux_pc, clock, address);
//   adder pc_incrementer(address, four, adder_mux);
//   memory mem(address, instruction);
//   control control(instruction[31:26], regdst, jump, branch, memread, memtoreg, aluop, regwrite, alusrc, memwrite, invertzero);
//   mux2_1 jump_mux(jump, jump_address, adder_mux, mux_pc);
//   jump_address_constructor jump_constructor(instruction[25:0], adder_mux[31:28], jump_address);
//
//   initial begin
//     four = 4;
//     //jump_address = 32'h00400000;
//     $dumpfile("jumps.vcd");
//     $dumpvars(0, test);
//     $monitor("instruction: %h\n", instruction);
//     #2000; $finish;
//   end
//   always @(instruction) begin
//     if (instruction == 0)
//       $finish;
//     else;
//   end
// endmodule
