`timescale 1ns / 1ps
`include "header.vh"

module memory(
    /* Memory stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire [`OPLEN:0] i_opcode, // Opcode
    input wire [`XADDR-1:0] i_rd_addr, // Destination register address
    input wire [`XLEN-1:0] i_alu_result,
    input wire [`XLEN-1:0] i_pc, // Current program counter
    input wire [`XLEN-1:0] i_pc_next, // Next program counter for jumps
    
    /* Memory stage inputs */
    output reg [`XLEN-1:0] or_pc,
    output reg [`XADDR-1:0] or_rd_addr,
    output reg [`XLEN-1:0] or_alu_result,
    output reg [`XLEN-1:0] or_mem_result,
    output reg [`OPLEN-1:0] or_opcode
    
);

endmodule;
