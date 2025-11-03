`timescale 1ns / 1ps
`include "header.vh"

module alu(
    /* ALU inputs */
    input wire [`ALUOPS-1:0] i_alu_op, // ALU operation to perform
    input wire signed [`XLEN-1:0] i_data_1, // First input data to operate upon (usually rs1)
    input wire signed [`XLEN-1:0] i_data_2, // Second input data to operate upon (usually rs2 or immediate)

    /* ALU output registers */
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
