`timescale 1ns / 1ps
`include "header.vh"

module cpu(
    /* CPU inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n // Active low reset

    /*This is from angeloJacobs, the rest is from ours */

    module rv32i_core #(parameter PC_RESET = 32'h00_00_00_00, TRAP_ADDRESS = 0, ZICSR_EXTENSION = 1) ( 
    input wire i_clk, i_rst_n,
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

//Wires for base register
wire[31:0] rs1_orig;
wire[31:0] rs2_orig;
wire[31:0] rs1;
wire[31:0] rs2;

//Wires for fetch
wire[31:0] fetch_pc;
wire[31:0] fetch_inst;

//Wires for decode
wire[`ALU_WIDTH-1:0] decoder_alu;
wire[`OPCODE_WIDTH-1:0] decoder_opcode;
wire[31:0] decoder_pc;
wire[4:0] decoder_rs1_addr, decoder_rs2_addr;
wire[4:0] decoder_rs1_addr_q, decoder_rs2_addr_q;
wire[4:0] decoder_rd_addr; 
wire[31:0] decoder_imm; 
wire[2:0] decoder_funct3;
wire[`EXCEPTION_WIDTH-1:0] decoder_exception;
wire decoder_ce;
wire decoder_flush;
//Wires for alu
wire[31:0] alu_y; // Result of alu_op
wire[`Oplen-1:0] alu_opcode;
wire[4:0] alu_rs1_addr;
wire[31:0] alu_rs1;
wire[31:0] alu_rs2;
wire[11:0] alu_imm;
wire[2:0] alu_funct3;
wire[31:0] alu_pc;
wire[31:0] alu_next_pc;
wire alu_change_pc;
wire alu_wr_rd;
wire[4:0] alu_rd_addr;
wire[31:0] alu_rd;

//Wires for mem access

//Wires for writeback
//wires for rv32i_writeback
wire writeback_wr_rd; 
wire[4:0] writeback_rd_addr; 
wire[31:0] writeback_rd;
wire[31:0] writeback_next_pc;
wire writeback_change_pc;
wire writeback_ce;
wire writeback_flush;

forward operand_forward (//Forarding unit
.i_rs1_ex(rs1_orig), //Rs1 in basereg
.i_rs2_ex(rs2_orig), //Rs2 in basereg
.i_rs1_addr_ex(decoder_rs1_addr_q), //Address or rs1 in execution
.i_rs2_addr_ex(decoder_rs2_addr_q), //Address or rs2 in execution
.o_rs1(rs1),
.o_rs2(rs2),

// Mem Access
.i_rd_addr(alu_rd_addr), //Destination register address
//ask questions on this and "stage 5"

);

register_file s0( // Base Register Creations
.i_clk(clk),
.i_rs1_addr(decoder_rs1_addr), //source register 1 address
.i_rs2_addr(decoder_rs2_addr), //source register 2 address
.i_rd_addr(writeback_rd_addr),
.i_rd_data(writeback_rd),
.i_wr_en(writeback_wr_rd), 
.or_rs1_data(rs1_orig),
.or_rs2_data(rs2_orig), 
);

fetch s1 ( // logic for fetching instruction [FETCH STAGE , STAGE 1]
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
.or_alu_op(decoder_alu), //Alu 
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

);

endmodule