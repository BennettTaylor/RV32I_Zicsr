`timescale 1ns / 1ps
`include "header.vh"

module fetch(
    /* Fetch stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire i_flush_sig, // Flush Condition
    input wire [31:0] i_flush_pc, // PC taken from Flush I/F 
    input wire i_branch_sig, // Branch Taken Condition
    input wire [31:0] i_branch_pc, // PC from branch prediction 
    input wire i_cpu_stall, // CPU Stall Command from Decode Unit
    input wire i_decode_stall // Past Stall 
    
    input wire [31:0] i_inst_mem, // Instruction from memory
    input wire [31:0] i_pc, // Program Counter 
    
    output wire o_inst, // Output instruction for decode
    output wire o_mem_req, // Request action 
    output reg o_pc_next // Next PC
);

wire [31:0] pc_next_four = i_pc[31:0] + 4; 
reg [31:0] no_op = 32'b00000000000000000000000000010011;

always @(*) begin
    if (i_flush_sig) begin
        o_pc_next = i_flush_pc; 
    end 
    
    if (i_branch_sig) begin
        o_pc_next = i_branch_pc; 
    end 
    
    if (i_cpu_stall) begin
        o_pc_next = i_pc; 
    end 
    
    if(!i_flush_sig && !i_branch_sig && !i_cpu_stall) begin
        o_pc_next = pc_next_four;
    end

end

always @(posedge i_clk || !i_rst_n) begin 
    
    
    
end

endmodule;