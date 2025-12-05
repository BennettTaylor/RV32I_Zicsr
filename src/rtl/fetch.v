`timescale 1ns / 1ps
`include "header.vh"

module fetch(
    /* Fetch stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire i_stall, // Stall signal
    input wire i_flush, // Flush signal
    input wire i_jump, // Jump signal
    input wire [`XLEN-1:0] i_jump_addr, // Address for jump
    input wire [31:0] i_inst_data, // Instruction data from memory
    input wire i_inst_ack, // Acknoledgement for instruction data
    
    output reg [31:0] or_inst_data, // Output instruction for decode
    output reg [`XLEN-1:0] or_inst_req_addr, // Address for requested instruction
    output reg or_inst_req, // Request instruction
    output reg or_stall_DDR2, //Stall off-board mem
    output reg[31:0] or_pc  // PC passed to decode
);

reg [31:0] pc; // Program counter
reg [31:0] inst_data; // Instruction data
reg stall; // Stall for instruction request
reg req_complete; // Request completion indicator



always @(posedge i_clk or negedge i_rst_n) begin
    // Set outputs
    if (!i_rst_n) begin
        // Set outputs to 0 for reset signal
        or_pc = 32'b0;
        or_inst_req_addr = 32'b0;
        or_inst_req = 0;
        or_inst_data = 32'b0;
    end else if (stall || i_stall) begin
        // Keep outputs constant if stalled
        or_pc = or_pc;
        or_inst_data = or_inst_data;
    end else if (i_flush) begin
        // Pass on NOP instruction if flush signaled
        or_pc = pc;
        or_inst_data = 31'b00000000000000000000000000010011;
    end else begin
        // Pass on PC and instruction data for normal operation
        or_pc = pc;
        or_inst_data = inst_data;
    end
    
    // Set internal state
    if (!i_rst_n) begin
        // Set all internal state to 0 for reset
        pc = 32'b0;
        inst_data = 32'b0;
        stall = 0;
        req_complete = 0;
    end else if (i_jump) begin
        // Update PC for jump
        pc = i_jump_addr;
        req_complete = 0;
    end else if (i_stall || stall) begin
        // Keep PC constant while stalled
        pc = pc;
    end else begin
        // Increment PC by 4 for normal operation
        pc = pc + 4;
        req_complete = 0;
    end
end

// Handle instruction memory request
always @(*) begin
    stall = 0;
    or_inst_req = 0;
    or_inst_req_addr = 32'b0;
    or_stall_DDR2 = 0;
    if (i_inst_ack && !req_complete) begin
        // If instruction data is ready and hasn't been handled, update system
        inst_data = i_inst_data;
        or_inst_req = 0;
        req_complete = 1;
        stall = 0;
    end else if (!req_complete) begin
        // If request hasn't been complete, request data
        or_inst_req_addr = pc;
        or_inst_req = 1;
        stall = 1;
    end
end
    
endmodule