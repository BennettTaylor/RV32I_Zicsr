`timescale 1ns / 1ps
`include "header.vh"

module execute(
    /* Execute stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire [`OPLEN:0] i_opcode, // Opcode
    input wire [`XADDR-1:0] i_rd_addr, // Destination register address
    input wire [`XLEN-1:0] i_rd_mem, // RD value for instruction currently in the memory stage
    input wire [`XADDR-1:0] i_rd_addr_mem, // RD address for instruction currently in the memory stage
    input wire i_rd_mem_wr_en,  // Register file write enable for the instruction currently in the memory stage 
    input wire [`XLEN-1:0] i_rd_wb, // RD value for instruction currently in the write back stage
    input wire [`XADDR-1:0] i_rd_addr_wb, // RD address for instruction currently in the write back stage
    input wire i_rd_wb_wr_en,  // Register file write enable for the instruction currently in the write back stage
    input wire [`XADDR-1:0] i_rs1_addr, // Source register 1 address for forwarding
    input wire [`XADDR-1:0] i_rs2_addr, // Source register 2 address for forwarding
    input wire [`XLEN-1:0] i_rs1_data, // Source register 1 value
    input wire [`XLEN-1:0] i_rs2_data, // Source register 2 value
    input wire [`XLEN-1:0] i_imm, // Immediate value
    input wire [4:0] i_shamt, // Shamt
    input wire [6:0] i_funct7, // Funct7
    input wire [2:0] i_funct3, // Funct3
    input wire [`ALUOPS-1:0] i_alu_op, // The ALU operation specified
    input wire [`XLEN-1:0] i_pc, // Current program counter
    
    /* Execute stage outputs */
    output reg [`OPLEN:0] or_opcode, // Opcode
    output reg [`XADDR-1:0] or_rd_addr, // Destination register address
    output reg [`XLEN-1:0] or_alu_result,
    output reg [`XLEN-1:0] or_pc, // Current program counter
    output reg [`XLEN-1:0] or_pc_next // Next program counter for jumps
);

/* Instantiate the forwarding unit */


/* ALU wires */
wire [`XLEN-1:0] rs1_data;
wire [`XLEN-1:0] rs2_data;

/* Instantiate the ALU */ 
forward forwarding_unit(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rs1_ex(i_rs1_data),
    .i_rs2_ex(i_rs2_data),
    .i_rs1_addr_ex(i_rs1_addr),
    .i_rs2_addr_ex(i_rs2_addr),
    .i_rd_mem(),
    .i_rd_addr_mem(),
    .i_rd_mem_wr_en(),
    .i_rd_wb(),
    .i_rd_addr_wb(),
    .i_rd_wb_wr_en(),
    .or_rs1(),
    .or_rs2()
);

endmodule;
