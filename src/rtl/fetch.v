`timescale 1ns / 1ps
`include "header.vh"

module fetch(
    /* Fetch stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire i_flush_sig, // Flush Condition
    input wire [31:0] i_flush_data, // PC taken from Flush I/F 
    input wire i_branch_sig, // Branch Taken Condition, from EXE stage
    input wire [31:0] i_branch_data, // PC from branch prediction 
    input wire i_stall, // CPU Stall Command
    input wire next_inst, // Next Instruction
    
    input wire [31:0] i_inst_mem, // Instruction from memory 
    
    output reg[31:0] o_inst, // Output instruction for decode
    output wire o_mem_req, // Request action 
    output wire o_stall_DDR2, //Stall off-board mem
    output reg[31:0] o_pc 
);
reg[31:0] no_op 32'b//no-op insert
reg[31:0] pc = ////change program counter to variable



always @(posedge i_clk) begin
    
        if(i_rst_n ==1) begin
            i_pc <= 32'b0; 
        else if(i_flush_sig||i_branch_sig)
            i_pc <= i_branch_data;
        else if(i_flush_sig||i_branch_sig)
            i_pc <= i_branch_data;  
        else if(i_stall)
            i_pc <= i_pc; 
            o_stall_DDR2 <= 1; 
        else 
            i_pc <= i_pc + 4;
    end

    // Add second if statement 
    o_pc <= i_pc;
end
    
endmodule
