`include "processor.v"
`include "mips.h"

module complete_processor(output [31:0] instruction, output clock);
  /* ------- Wires (and regs) -------- */
  wire clock;
  wire [31:0] pc_adder_mux/*PC+4*/, branch_adder_mux;
  wire [31:0] mux_pc;
  wire [31:0] instruction;
  reg [31:0] four;
  wire [31:0] address;
  //reg [31:0] jump_address;
  wire [31:0] jump_address, branch_address;
  /* ALU */
  wire [3:0] aluop_from_control, aluop_to_alu;
  wire [31:0] read_data1,read_data2/*From registers*/, alusrc_mux_output, alu_result;
  /* Control */
  wire regdst, jump, branch, memread, memtoreg, rtype, regwrite, alusrc, memwrite, invertzero;
  wire syscall;
  wire branch_zero_and_output, branch_mux_control;

  /* Register */
  wire [4:0] regdst_mux_output;
  wire [31:0] memtoreg_mux_output;

  /* Data Memory */
  wire [31:0] read_data;

  /* -------- Wire up the processor's individual modules ------------ */
  // NOTE: See documentation for block diagram TODO: Add annotated modified diagram.
  clock_gen clk(clock);
  PC p_counter(mux_pc, clock, address);
  adder pc_incrementer(address, four, pc_adder_mux);
  instruction_memory imem(address, instruction);
  control control(instruction[`op], regdst, jump, branch, memread, memtoreg,
                  aluop_from_control, rtype, memwrite, alusrc, regwrite, invertzero);

  SYSCALL_controller syscaller(instruction, clock, syscall);

  registers register_file(instruction[`rs], instruction[`rt],
                          regdst_mux_output, memtoreg_mux_output,
                          regwrite, syscall, clock,
                          read_data1, read_data2);
  mux32_2 memtoreg_mux(read_data/*from data memory*/, alu_result, memtoreg, memtoreg_mux_output);
  mux5_2 regdst_mux(instruction[`rd], instruction[`rt], regdst, regdst_mux_output);

  data_memory dmem(alu_result, read_data2, memwrite, memread, clock, read_data);

  /* ALU */
  ALU_control alu_control(aluop_from_control, instruction[`function], rtype, aluop_to_alu);
  ALU alu(aluop_to_alu, read_data1, alusrc_mux_output, alu_result, zero);
  mux32_2 alusrc_mux({16'h0, instruction[15:0]}/*sign-extend from 16 to 32*/,
                      read_data2, alusrc, alusrc_mux_output);

  /* Jumping logic */
  mux32_2 jump_mux(jump_address, branch_address, jump, mux_pc);
  jump_address_constructor jump_constructor(instruction[`target], pc_adder_mux[31:28], jump_address);

  /* Branching logic */
  and1_2 branch_zero_and(branch, zero, branch_zero_and_output);
  // Inverter for detecting when ALU is not zero, used for BNE
  inverter invertzero_inverter(branch_zero_and_output, invertzero, branch_mux_control);
  mux32_2 branch_mux(branch_adder_mux, pc_adder_mux, branch_mux_control, branch_address);
  adder branch_adder(pc_adder_mux,
                    {16'h0, instruction[15:0]}<<2/*sign-extend from 16 to 32 then shift left 2*/,
                    branch_adder_mux);
  initial
    four = 4;
endmodule

module test;
  wire [31:0] instruction;
  wire clock;
  complete_processor processor(instruction, clock);
  initial begin
    //jump_address = 32'h00400000;
    $dumpfile("processor.vcd");
    $dumpvars(0, processor);
    //$monitor("instruction: %h, clock:%b\n", instruction, clock);
    #2000; $finish;
  end
  // always @(clock) begin
  //   if (instruction === `undefined) begin
  //     $strobe("Undefined instruction"); $finish; end
  //   else;
  // end
endmodule

// module test_data_memory;
//   reg [31:0] address1;
//   reg [31:0] write_data;
//   reg memwrite, memread;
//   wire clock;
//
//   clock_gen clk(clock);
//
//
// endmodule
