`timescale 1ns / 1ps
`include "header.vh"

module decode(
    // Inputs
    input wire i_clk, // System clock
    input wire i_rst_n, // Active low reset
    input wire [`XLEN-1:0] i_inst, // Instruction from instruction memory
    input wire [`XLEN-1:0] i_pc, // Current program counter

    // Output registers
    output reg [`OPLEN:0] or_opcode, // Opcode
    output reg [`XADDR-1:0] or_rd_addr, // Destination register address
    output reg [`XADDR-1:0] or_rs1_addr, // Source register 1 address for forwarding
    output reg [`XADDR-1:0] or_rs2_addr, // Source register 2 address for forwarding
    output reg [`XLEN-1:0] or_imm, // Immediate value
    output reg [6:0] or_funct7, // Funct7
    output reg [2:0] or_funct3, // Funct3
    output reg [`ALUOPS-1:0] or_alu_op, // The ALU operation specified
    output reg [`XLEN-1:0] or_pc, // Current program counter

    //Output wires
    output wire [`XADDR-1:0] ow_rs1_addr, // Source register 1 address for register file
    output wire [`XADDR-1:0] ow_rs2_addr // Source register 2 address for register file
);



/* Assign rs1 and rs2 wires for register file */
assign ow_rs1_addr = i_inst[19:15];
assign ow_rs2_addr = i_inst[24:20];

/* Generate opcode & funct3 wire */
wire [`OPLEN-1:0] opcode = i_inst[`OPLEN-1:0]; 
wire [2:0] funct3 = i_inst[14:12];

/* Registers for storing calculated values */
reg [`XLEN-1:0] imm;
reg [`ALUOPS-1:0] alu_ops;

/* Assign register outputs */
always @(posedge i_clk) begin
    or_opcode <= opcode;
    or_rd_addr <= i_inst[11:7];
    or_rs1_addr <= ow_rs1_addr;
    or_rs2_addr <= ow_rs2_addr;
    or_imm <= imm;
    or_funct7 <= i_inst[31:25];
    or_funct3 <= funct3;
    or_alu_ops <= alu_op;
    or_pc <= i_pc;
end

/* Calculate needed values */
always @(*) begin
    /* Reset registers */
    alu_ops = 0;
    imm = 0;
end

endmodule;
