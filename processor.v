`include "mips.h"
`include "control.v"

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

module and1_2(input a, b, output reg out);
  always @(*) begin
    out = a & b;
  end
endmodule

// Inverter outputs the inverse of the input if control is 1.
module inverter(input in, control, output reg out);
  always @(*) begin
    out = (control) ? ~in : in;
  end
endmodule

module instruction_memory (input [31:0] address, output [31:0] instruction);
  reg [31:0] mem [32'h0100000: 32'h0101000];
  initial begin
    $readmemh("program.in", mem);
  end
  always @(instruction)
    $display("memory address=%h, instruction=%h", address, instruction);

  assign instruction = mem[address[31:2]];
endmodule

module mux32_2 (input [31:0] a, b, input high_a, output [31:0] out);
  assign out = high_a ? a : b;
  always @(high_a) begin
    $display("high_a=%d, out=%h", high_a, out);
  end
endmodule

module mux5_2 (input [4:0] a, b, input high_a, output [4:0] out);
  assign out = high_a ? a : b;
  always @(high_a) begin
    $display("high_a=%d, out=%h", high_a, out);
  end
endmodule

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

// -------------------------- //

module registers(input [25:21] read_reg1,
                input [20:16] read_reg2,
                input [15:11] write_reg,
                input [31:0] write_data,
                input regwrite,
                input clk,
                output reg [31:0] read_data1, read_data2);
  reg [32:0] [32:0] reg_file;
  initial begin
    reg_file = 0;
  end
  always @(posedge clk) begin
    read_data1 = reg_file[read_reg1];
    read_data2 = reg_file[read_reg2];
  end
  always @(negedge clk) begin
    if (regwrite) begin
      reg_file[write_reg] = write_data;
    end
    else begin
    end
  end
endmodule

// -------- Memory ---------- //
module data_memory(input [31:0] address, write_data, input memwrite, memread, clk, output reg [31:0] read_data);
  reg [31:0] mem[0:255];
  always @(posedge clk) begin
    if (memwrite) begin
      mem[address] = write_data;
    end else;
  end
  always @(negedge clk) begin
    if (memread) begin
      read_data = mem[address];
    end
  end
endmodule

module jump_address_constructor(input [25:0] instruction, input [31:28] PC_plus_4, output reg [31:0] out);
  always @(*)
    out = {PC_plus_4, (instruction<<2)};
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
