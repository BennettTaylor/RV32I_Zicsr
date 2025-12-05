`timescale 1ns / 1ps
`include "header.vh"

module cpu(
    /* CPU inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n,// Active low reset

    /*This is from angeloJacobs, the rest is from ours */
  
);
// Wires for Program Memory
wire pm_awk // Program Mem Awk
wire [31:0] pm_instruction // Output Instruction

//Wires for decode
wire decode_or_opcode; // Opcode
wire decode_or_rd_addr; // Destination register address
wire decode_or_rs1_addr; // Source register 1 address for forwarding
wire decode_or_rs2_addr; // Source register 2 address for forwarding
wire decode_or_rs1_data; // Source register 1 value
wire decode_or_rs2_data; // Source register 2 value
wire decode_or_imm; // Immediate value
wire decode_or_funct7; // Funct7
wire decode_or_funct3; // Funct3
wire decode_or_alu_op; // The ALU operation specified
wire decode_or_pc; // Current program counter
wire decode_flush; //Decode Flush
wire decode_stall;
);

//Wires for fetch
wire [31:0] fetch_inst; // Output instruction for decode
wire fetch__mem_req; // Request action 
wire wfetch__stall_program_mem; //Stall off-board mem
wire [31:0] fetch_pc; 

// Wires for execute

wire execute_or_opcode; // Opcode
wire execute_or_funct3; // Funct3
wire execute_or_rs2_data; // Data to be written
wire execute_or_rd_addr; // Destination register address
wire execute_or_rd_wr_en; // RD write enable
wire execute_or_alu_result;
wire execute_or_pc; // Current program counter
wire execute_or_pc_next; // Next program counter for jumps
wire execute_or_pc_jump; // Jump signal
wire execute_or_stall; // Output stall signal
wire execute_or_flush; // Output flush signal


//Wires for mem access
wire memory_or_pc; // Current program counter
wire memory_or_rd_addr; // Register to be writen to
wire memory_or_rd_write; // Write enable for rd
wire memory_or_rd_data; // Data to be written to rd
wire memory_or_opcode; // Opcode
wire memory_or_mem_req; // Memory request signal
wire memory_or_mem_addr; // Memory address requested for read/write
wire memory_or_mem_data; // Data to be written to memory
wire memory_or_funct3; // Indicates what kind of memory operation is being performed
wire memory_or_read_write; // Indicates read (0) or write (1) operation
wire memory_or_flush; // Flush signal to external stages
wire memory_or_stall; // Stall signal to external stages


//Wires for writeback
wire writeback_ir_rd_addr; // Register to be writen to
wire writeback_ir_rd_write; // Write enable for rd
wire writeback_ir_rd_data; // Data to be written to rd
wire writeback_or_stall;
wire writeback_or_flush;


//wires for rv32i_writeback Placeholder 


fetch s1( // logic for fetching instruction [FETCH STAGE , STAGE 1]
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_branch_sig(execute_or_pc_jump),
.i_flush_data(executre_or_pc_next),
.i_stall(execute_or_stall), 
.i_inst_mem(pm_instruction)

); 

decode s2( // Logic for decode
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_inst(fetch_inst), //32 bit instruction
.i_pc(fetch_pc), //PC value from fetch stage
// Do we need the rd_addr or rd_data??
//Insert stalls here
);

execute s3(//Alu Logic
.i_clk(i_clk), // CPU clock
.i_rst_n(i_rst_n), // Active low reset
.i_opcode(decode_or_opcode), // Opcode
.i_rd_addr(decode_or_rd_addr) // Destination register address
.i_rd_wr_en(writeback_ir_wd_write),
.i_rd_mem(memory_or_rd_data), // RD value for instruction currently in the memory stage
.i_rd_addr_mem(memory_or_addr), // RD address for instruction currently in the memory stage
.i_rd_mem_wr_en(memory_or_rd_write),  // Register file write enable for the instruction currently in the memory stage 
.i_rd_wb(writeback_ir_rd_data), // RD value for instruction currently in the write back stage
.i_rd_addr_wb(writeback_ir_rd_addr), // RD address for instruction currently in the write back stage
.i_rd_wb_wr_en(writeback_ir_rd_write),  // Register file write enable for the instruction currently in the write back stage
//Do these need to be in here? and is the above a copy?
.i_rs1_addr, // Source register 1 address for forwarding
.i_rs2_addr, // Source register 2 address for forwarding
.i_rs1_data, // Source register 1 value
.i_rs2_data, // Source register 2 value
.i_imm(decode_or_imm), // Immediate value
.i_funct7(decode_or_funct7), // Funct7
.i_funct3(decode_or_funct3, // Funct3
.i_alu_op(decode_or_alu_op), // The ALU operation specified
.i_pc(decode_or_pc), // Current program counter
.i_flush(memory_or_flush), // Flush signal from external stages
.i_stall(memory_or_stall), // Stall signals from external stages

);

memory s4 (//Logic For memory
/* Memory stage inputs */
,i(i_clk),
.i(i_rst_n),
.i_opcode(alu_or_opcode), // Opcode
.i_funct3(alu_funct3),
.i_rs2(alu_or_rs2), // Data to be written
.i_rd_addr(decoder_rd_addr), // Destination register address
//Fix write enable.i_rd_write(decoder_), // Write enable for rd
.i_alu_result(alu_ow_result),
.i_pc(decoder_pc), // Current program counter
//Fix mem awk.i_mem_ack(), // Acknoledgement from memory (data is ready for read/written to)
//Fetch ??.i_mem_data(), // Data from memory address requested
//Add Flush .i_flush, // Flush signal from external stages
//Add Stall .i_stall(), // Stall signals from external stages

/* Memory stage outputs */
.or_pc(memory_or_pc), // Current program counter
.or_rd_addr(memory_or_rd_addr), // Register to be writen to
.or_rd_write(memory_or_rd_write), // Write enable for rd
.or_rd_data(memory_or_rd_data), // Data to be written to rd
.or_opcode(memory_or_opcode), // Opcode
.or_mem_req(memory_or_mem_req), // Memory request signal
.or_mem_addr(memory_or_mem_addr), // Memory address requested for read/write
.or_mem_data(memory_or_mem_data), // Data to be written to memory
.or_funct3(memory_or_funct3), // Indicates what kind of memory operation is being performed
.or_read_write(memory_or_read_write), // Indicates read (0) or write (1) operation
// Do flush output reg or_flush(), // Flush signal to external stages
// Do stall output reg or_stall // Stall signal to external stages
);



endmodule;
