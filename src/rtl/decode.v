`timescale 1ns / 1ps
`include "header.vh"

module decode(
    /* Decode stage inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire [`XLEN-1:0] i_inst, // Instruction from instruction memory
    input wire [`XLEN-1:0] i_pc, // Current program counter
    input wire [`XADDR-1:0] i_rd_addr, // register address for  
    input wire [`XLEN-1:0] i_rd_data, // Data to be writen to register file
    input wire i_wr_en, // Write enable for the register file
    input wire i_stall, 
    input wire i_flush,

    /* Decode stage output registers */
    output reg [`OPLEN-1:0] or_opcode, // Opcode
    output reg [`XADDR-1:0] or_rd_addr, // Destination register address
    output reg [`XADDR-1:0] or_rs1_addr, // Source register 1 address for forwarding
    output reg [`XADDR-1:0] or_rs2_addr, // Source register 2 address for forwarding
    output reg [`XLEN-1:0] or_rs1_data, // Source register 1 value
    output reg [`XLEN-1:0] or_rs2_data, // Source register 2 value
    output reg [`XLEN-1:0] or_imm, // Immediate value
    output reg [6:0] or_funct7, // Funct7
    output reg [2:0] or_funct3, // Funct3
    output reg [`ALUOPS-1:0] or_alu_op, // The ALU operation specified
    output reg [`XLEN-1:0] or_pc, // Current program counter
    output reg or_write_enable, //Write enable to be passed along
    output reg or_stall, 
    output reg or_flush
);



/* Assign rs1 and rs2 address wires for register file */
wire [`XADDR-1:0] rs1_addr = i_inst[19:15];
wire [`XADDR-1:0] rs2_addr = i_inst[24:20];

/* Generate opcode & funct wires */
wire [`OPLEN-1:0] opcode = i_inst[`OPLEN-1:0]; 
wire [2:0] funct3 = i_inst[14:12];
wire [6:0] funct7 = i_inst[31:25];

/* Wires for register file */
wire [`XLEN-1:0] rs1_data; 
wire [`XLEN-1:0] rs2_data; 

/* Registers for storing calculated values */
reg [`XLEN-1:0] imm;
reg [`ALUOPS-1:0] alu_op;

/* Assign Write Enable*/
reg write_enable;

/* Instantiate register file */
register_file registers(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_wr_en(i_wr_en),
    .i_rs1_addr(rs1_addr),
    .i_rs2_addr(rs2_addr),
    .i_rd_addr(i_rd_addr),
    .i_rd_data(i_rd_data),
    .or_rs1_data(rs1_data),
    .or_rs2_data(rs2_data)
);

/* Assign register outputs */
always @(posedge i_clk) begin
    if (!i_rst_n) begin
        or_opcode <= 0;
        or_rd_addr <= 0;
        or_rs1_addr <= 0;
        or_rs2_addr <= 0;
        or_rs1_data <= 0;
        or_rs2_data <= 0;
        or_imm <= 0;
        or_funct7 <= 0;
        or_funct3 <= 0;
        or_funct7 <= 0; 
        or_alu_op <= 0;
        or_pc <= 0;
        or_flush <=0; 
        or_stall <=0; 
        or_write_enable <=0; 
    end else if (i_stall || or_stall) begin
        or_opcode <= 0;
        or_rd_addr <= 0;
        or_rs1_addr <= 0;
        or_rs2_addr <= 0;
        or_rs1_data <= 0;
        or_rs2_data <= 0;
        or_imm <= 0;
        or_funct7 <= 0;
        or_funct3 <= 0;
        or_funct7 <= 0; 
        or_alu_op <= 0;
        or_pc <= 0;
    end else if(i_flush) begin
        or_opcode <= 0;
        or_rd_addr <= 0;
        or_rs1_addr <= 0;
        or_rs2_addr <= 0;
        or_rs1_data <= 0;
        or_rs2_data <= 0;
        or_imm <= 0;
        or_funct7 <= 0;
        or_funct3 <= 0;
        or_funct7 <= 0; 
        or_alu_op <= 0;
        or_pc <= 0;
    end else begin
        or_opcode <= opcode;
        or_rd_addr <= i_inst[11:7];
        or_rs1_addr <= rs1_addr;
        or_rs2_addr <= rs2_addr;
        or_rs1_data <= rs1_data;
        or_rs2_data <= rs2_data;
        or_imm <= imm;
        or_funct7 <= i_inst[31:25];
        or_funct3 <= funct3;
        or_funct7 <= funct7; 
        or_alu_op <= alu_op;
        or_pc <= i_pc;
    end
    
end

/* Calculate needed values */
always @(*) begin
    /* Reset registers */
    alu_op = 0;
    imm = 0;
     
    write_enable = 1; 
    case(opcode)
        `LUI_OP, `AUIPC_OP: begin
            /* Immediate encoding for U-Type instruction */
            imm[31:12] = i_inst[31:12]; 
            imm[11:0] = 12'b000000000000;
            alu_op = `ADD;
        end 
        
        `JAL_OP: begin
            /* Immediate encoding for JAL instruction */
            imm[31:20] = i_inst[31];
            imm[19:12] = i_inst[19:12];
            imm[11] = i_inst[20];
            imm[10:1] = i_inst[30:21]; 
            imm[0] = 1'b0;
            alu_op = `ADD;
        end
        
        `L_OP, `JALR_OP: begin
        // Case Statement for I-Type
            imm[31:12] = i_inst[31];
            imm[11:0] = i_inst[31:20];
            alu_op = `ADD;
        end
        
        `S_OP: begin
        // Case Statement for S-Type
            imm[31:12] = i_inst[31];
            imm[11:5] = i_inst[31:25];
            imm[4:0] = i_inst[11:7];
            write_enable = 0; 
        end 
        
        `B_OP: begin
        // Case Statement for B-Type
            imm[31:12] = i_inst[31];
            imm[11] = i_inst[7]; 
            imm[10:5] = i_inst[30:25]; 
            imm[4:1] = i_inst[11:8]; 
            imm[0] = 1'b0;
            
            case(funct3)
                3'b000: alu_op = `EQ;
                3'b001: alu_op = `NEQ;
                3'b100: alu_op = `SLT;
                3'b101: alu_op = `GE;
                3'b110: alu_op = `SLTU;
                3'b111: alu_op = `GEU;
            endcase
            write_enable = 0; 
        end
        
        `R_OP, `I_OP: begin
            imm[31:12] = i_inst[31];
            imm[11:0] = i_inst[31:20];
            case(funct3)
                3'b000: begin
                    if ((funct7 == 7'b0010100) && (opcode != `I_OP)) begin
                        alu_op = `SUB;
                    end else begin
                        alu_op = `ADD;
                    end
                end
                3'b100: alu_op = `XOR;
                3'b110: alu_op = `OR;
                3'b001: alu_op = `SLL;
                3'b101: begin
                    if (funct7 == 7'b0010100) begin //SRA (Shift Right Arithmetic)
                        alu_op = `SRA;
                    end else begin
                        alu_op = `SRL;
                    end
                end
                3'b111: alu_op = `AND;
                3'b010: alu_op = `SLT;
                3'b011: alu_op = `SLTU;
            endcase
        end
    endcase
end

endmodule

