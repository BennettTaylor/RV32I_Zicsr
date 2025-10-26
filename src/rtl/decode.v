`timescale 1ns / 1ps
`include "header.vh"

module decode(
    // Inputs
    input wire i_clk, // System clock
    input wire i_rst_n, // Active low reset
    input wire [`XLEN-1:0] i_inst, // Instruction from instruction memory
    input wire [`XLEN-1:0] i_pc, // Current program counter

    // Output registers
    output reg [`OPLEN:0] or_opcode, // Opcode
    output reg [`XADDR-1:0] or_rd_addr, // Destination register address
    output reg [`XADDR-1:0] or_rs1_addr, // Source register 1 address for forwarding
    output reg [`XADDR-1:0] or_rs2_addr, // Source register 2 address for forwarding
    output reg [`XLEN-1:0] or_imm, // Immediate value
    output reg [6:0] or_funct7, // Funct7
    output reg [2:0] or_funct3, // Funct3
    output reg [`ALUOPS-1:0] or_alu_ops, // The ALU operation specified
    output reg [`XLEN-1:0] or_pc, // Current program counter
    output reg [4:0] or_shamti, // Shamt I-type Instruction 

    //Output wires
    output wire [`XADDR-1:0] ow_rs1_addr, // Source register 1 address for register file
    output wire [`XADDR-1:0] ow_rs2_addr // Source register 2 address for register file
);



/* Assign rs1 and rs2 wires for register file */
assign ow_rs1_addr = i_inst[19:15];
assign ow_rs2_addr = i_inst[24:20];

/* Generate opcode & funct3 wire */
wire [`OPLEN-1:0] opcode = i_inst[`OPLEN-1:0]; 
wire [2:0] funct3 = i_inst[14:12];
wire [6:0] funct7 = i_inst[31:25]; 

/* Registers for storing calculated values */
reg [`XLEN-1:0] imm;
reg [`ALUOPS-1:0] alu_ops;
reg [4:0] shamti; 

/* Assign register outputs */
always @(posedge i_clk) begin
    or_opcode <= opcode;
    or_rd_addr <= i_inst[11:7];
    or_rs1_addr <= ow_rs1_addr;
    or_rs2_addr <= ow_rs2_addr;
    or_imm <= imm;
    or_funct7 <= i_inst[31:25];
    or_funct3 <= funct3;
    or_funct7 <= funct7; 
    or_alu_ops <= alu_ops;
    or_pc <= i_pc;
    or_shamti <=shamti; 
end

/* Calculate needed values */
always @(*) begin
    /* Reset registers */
    alu_ops = 0;
    imm = 0;
        case(or_opcode)
            7'b0110111:begin
            // Case Statement for U-Type
                imm[31:12] <= i_inst[31:12]; 
                imm[11:0] <= 12'b000000000000;
            end 
            7'b1101111:begin
            // Case Statement for J-Type
                imm[31:20] <= i_inst[31];
                imm[19:12] <= i_inst[19:12];
                imm[11] <= i_inst[20];
                imm[10:1] <= i_inst[30:21]; 
                imm[0] <= 1'b0;     
            end
            7'b0000011:begin
            // Case Statement for I-Type
                imm[31:12] <= i_inst[31];
                imm[11:0] <= i_inst[30:10];
                shamti[4:0] <= i_inst[24:20]; 
            end
            7'b0100011:begin
            // Case Statement for S-Type
                imm[31:12] <= i_inst[31];
                imm[11:5] <= i_inst[31:25];
                imm[4:0] <= i_inst[11:7];
            end 
            7'b110011:begin
            // Case Statement for B-Type
                imm[31:12] <= i_inst[31];
                imm[11] <= i_inst[7]; 
                imm[10:5] <= i_inst[30:25]; 
                imm[4:1] <= i_inst[11:8]; 
                imm[0] <= 1'b0;
                
                case(funct3)
                    3'b000:begin // Branch Equal
                    alu_ops = 10;
                end
                    3'b001:begin // Branch Not Equal
                    alu_ops = 11;
                end 
                    3'b100:begin // Branch Less Than
                    alu_ops = 3;
                end 
                    3'b101:begin // Branch Greater Than or Equal
                    alu_ops = 12;
                end 
                    3'b110:begin // Branch Less Than Unsigned
                    alu_ops = 4;
                end
                    3'b111:begin // Branch Greater Than or Equal Unsigned 
                    alu_ops = 13;
                end 
                endcase
            end 
        endcase
        
        if (or_opcode==7'b0110011 || or_opcode == 7'b0010011) begin
            case(funct3)
                3'b000:begin // Add
                if (or_opcode == 7'b0110011 && funct7 == 7'b0010100) begin // Sub
                    alu_ops = 1; // Sub
                end 
                alu_ops = 0; // Add
            end
                3'b100:begin // Xor
                alu_ops = 5;
            end 
                3'b110:begin // Or
                alu_ops = 8;
            end 
                3'b001:begin // SLL (Shift Left Logical)
                alu_ops = 2;
            end 
                3'b101:begin // SRL (Shift Right Logical)
                if (or_opcode == 7'b0110011 && funct7 == 7'b0010100) begin //SRA (Shift Right Arithmetic)
                    alu_ops = 7; 
                end
                alu_ops = 6;
            end
                3'b111:begin // And
                alu_ops = 9;
            end 
                3'b010:begin // SLT (Set Less Than)
                alu_ops = 3;
            end 
                3'b011:begin // SLTU (Set Less Than Unsigned)
                alu_ops = 4;
            end 
            endcase
         end 
end

endmodule;