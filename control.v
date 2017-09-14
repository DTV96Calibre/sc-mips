`include "mips.h"

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

    // alusrc ("Selects the second source operand for the ALU (rt or sign-extended immediate...")
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
