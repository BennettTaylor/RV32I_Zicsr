`timescale 1ns / 1ps
`include "header.vh"

module forward(
    /* Forwarding unit inputs */
    input wire [`XLEN-1:0] i_rs1_ex, // RS1 value for the instruction currently in the execution stage
    input wire [`XLEN-1:0] i_rs2_ex, // RS2 value for the instruction currently in the execution stage
    input wire [`XADDR-1:0] i_rs1_addr_ex, // Address of RS1 for the insturction currently in the execution stage
    input wire [`XADDR-1:0] i_rs2_addr_ex, // Address of RS1 for the insturction currently in the execution stage
    input wire [`XLEN-1:0] i_rd_mem, // RD value for instruction currently in the memory stage
    input wire [`XADDR-1:0] i_rd_addr_mem, // RD address for instruction currently in the memory stage
    input wire i_rd_mem_wr_en,  // Register file write enable for the instruction currently in the memory stage 
    input wire [`XLEN-1:0] i_rd_wb, // RD value for instruction currently in the write back stage
    input wire [`XADDR-1:0] i_rd_addr_wb, // RD address for instruction currently in the write back stage
    input wire i_rd_wb_wr_en,  // Register file write enable for the instruction currently in the write back stage
    
    /* Forwarding unit outputs */
     output reg [`XLEN-1:0] or_rs1, // RS1 value fed to the ALU
     output reg [`XLEN-1:0] or_rs2 //  RS2 value fed to the ALU
);

always @(*) begin
    /* RS1 */
    if ((i_rs1_addr_ex == i_rd_addr_mem) && i_rd_mem_wr_en) begin
        or_rs1 = i_rd_mem;
    end else if ((i_rs1_addr_ex == i_rd_addr_wb) && i_rd_wb_wr_en) begin
        or_rs1 = i_rd_wb;
    end else begin
        or_rs1 = i_rs1_ex;
    end
    
    /* RS2 */
    if ((i_rs2_addr_ex == i_rd_addr_mem) && i_rd_mem_wr_en) begin
        or_rs2 = i_rd_mem;
    end else if ((i_rs2_addr_ex == i_rd_addr_wb) && i_rd_wb_wr_en) begin
        or_rs2 = i_rd_wb;
    end else begin
        or_rs2 = i_rs2_ex;
    end
end

endmodule
