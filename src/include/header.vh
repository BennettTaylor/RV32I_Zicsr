/* This header file defines macros for numbers frequently used in the RV32I_Zicsr processor */

/* System constants */
`define XLEN 32 // Register length
`define XADDR 5 // Register address length
`define ILEN 32 // Instruction length
`define IALIGN 32 // Instruction alignment required
`define REGISTERS 32 // Number of registers in the register file
`define OPLEN 7 // Opcode length
`define OPS 10 // Number of unique opcodes
`define ALUOPS 4 // Number of bits needed to identify ALU operations 
`define MEMADDR 25 // Number of bits needed to access 128MB of memory word-wise
`define MEMSIZE 32 // Number of accessable in memory
`define MEMBITS 5
`define NUMINST 32  // Number of instructions accessable in memory
`define INSTBITS 5

/* Opcodes */
`define R_OP 7'b0110011 // R Type Opcode
`define I_OP 7'b0010011 // I Type Opcode
`define B_OP 7'b1100011 // B Type Opcode
`define S_OP 7'b0100011 // S Type Opcode
`define L_OP 7'b0000011 // Load Opcode
`define SYSTEM_OP 7'b1110011 // ECALL, EBREAK, or CSR Opcode
`define JALR_OP 7'b1100111 // JALR Opcode
`define JAL_OP 7'b1101111 // JAL Opcode
`define LUI_OP 7'b0110111 // LUI Opcode
`define AUIPC_OP 7'b0010111 // AUIPC Opcode

/* ALU Operations */
`define ADD 4'b0000
`define SUB 4'b0001
`define SLL 4'b0010
`define SLT 4'b0011
`define SLTU 4'b0100
`define XOR 4'b0101
`define SRL 4'b0110
`define SRA 4'b0111
`define OR 4'b1000
`define AND 4'b1001
`define EQ 4'b1010
`define NEQ 4'b1011
`define GE 4'b1100
`define GEU 4'b1101
