`timescale 1ns / 1ps
`include "header.vh"

module alu(
    /* ALU inputs */
    input wire [`ALUOPS-1:0] i_alu_op, // ALU operation to perform
    input wire signed [`XLEN-1:0] i_data_1, // First input data to operate upon (usually rs1)
    input wire signed [`XLEN-1:0] i_data_2, // Second input data to operate upon (usually rs2 or immediate)

    input wire[31:0] i_rs1, //Rs1 From Decode
    input wire[31:0] i_rs2, //Rs2 From Decode
    
    input wire[4:0] i_rs1_addr, //address for register source 1
    
    input wire[31:0] i_imm_de, //Immediate value from decode
    input wire[2:0] i_funct3_de, //function type from decode
    input wire[`Oplen:0] i_opcode_de, //opcode type from decode
    input wire[`Oplen:0] i_opcode_de, //opcode type from decode

    /* ALU output registers */
    output reg[31:0] or_rs1, //Source register 1 value
    output reg[31:0] or_rs2, //Source register 2 value
    output reg[11:0] or_imm, //Immediate value
    output reg[2:0] or_funct3, // function type
    output reg[4:0] or_rs1_addr, //address for register source 1
    output reg[`Oplen:0] or_opcode, //opcode type 
    output reg [`XLEN-1:0] ow_result // ALU result
    
);

wire [`XLEN-1:0] i_data_1_us = $unsigned(i_data_1);
wire [`XLEN-1:0] i_data_2_us = $unsigned(i_data_2);

/* Perform ALU operation */
always @(*) begin
    case(i_alu_op)
        `ADD: ow_result <= i_data_1 + i_data_2;
        `SUB: ow_result <= i_data_1 - i_data_2;
        `SLL: ow_result <= i_data_1 << i_data_2[4:0];
        `SLT: ow_result <= i_data_1 < i_data_2;
        `SLTU: ow_result <= i_data_1_us < i_data_2_us;
        `XOR: ow_result <= i_data_1 ^ i_data_2;
        `SRL: ow_result <= i_data_1 >> i_data_2[4:0];
        `SRA: ow_result <= i_data_1 >>> i_data_2[4:0];
        `OR: ow_result <= i_data_1 | i_data_2;
        `AND: ow_result <= i_data_1 & i_data_2;
        `EQ: ow_result <= i_data_1 == i_data_2;
        `NEQ: ow_result <= i_data_1 != i_data_2;
        `GE: ow_result <= i_data_1 >= i_data_2;
        `GEU: ow_result <= i_data_1_us >= i_data_2_us;
    endcase
end

endmodule