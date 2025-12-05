`timescale 1ns / 1ps
`include "header.vh" 

module program_memory #(
    parameter INIT_FILE = ""
) (
    input wire [31:0] i_pc, // Instruction address
    input wire i_instruction_request, // Instruction request signal
    
    output reg [31:0] or_instruction, // Instruction data
    output reg or_ack // Acknoledgement signal
);
/* Instruction data */
reg [`NUMINST-1:0] program_instructions [31:0];
integer i;

initial begin 
    for (i = 0; i < 2 ** `MEMSIZE; i = i + 1) begin
        program_instructions[i] = 32'b0;
    end
    
    if (INIT_FILE != "") begin
        $readmemh(INIT_FILE, program_instructions);
    end
end

/* Answer request */
always @(*) begin
        if (i_instruction_request) begin 
            or_instruction <= program_instructions[i_pc[`NUMINST-1:0]]; 
            or_ack <= 1; 
        end else begin
            or_ack <= 0;
        end
end

endmodule