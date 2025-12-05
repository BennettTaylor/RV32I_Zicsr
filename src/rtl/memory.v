`timescale 1ns / 1ps
`include "header.vh"

module memory(
    /* Memory stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire [`OPLEN-1:0] i_opcode, // Opcode
    input wire [2:0] i_funct3,
    input wire [`XLEN-1:0] i_rs2, // Data to be written
    input wire [`XADDR-1:0] i_rd_addr, // Destination register address
    input wire i_rd_write, // Write enable for rd
    input wire [`XLEN-1:0] i_alu_result,
    input wire [`XLEN-1:0] i_pc, // Current program counter
    input wire i_mem_ack, // Acknoledgement from memory (data is ready for read/written to)
    input wire [`XLEN-1:0] i_mem_data, // Data from memory address requested
    input wire i_flush, // Flush signal from external stages
    input wire i_stall, // Stall signals from external stages
    
    /* Memory stage outputs */
    output reg [`XLEN-1:0] or_pc, // Current program counter
    output reg [`XADDR-1:0] or_rd_addr, // Register to be writen to
    output reg or_rd_write, // Write enable for rd
    output reg [`XLEN-1:0] or_rd_data, // Data to be written to rd
    output reg [`OPLEN-1:0] or_opcode, // Opcode
    output reg or_mem_req, // Memory request signal
    output reg [`XLEN-1:0] or_mem_addr, // Memory address requested for read/write
    output reg [`XLEN-1:0] or_mem_data, // Data to be written to memory
    output reg [2:0] or_funct3, // Indicates what kind of memory operation is being performed
    output reg or_read_write, // Indicates read (0) or write (1) operation
    output reg or_flush, // Flush signal to external stages
    output reg or_stall, // Stall signal to external stages
    output reg [2:0] or_funct_3_wb //
);

reg [`XLEN-1:0] rd_data;
reg misaligned_addr;
reg req_complete; // Request completion indicator

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        /* Set all output and internal state to 0 */
        or_pc <= 0;
        or_rd_addr <= 0;
        or_rd_write <= 0;
        or_rd_data <= 0;
        or_opcode <= 0;
        or_mem_req <= 0;
        or_mem_data <=0;
        or_read_write <= 0;
        or_funct3 <=0; 
        or_mem_addr <= 0;
        or_flush <= 0;
        or_stall <= 0;
        or_funct_3_wb <=0; 
    end else if (i_flush || or_flush) begin
        /* Make current instruction a NOP instruction (ADDI x0, x0, 0) */
        or_pc <= i_pc;
        or_rd_addr <= 0;
        or_rd_write <= 1;
        or_rd_data <= 0;
        or_opcode <= `I_OP;
        or_mem_req <= 0;
        or_mem_addr <= 0;
        or_flush <= 0;
        or_stall <= 0;
        or_funct_3_wb <=0;
    end else if (i_stall || or_stall) begin
        /* Hold current state */
        or_pc <= or_pc;
        or_rd_addr <= or_rd_addr;
        or_rd_write <= or_rd_write;
        or_rd_data <= rd_data;
        or_opcode <= or_opcode;
        or_mem_req <= or_mem_req;
        or_mem_addr <= or_mem_addr;
        or_flush <= or_flush;
        or_stall <= or_stall;
        or_funct_3_wb <= or_funct_3_wb;
    end else begin
        /* Pass result to write back stage */
        or_pc <= i_pc;
        or_rd_addr <= i_rd_addr;
        or_rd_write <= i_rd_write;
        or_rd_data <= rd_data;
        or_opcode <= i_opcode;
        or_mem_req <= 0;
        or_mem_addr <= 0;
        or_flush <= 0;
        or_stall <= 0;
        or_funct_3_wb <=i_funct3;
    end
    
    req_complete = 0;
end

/* Generate memory request */
always @(*) begin
    misaligned_addr = 0;
    if ((i_opcode == `L_OP) && !req_complete) begin
        /* Handle load operation */
        case (i_funct3)
            /* Load byte */
            3'b000: begin
                or_mem_addr = i_alu_result;
                or_read_write = 0;
                or_mem_req = 1;
                or_stall = 1'b1;
                or_funct3 = i_funct3;
            end
            
            /* Load half word */
            3'b001: begin
                if (i_alu_result[0] == 1) begin
                    or_read_write = 0;
                    or_mem_req = 0;
                    or_stall = 1'b1;
                    or_funct3 = i_funct3;
                    misaligned_addr = 1;
                end else begin
                    or_mem_addr = i_alu_result;
                    or_read_write = 0;
                    or_mem_req = 1;
                    or_stall = 1'b1;
                    or_funct3 = i_funct3;
                end
            end
            
            /* Load word */
            3'b010: begin
                if (i_alu_result[1:0] != 2'b00) begin
                    or_read_write = 0;
                    or_mem_req = 0;
                    or_stall = 1'b1;
                    or_funct3 = i_funct3;
                    misaligned_addr = 1;
                end else begin
                    or_mem_addr = i_alu_result;
                    or_read_write = 0;
                    or_mem_req = 1;
                    or_stall = 1'b1;
                    or_funct3 = i_funct3;
                end
            end
        endcase
    end else if ((i_opcode == `S_OP) && !req_complete) begin
        /* Handle store operation */
        case (i_funct3)
            /* Load byte */
            3'b000: begin
                or_mem_addr = i_alu_result;
                or_mem_data = i_rs2;
                or_read_write = 1;
                or_mem_req = 1;
                or_stall = 1'b1;
                or_funct3 = i_funct3;
            end
            
            /* Load half word */
            3'b001: begin
                if (i_alu_result[0] == 1) begin
                    or_read_write = 1;
                    or_mem_req = 0;
                    or_stall = 1'b1;
                    or_funct3 = i_funct3;
                    misaligned_addr = 1;
                end else begin
                    or_mem_addr = i_alu_result;
                    or_mem_data = i_rs2;
                    or_read_write = 1;
                    or_mem_req = 1;
                    or_stall = 1'b1;
                    or_funct3 = i_funct3;
                end
            end
            
            /* Load word */
            3'b010: begin
                if (i_alu_result[1:0] != 2'b00) begin
                    or_read_write = 1;
                    or_mem_req = 0;
                    or_stall = 1'b1;
                    or_funct3 = i_funct3;
                    misaligned_addr = 1;
                end else begin
                    or_mem_addr = i_alu_result;
                    or_mem_data = i_rs2;
                    or_read_write = 1;
                    or_mem_req = 1;
                    or_stall = 1'b1;
                    or_funct3 = i_funct3;
                end
            end
        endcase
        
        /* Construct data to be stored to memory */
        case (i_funct3)
            /* Store byte */
            3'b000: begin
                case (i_alu_result[1:0])
                    2'b00: begin
                        or_mem_data = {24 * 0, i_rs2[7:0]}; 
                    end
                    
                    2'b01: begin
                        or_mem_data = {24 * 0, i_rs2[15:8]};
                    end
                    
                    2'b10: begin
                        or_mem_data = {24 * 0, i_rs2[23:16]};
                    end
                    
                    2'b11: begin
                        or_mem_data = {24 * 0, i_rs2[31:24]};
                    end
                endcase
            end
            
            /* Store half word */
            3'b001: begin
                case (i_alu_result[1])
                    1'b0: begin
                        or_mem_data = {16 * 0, i_rs2[15:0]};
                    end
                    
                    1'b1: begin
                        or_mem_data = {16 * 0, i_rs2[31:16]};
                    end
                endcase                
            end
            
            /* Store word */
            3'b010: begin
                or_mem_data = i_rs2;
            end
        endcase
    end else begin
        /* Not a memory operation */
        rd_data = i_alu_result;
    end
end

/* Handle memory request acknoledgement */
always @(posedge i_mem_ack) begin
    if (i_opcode == `L_OP) begin
        /* Handle load operation */
        rd_data = i_mem_data;
    end
    
    /* Stop request */
    or_mem_req = 1'b0;
    or_stall = 1'b0;
    or_mem_data = 32'b0;
    or_mem_addr = 32'b0;
    req_complete = 1;
end

endmodule
