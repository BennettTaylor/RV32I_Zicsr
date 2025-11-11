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

/* Opcodes */
`define R_OP 7'b0110011 // R Type Opcode
`define I_OP 7'b0010011 // I Type Opcode
`define B_OP 7'b1100011 // B Type Opcode
`define S_OP 7'b0100011 // S Type Opcode
`define L_OP 7'b0000011 // Load Opcode
`define SYSTEM_OP 7'b1110011 // ECALL, EBREAK, or CSR Opcode
`define JALR_OP 7'b0110011 // JALR Opcode
`define JAL_OP 7'b1101111 // JAL Opcode
`define LUI_OP 7'b0110111 // LUI Opcode
`define AUIPC_OP 7'b0010111 // AUIPC Opcode

/* ALU Operations */
`define ADD 0
`define SUB 1
`define SLL 2
`define SLT 3
`define SLTU 4
`define XOR 5
`define SRL 6
`define SRA 7
`define OR 8
`define AND 9
`define EQ 10
`define NEQ 11
`define GE 12
`define GEU 13
