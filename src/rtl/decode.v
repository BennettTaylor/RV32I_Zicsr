`timescale 1ns / 1ps
`include "header.vh"

module decode(
    // Inputs
    input wire i_clk, // System clock
    input wire rst_n, // Active low reset
    input wire [31:0] i_inst, // Instruction from instruction memory
    input wire [31:0] i_pc, // Current program counter

    // Output registers
    output reg [6:0] o_opcode, // Opcode
    output reg [4:0] o_rd_addr, // Destination register address
    output reg [31:0] o_imm, // Immediate value
    output reg [6:0] o_funct7, // Funct7
    output reg [2:0] o_funct3, // Funct3
    output reg [31:0] o_pc, // Current program counter

    //Output wires
    output wire [4:0] o_rs1_addr, // Source register 1 address for register file
    output wire [4:0] o_rs2_addr // Source register 2 address for register file
);

endmodule;

