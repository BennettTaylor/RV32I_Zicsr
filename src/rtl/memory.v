`timescale 1ns / 1ps
`include "header.vh"

module memory(
    /* Memory stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire [`OPLEN:0] i_opcode, // Opcode
    input wire [2:0] i_funct3,
    input wire [`XLEN-1:0] i_rs2, // Data to be written
    input wire [`XADDR-1:0] i_rd_addr, // Destination register address
    input wire i_rd_write, // Write enable for rd
    input wire [`XLEN-1:0] i_alu_result,
    input wire [`XLEN-1:0] i_pc, // Current program counter
    input wire i_mem_ack, // Acknoledgement from memory (data is ready for read/written to)
    input wire [`XLEN-1:0] i_mem_data, // Data from memory address requested
    input wire i_flush, // Flush signal from external stages
    input wire i_stall, // Stall signals from external stages
    
    /* Memory stage outputs */
    output reg [`XLEN-1:0] or_pc, // Current program counter
    output reg [`XADDR-1:0] or_rd_addr, // Register to be writen to
    output reg or_rd_write, // Write enable for rd
    output reg [`XLEN-1:0] or_rd_data, // Data to be written to rd
    output reg [`OPLEN-1:0] or_opcode, // Opcode
    output reg or_mem_req, // Memory request signal
    output reg [`XLEN-1:0] or_mem_addr, // Memory address requested for read/write
    output reg [`XLEN-1:0] or_mem_data, // Data to be written to memory
    output reg or_read_write, // Indicates read (0) or write (1) operation
    output reg or_flush, // Flush signal to external stages
    output reg or_stall // Stall signal to external stages
);

reg [`XLEN-1:0] mem_data;
reg [`XLEN-1:0] rd_data;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        /* Set all output and internal state to 0 */
        or_pc <= 0;
        or_rd_addr <= 0;
        or_rd_write <= 0;
        or_rd_data <= 0;
        or_opcode <= 0;
        or_mem_req <= 0;
        or_mem_addr <= 0;
        or_flush <= 0;
        or_stall <= 0;
    end else if (i_flush || or_flush) begin
        /* Make current instruction a NOP instruction (ADDI x0, x0, 0) */
        or_pc <= i_pc;
        or_rd_addr <= 0;
        or_rd_write <= 1;
        or_rd_data <= 0;
        or_opcode <= `I_OP;
        or_mem_req <= 0;
        or_mem_addr <= 0;
        or_flush <= 0;
        or_stall <= 0;
    end else if (i_stall || or_stall) begin
        /* Hold current state */
        or_pc <= or_pc;
        or_rd_addr <= or_rd_addr;
        or_rd_write <= or_rd_write;
        or_rd_data <= rd_data;
        or_opcode <= or_opcode;
        or_mem_req <= or_mem_req;
        or_mem_addr <= or_mem_addr;
        or_flush <= or_flush;
        or_stall <= or_stall;
    end else begin
        /* Pass result to write back stage */
        or_pc <= i_pc;
        or_rd_addr <= i_rd_addr;
        or_rd_write <= i_rd_write;
        or_rd_data <= rd_data;
        or_opcode <= i_opcode;
        or_mem_req <= 0;
        or_mem_addr <= 0;
        or_flush <= 0;
        or_stall <= 0;
    end
end

/* Generate memory request */
always @(*) begin
    if ((i_opcode == `L_OP) && !i_mem_ack) begin
        /* Handle load operation */
        or_mem_addr = {i_alu_result[31:2], 2'b00};
        or_read_write = 0;
        or_mem_req = 1;
        or_stall = 1'b1;
    end else if ((i_opcode == `S_OP) && !i_mem_ack) begin
        /* Handle store operation */
        or_mem_addr = {i_alu_result[31:2], 1'b00};
        or_read_write = 1;
        or_mem_req = 1;
        or_stall = 1'b1;
    end 
end

/* Handle memory request acknoledgement */
always @(posedge i_mem_ack) begin
    if (i_opcode == `L_OP) begin
        /* Handle load operation */
        case (i_funct3)
            3'b000: begin
                case (i_alu_result[1:0])
                    2'b00: begin
                        mem_data = {24 * i_mem_data[7], i_mem_data[7:0]}; 
                    end
                    
                    2'b01: begin
                        mem_data = {24 * i_mem_data[15], i_mem_data[15:8]};
                    end
                    
                    2'b10: begin
                        mem_data = {24 * i_mem_data[23], i_mem_data[23:16]};
                    end
                    
                    2'b11: begin
                        mem_data = {24 * i_mem_data[31], i_mem_data[31:24]};
                    end
                endcase
            end
            
            3'b001: begin
            
            end
        endcase
    end 
end

endmodule;
