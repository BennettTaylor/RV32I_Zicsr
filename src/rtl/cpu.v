`timescale 1ns / 1ps
`include "header.vh"

module cpu(
    /* CPU inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n,// Active low reset
    
    input wire i_inst_ack, 
    input wire i_inst_received, 
    input wire i_data_ack,
    input wire i_data_received,
    
    output reg o_inst_req,
    output reg [`XADDR:0] o_inst_addr,
    output reg o_data_req,
    output reg [`XADDR:0] o_data_addr,
    output reg [2:0] o_size_delineator,
    output reg o_readwrite_signal
    
    // Instruction (fetch)
    // Request signal o
    // Requested address o
    // Acknoledgement signal i
    // Data recieved i
    
    // Data (memory)
    // Request signal o
    // Requested address o
    // Acknoledgement signal i
    // Data recieved i
    // Byte, half-word, word signal (2 bits) o
    
);


//Wires for decode
wire [`OPLEN:0] decode_or_opcode; // Opcode
wire [`XADDR-1:0] decode_or_rd_addr; // Destination register address
wire [`XADDR-1:0] decode_or_rs1_addr; // Source register 1 address for forwarding
wire [`XADDR-1:0] decode_or_rs2_addr; // Source register 2 address for forwarding
wire [`XLEN-1:0] decode_or_rs1_data; // Source register 1 value
wire [`XLEN-1:0] decode_or_rs2_data; // Source register 2 value
wire [`XLEN-1:0] decode_or_imm; // Immediate value
wire [6:0] decode_or_funct7; // Funct7
wire [2:0] decode_or_funct3; // Funct3
wire [`ALUOPS-1:0] decode_or_alu_op; // The ALU operation specified
wire [`XLEN-1:0]decode_or_pc; // Current program counter
wire decode_flush; //Decode Flush
wire decode_stall;
wire decode_or_write_enable; //Write enable for execution 


//Wires for fetch
wire [31:0] fetch_or_inst_data; // Output instruction for decode
wire [31:0] fetch_or_inst_req_addr; // Address for requested instruction
wire fetch_or_inst_req; // Request instruction
wire fetch_or_stall_DDR2; //Stall off-board mem
wire [31:0] fetch_or_pc;  // PC passed to decode

// Wires for execute
wire [`OPLEN:0] execute_or_opcode; // Opcode
wire [2:0] execute_or_funct3; // Funct3
wire [`XLEN-1:0] execute_or_rs2_data; // Data to be written
wire [`XADDR-1:0] execute_or_rd_addr; // Destination register address
wire execute_or_rd_wr_en; // RD write enable
wire [`XLEN-1:0] execute_or_alu_result;
wire [`XLEN-1:0] execute_or_pc; // Current program counter
wire [`XLEN-1:0] execute_or_pc_next; // Next program counter for jumps
wire execute_or_pc_jump; // Jump signal
wire execute_or_stall; // Output stall signal
wire execute_or_flush; // Output flush signal


//Wires for mem access
wire [`XLEN-1:0] memory_or_pc; // Current program counter
wire [`XADDR-1:0] memory_or_rd_addr; // Register to be writen to
wire memory_or_rd_write; // Write enable for rd
wire [`XLEN-1:0] memory_or_rd_data; // Data to be written to rd
wire [`OPLEN-1:0]memory_or_opcode; // Opcode
wire memory_or_mem_req; // Memory request signal
wire [`XLEN-1:0] memory_or_mem_addr; // Memory address requested for read/write
wire [`XLEN-1:0] memory_or_mem_data; // Data to be written to memory
wire [2:0] memory_or_funct3; // Indicates what kind of memory operation is being performed
wire memory_or_flush; // Flush signal to external stages
wire memory_or_stall; // Stall signal to external stages


//Wires for writeback
wire [`XADDR-1:0] writeback_or_rd_addr; // Register to be writen to
wire writeback_or_rd_write; // Write enable for rd
wire [`XLEN-1:0] writeback_or_rd_data; // Data to be written to rd
wire writeback_or_stall;
wire writeback_or_flush;


//wires for rv32i_writeback Placeholder 


fetch s1( // logic for Fetch Stage

//Fetch Stage Inputs//

.i_clk(i_clk), // CPU clock
.i_rst_n(i_rst_n), // Active low reset
.i_stall(decode_stall), // Stall signal
.i_flush(decode_flush), // Flush signal
.i_jump(execute_pc_jump), // Jump signal
.i_jump_addr(execute_or_pc_next), // Address for jump
.i_inst_data(o_inst_addr), // Instruction data from memory
.i_inst_ack(i_inst_ack), // Acknoledgement for instruction data

//Fetch Stage Outputs//
.or_inst_data(fetch_or_inst_data), // Output instruction for decode
.or_inst_req_addr(fetch_or_inst_req_addr), // Address for requested instruction
.or_inst_req(fetch_or_inst_req), // Request instruction
.or_stall_DDR2(fetch_or_stall_DDR2), //Stall off-board mem
.or_pc(fetch_or_pc)  // PC passed to decode

); 

decode s2( // Logic for decode

//Wires For Decode Input//
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_inst(fetch_or_inst_data), //32 bit instruction
.i_pc(fetch_or_pc), 
.i_rd_addr(writeback_or_rd_addr),
.i_rd_data(writeback_or_rd_data),
.i_wr_en(writeback_or_rd_write),
.i_flush(execute_or_flush),
.i_stall(execute_or_stall),

//Wires for Decode Output 
.or_opcode(decode_or_opcode), // Opcode
.or_rd_addr(decode_or_rd_addr), // Destination register address
.or_rs1_addr(decode_or_rs1_addr), // Source register 1 address for forwarding
.or_rs2_addr(decode_or_rs2_addr), // Source register 2 address for forwarding
.or_rs1_data(decode_or_rs1_data), // Source register 1 value
.or_rs2_data(decode_or_rs2_data), // Source register 2 value
.or_imm(decode_or_imm), // Immediate value
.or_funct7(decode_or_funct7), // Funct7
.or_funct3(decode_or_funct3), // Funct3
.or_alu_op(decode_or_alu_op), // The ALU operation specified
.or_pc(decode_or_pc), // Current program counter
.or_write_enable(decode_or_write_enable), //Write enable to be passed along
.or_stall(decode_stall) 


);

execute s3(
//Wires For Execute Input//
.i_clk(i_clk), // CPU clock
.i_rst_n(i_rst_n), // Active low reset
.i_opcode(decode_or_opcode), // Opcode
.i_rd_addr(decode_or_rd_addr), // Destination register address
.i_rd_wr_en(decode_or_write_enable),
.i_rd_mem(memory_or_rd_data), // RD value for instruction currently in the memory stage
.i_rd_addr_mem(memory_or_addr), // RD address for instruction currently in the memory stage
.i_rd_mem_wr_en(memory_or_rd_write),  // Register file write enable for the instruction currently in the memory stage 
.i_rd_wb(writeback_or_rd_data), // RD value for instruction currently in the write back stage
.i_rd_addr_wb(writeback_or_rd_addr), // RD address for instruction currently in the write back stage
.i_rd_wb_wr_en(writeback_or_rd_write),  // Register file write enable for the instruction currently in the write back stage
.i_rs1_addr(decode_or_rs1_addr), // Source register 1 address for forwarding
.i_rs2_addr(decode_or_rs2_addr), // Source register 2 address for forwarding
.i_rs1_data(decode_or_rs1_data), // Source register 1 value
.i_rs2_data(decode_or_rs2_data), // Source register 2 value
.i_imm(decode_or_imm), // Immediate value
.i_funct7(decode_or_funct7), // Funct7
.i_funct3(decode_or_funct3), // Funct3
.i_alu_op(decode_or_alu_op), // The ALU operation specified
.i_pc(decode_or_pc), // Current program counter
.i_flush(memory_or_flush), // Flush signal from external stages
.i_stall(memory_or_stall), // Stall signals from external stages

//Wires For Execute Output
.or_opcode(execute_or_opcode), // Opcode
.or_funct3(execute_or_funct3), // Funct3
.or_rs2_data(execute_or_rs2_data), // Data to be written
.or_rd_addr(execute_or_rd_addr), // Destination register address
.or_rd_wr_en(execute_or_rd_wr_en), // RD write enable
.or_alu_result(execute_or_alu_result),
.or_pc(execute_or_pc), // Current program counter
.or_pc_next(execute_or_pc_next), // Next program counter for jumps
.or_pc_jump(execute_or_pc_jump), // Jump signal
.or_stall(execute_or_stall), // Output stall signal
.or_flush(execute_or_flush)// Output flush sign

);

memory s4 (//Logic For memory
/* Memory stage inputs */
.i(i_clk),
.i(i_rst_n),
.i_opcode(execute_or_opcode), // Opcode
.i_funct3(execute_or_funct3),
.i_rs2(execute_or_rs2_data), // Data to be written
.i_rd_addr(execute_or_rd_add),
.i_rd_write(execute_or_rd_wr_en),
.i_alu_result(execute_or_alu_result),
.i_pc(execute_or_pc), 
.i_mem_awk(i_data_ack),
.i_mem_data(o_data_addr),
.i_flush(writeback_or_flush),
.i_stall(writeback_or_stall), 

/*Memory stage outuputs */
.or_pc(memory_or_pc), // Current program counter
.or_rd_addr(memory_or_rd_addr), // Register to be writen to
.or_rd_write(memory_or_rd_write), // Write enable for rd
.or_rd_data(emory_or_rd_data), // Data to be written to rd
.or_opcode(memory_or_opcode), // Opcode
.or_mem_req(memory_or_mem_req), // Memory request signal
.or_mem_addr(memory_or_mem_addr), // Memory address requested for read/write
.or_mem_data(memory_or_mem_data), // Data to be written to memory
.or_funct3(memory_or_funct3), // Indicates what kind of memory operation is being performed
.or_read_write(o_readwrite_signal), // Indicates read (0) or write (1) operation
.or_flush(memory_or_flush), // Flush signal to external stages
.or_stall(memory_or_stall) // Stall signal to external stages
);

write_back s5(// Logic for Write Back)
// Write Back Inputs 
.i_clk(i_clk), // CPU clock
.i_rst_n(i_rst_n), // Active low reset
.i_rd_addr(execute_or_rd_addr), // Register to be writen to
.i_rd_write(execute_or_rd_wr_en), // Write enable for rd
.i_rd_data(execute_or_rd_addr), // Data to be written to rd
.i_pc(execute_or_pc), // Current program counter
.i_opcode(execute_or_opcode), // Opcode
.i_funct3(execute_or_funct3), // Funct3 (for CSR instructions)

//Write Back Outputs
.or_rd_addr(writeback_ir_rd_addr), // Register to be writen to
.or_rd_write(writeback_ir_rd_write), // Write enable for rd
.or_rd_data(writeback_ir_rd_data), // Data to be written to rd
.or_stall(writeback_or_stall),
.or_flush(writeback_or_flush)
);

endmodule;
