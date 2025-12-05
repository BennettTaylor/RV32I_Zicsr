`timescale 1ns / 1ps
`include "header.vh" 

module program_memory(
    input wire i_clk, // CPU clock
    input wire [31:0] i_pc,
    input wire i_instruction_request, 
    
    output reg [31:0] o_instruction, //To Fetch
    output reg o_awk // 
);
reg [`NUMINST - 1:0] i_program_instructions [31:0];

always @(*) begin
        if (i_instruction_request) begin 
            o_instruction[31:0] <= i_program_instructions[i_pc]; 
            o_awk <= 1; 
        end
        
end

endmodule
