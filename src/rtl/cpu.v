`timescale 1ns / 1ps
`include "header.vh"

module cpu(
    /* CPU inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n,// Active low reset

    /*This is from angeloJacobs, the rest is from ours */
    //Instruction Memory Interface (32 bit rom)
    input wire[31:0] i_inst, //32-bit instruction
    output wire[31:0] o_iaddr, //address of instruction 
    output wire o_stb_inst, //request for read access to instruction memory
    input wire i_ack_inst, //ack (high if new instruction is ready)
    //Data Memory Interface (32 bit ram)
    output wire o_wb_cyc_data, //bus cycle active (1 = normal operation, 0 = all ongoing transaction are to be cancelled)
    output wire o_wb_stb_data, //request for read/write access to data memory
    output wire o_wb_we_data, //write-enable (1 = write, 0 = read)
    output wire[31:0] o_wb_addr_data, //address of data memory for store/load
    output wire[31:0] o_wb_data_data, //data to be stored to memory
    output wire[3:0] o_wb_sel_data, //byte strobe for write (1 = write the byte) {byte3,byte2,byte1,byte0}
    input wire i_wb_ack_data, //ack by data memory (high when read data is ready or when write data is already written)
    input wire i_wb_stall_data, //stall by data memory 
    input wire[31:0] i_wb_data_data, //data retrieve from memory
    //Interrupts
    input wire i_external_interrupt, //interrupt from external source
    input wire i_software_interrupt, //interrupt from software (inter-processor interrupt)
    input wire i_timer_interrupt //interrupt from timer
);

//Wires for fetch
wire[31:0] fetch_pc;
wire[31:0] fetch_inst;

//Wires for decode
wire[`Oplen-1:0] decoder_opcode;
wire[31:0] decoder_pc;
wire[4:0] decoder_rs1_addr, decoder_rs2_addr;
wire[4:0] decoder_rs1_addr_q, decoder_rs2_addr_q;
wire[4:0] decoder_rd_addr; 
wire[31:0] decoder_imm; 
wire[2:0] decoder_funct3;
wire decoder_ce;
wire decoder_flush;

//Wires for alu
wire [31:0] alu_or_rs1; //Source register 1 value
wire [31:0] alu_or_rs2; //Source register 2 value
wire [11:0] alu_or_imm; //Immediate value
wire [2:0] alu_or_funct3; // function type
wire [4:0] alu_r_rs1_addr; //address for register source 1
wire [6:0] alu_or_opcode; //opcode type 
wire [`XLEN-1:0] alu_ow_result;// ALU result

//Wires for mem access
wire memory_or_pc; // Current program counter
wire memory_or_rd_addr; // Register to be writen to
wire memory_r_rd_write; // Write enable for rd
wire memory_or_rd_data; // Data to be written to rd
wire memory_or_opcode; // Opcode
wire memory_or_mem_req; // Memory request signal
wire memory_or_mem_addr; // Memory address requested for read/write
wire memory_or_mem_data; // Data to be written to memory
wire emory_or_funct3; // Indicates what kind of memory operation is being performed
wire memory_or_read_write; // Indicates read (0) or write (1) operation
wire memory_or_flush; // Flush signal to external stages
wire memory_or_stall; // Stall signal to external stages


//Wires for writeback
wire writeback_or_rd_addr; // Register to be writen to
wire writeback_or_rd_write; // Write enable for rd
wire writeback_or_rd_data; // Data to be written to rd
wire writeback_or_stall;
wire writeback_or_flush;
wire writeback_wr_rd; 

//wires for rv32i_writeback Placeholder 


fetch s1( // logic for fetching instruction [FETCH STAGE , STAGE 1]
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.o_iaddr(o_iaddr), //Instruction address
.o_pc(fetch_pc), //PC value of o_inst
.i_inst(i_inst), // retrieved instruction from Memory
.o_inst(fetch_inst), // instruction
.o_stb_inst(o_stb_inst), // request for instruction
.i_ack_inst(i_ack_inst), //ack (high if new instruction is ready)
// PC Control
.i_writeback_change_pc(writeback_change_pc), //high when PC needs to change when going to trap or returning from trap
.i_writeback_next_pc(writeback_next_pc), //next PC due to trap
.i_alu_change_pc(alu_change_pc), //high when PC needs to change for taken branches and jumps
.i_alu_next_pc(alu_next_pc), //next PC due to branch or jump
/// Pipeline Control ///
.o_ce(decoder_ce), // output clk enable for pipeline stalling of next stage
.i_stall((stall_decoder || stall_alu || stall_memoryaccess || stall_writeback)), //informs this stage to stall
.i_flush(decoder_flush) //flush this stage
); 

decode s2( // Logic for decode
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_inst(fetch_inst), //32 bit instruction
.i_pc(fetch_pc), //PC value from fetch stage
.or_rs1_addr(decoder_rs2_addr_q), // Source register 1 address for forwarding
.or_rs2_addr(decoder_rs2_addr_q), // Source register 2 address for forwarding
.or_rd_addr(decoder_rd_addr),
.or_imm(decoder_imm), // Does this need to be a wire in decode??
.or_funct7(decoder_funct3), //Function3 
.or_opcode(decoder_opcode), //Opcode
.or_alu_op(decoder_alu) //Alu 
//Insert stalls here
);

alu s3(//Alu Logic
// Have the ALU operation changed HERE//
.i_alu_op(decoder_alu), //Alu Operation
.i_data_1(rs1), //Alu Data
.i_data_2(rs2), //This needs to be changed, does it need more its own funct3, rs1, rd?



.i_rs1_addr(decoder_rs1_addr_q), //address for register source 1
.i_imm_de(decoder_imm), //Immediate value from decode
.i_funct3_de(decoder_funct3), //function type from decode
.i_opcode_de(decoder_opcode), //opcode type from decode

.or_rs1(alu_rs1), //Source register 1 value
.or_rs2(alu_rs2), //Source register 2 value
.or_imm(alu_imm), //Immediate value
.or_funct3(alu_funct3), // function type
.or_rs1_addr(alu_rs1_addr), //address for register source 1
.or_opcode(alu_opcode), //opcode type 
.ow_result(alu_y) //Alu result

);

memory s4 (//Logic For memory

    

);



endmodule;