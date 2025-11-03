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
    input wire [6:0] i_funct7, // Funct7
    input wire [2:0] i_funct3, // Funct3
    input wire [`ALUOPS-1:0] i_alu_op, // The ALU operation specified
    input wire [`XLEN-1:0] i_pc, // Current program counter
    
    /* Execute stage outputs */
    output reg [`OPLEN:0] or_opcode, // Opcode
    output reg [`XADDR-1:0] or_rd_addr, // Destination register address
    output reg [`XLEN-1:0] or_alu_result,
    output reg [`XLEN-1:0] or_pc, // Current program counter
    output reg [`XLEN-1:0] or_pc_next, // Next program counter for jumps
    output reg or_pc_jump
);

/* Forwarding unit wires */
wire [`XLEN-1:0] rs1_data;
wire [`XLEN-1:0] rs2_data;

/* Instantiate the forwarding unit */
forward forwarding_unit(
    .i_rs1_ex(i_rs1_data),
    .i_rs2_ex(i_rs2_data),
    .i_rs1_addr_ex(i_rs1_addr),
    .i_rs2_addr_ex(i_rs2_addr),
    .i_rd_mem(i_rd_mem),
    .i_rd_addr_mem(i_rd_addr_mem),
    .i_rd_mem_wr_en(i_rd_mem_wr_en),
    .i_rd_wb(i_rd_wb),
    .i_rd_addr_wb(i_rd_addr_wb),
    .i_rd_wb_wr_en(i_rd_wb_wr_en),
    .or_rs1(rs1_data),
    .or_rs2(rs2_data)
);

/* ALU wires */
wire [`XLEN-1:0] alu_result;
reg [`XLEN-1:0] data_1;
reg [`XLEN-1:0] data_2;

/* Instantiate the ALU */ 
alu ALU(
    .i_alu_op(i_alu_op),
    .i_data_1(data_1),
    .i_data_2(data_2),
    .ow_result(alu_result)
);

/* PC generation wires */
reg [`XLEN-1:0] pc_inc;

/* Assign register outputs */
always @(posedge i_clk) begin
    if ((i_opcode == `B_OP) && (alu_result == 1)) begin
        or_pc_jump <= 1;
        pc_inc <= i_imm;
    end else if ((i_opcode == `AUIPC_OP) || (i_opcode == `JAL_OP) || (i_opcode == `JALR_OP)) begin
        or_pc_jump <= 1;
        pc_inc <= alu_result;
    end
    if (!i_rst_n) begin
        or_opcode <= 0;
        or_rd_addr <= 0;
        or_alu_result <= 0;
        or_pc <= 0;
        or_pc_next <= 0;
    end else begin
        or_opcode <= i_opcode;
        or_rd_addr <= i_rd_addr;
        or_alu_result <= alu_result;
        or_pc <= i_pc;
        or_pc_next <= i_pc + pc_inc;
        
    end 

end

/* Generate ALU inputs */
always @(*) begin
    data_1 = 0;
    data_2 = 0;
    pc_inc = 4;
    case(i_opcode)
        `R_OP, `B_OP: begin
            data_1 = rs1_data;
            data_2 = rs2_data;
        end
        
        `I_OP, `S_OP, `L_OP, `JALR_OP: begin
            data_1 = rs1_data;
            data_2 = i_imm;
        end
        
        `LUI_OP, `AUIPC_OP, `JAL_OP: begin
            data_1 = i_imm;
        end
    endcase
end

endmodule
