`timescale 1ns / 1ps
`include "header.vh"

module fetch(
    /* Fetch stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire i_flush_sig, // Flush Condition
    input wire [31:0] i_flush_data, // PC taken from Flush I/F 
    input wire i_branch_sig, // Branch Taken Condition
    input wire [31:0] i_branch_data, // PC from branch prediction 
    input wire i_stall, // CPU Stall Command
    
    input wire [31:0] i_inst_mem, // Instruction from memory
    input wire [31:0] i_pc, // Program Counter 
    
    output wire o_inst, // Output instruction for decode
    output wire o_mem_req // Request action 
);

always @(posedge i_clk) begin
    

end

endmodule;