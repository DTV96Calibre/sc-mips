`include "mips.h"

// -------------CONTROL-----------------------------------
module control (input [31:26] opcode,
                output reg regdst,jump,
                branch,memread,memtoreg,
                output reg [3:0] aluop,
                output reg rtype, memwrite,
                alusrc,regwrite,invertzero);
  initial begin
    regdst <= 0;
    jump <= 0;
    branch <= 0;
    memread <= 0;
    memtoreg <= 0;
    aluop <= 0;
    rtype <= 0;
    memwrite <= 0;
    alusrc <= 0;
    regwrite <= 0;
    invertzero <= 0;
  end
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
      `ADDIU: aluop = `ALU_add; //TODO The alu needs to differentiate addi addiu
      `LW: aluop = `ALU_add;
      `SW: aluop = `ALU_add;
      `SUB: aluop = `ALU_sub;
      `BEQ: aluop = `ALU_sub;
      `BNE: aluop = `ALU_sub;
      `SLT: aluop = `ALU_slt;
      default: aluop = `ALU_undef;
    endcase;

    rtype <= (opcode == 6'h0) ? 1 : 0;

    // memwrite
    memwrite <= (opcode ==`SW) ? 1 : 0;

    // alusrc ("Selects the second source operand for the ALU (rt or sign-extended immediate...")
    alusrc <= (opcode==`ADDI||opcode == `ADDIU||opcode==`ORI||opcode==`LW||opcode==`SW)?1:0;

    regwrite <= (opcode == `SW||opcode == `BEQ||opcode == `BNE||opcode == `J||opcode == `JR) ? 0 : 1;

    // Only sw and beq/bne don't write to a reg (regdst=x, regwrite=0, memtoreg=x)
    regdst <= (opcode == `ADDI||opcode == `ADDIU||opcode == `LW||opcode == `ORI) ? 0 : 1;

    // Invert ALU Zero signal?
    // Subtract OP results in Zero=1 when ==, so flip Zero when checking !=
    invertzero <= (opcode == `BNE) ? 1 : 0;


    // $display("opcode=%b, jump=%b", opcode, jump);
  end
endmodule
// -------------------------------------------------------

module ALU_control (input [3:0] aluop_from_control,
                    input [5:0] functioncode,
                    input rtype,
                    output reg [3:0] aluop_out);
  always @(*) begin
    if (rtype) begin
      case(functioncode)
        `AND: aluop_out = `ALU_AND;
        `OR: aluop_out = `ALU_OR;
        `ORI: aluop_out = `ALU_OR;
        `ADD: aluop_out = `ALU_add;
        `ADDI: aluop_out = `ALU_add;
        `ADDU: aluop_out = `ALU_add; //TODO Differentiate this from addi
        `LW: aluop_out = `ALU_add;
        `SW: aluop_out = `ALU_add;
        `SUB: aluop_out = `ALU_sub;
        `BEQ: aluop_out = `ALU_sub;
        `BNE: aluop_out = `ALU_sub;
        `SLT: aluop_out = `ALU_slt;
        `SYSCALL: aluop_out = `ALU_add;
        default: aluop_out = `ALU_undef;
      endcase
    end
    else begin
      aluop_out = aluop_from_control;
    end
  end
endmodule

module SYSCALL_controller(input [31:0]instruction, input clk, output reg syscall);
  initial
    syscall <= 0;
  // Alert the syscall module if the current instruction is a syscall
  always @(negedge clk) begin
  // A syscall instruction is 00 00 00 0C
    syscall = (instruction == {28'h0,`SYSCALL}) ? 1 : 0;
  end
endmodule
