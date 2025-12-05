`timescale 1ns / 1ps
`include "header.vh" 

module program_memory(
    input wire i_clk, // CPU clock
    input wire [31:0] i_pc,
    input reg ['col:0] i_program_instructions [31:0],
    input reg ['mem:0] i_data_memory [31:0]
    input wire i_instruction_request,
    input wire i_data_write_request,
    input wire i_data_read_request, 
    
    
    output reg [31:0] o_instruction //To Fetch -> Decode

    output wire o_awk // 
);
reg [31:0] instruction;
reg [31:0] program_counter;

always @(posedge i_clk) begin
        instruction[31:0] <= i_program_instructions[i_pc]; 
end
always(*)begin
    if(i_instruction_request) begin
        o_instruction <= instruction 
    end
    program_counter <= i_pc;
end

endmodule
