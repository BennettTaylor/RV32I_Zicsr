`timescale 1ns / 100ps
`include "header.vh"

module write_back(
    /* Write back stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire [`XADDR-1:0] i_rd_addr, // Register to be writen to
    input wire i_rd_write, // Write enable for rd
    input wire [`XLEN-1:0] i_rd_data, // Data to be written to rd
    input wire [`XLEN-1:0] i_pc, // Current program counter
    input wire [`OPLEN-1:0] i_opcode, // Opcode
    input wire [2:0] i_funct3, // Funct3 (for CSR instructions)
    
    output reg [`XADDR-1:0] or_rd_addr, // Register to be writen to
    output reg or_rd_write, // Write enable for rd
    output reg [`XLEN-1:0] or_rd_data, // Data to be written to rd
    output reg or_stall,
    output reg or_flush
);

always @(*) begin
    or_rd_addr = i_rd_addr;
    or_rd_write = i_rd_write;
    or_rd_data = i_rd_data;
end

endmodule
