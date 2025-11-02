`timescale 1ns / 1ps
`include "/home/dpapp/Risc-V/SSH_RV32I/RV32I_Zicsr/src/include/header.vh"

module alu_tb;

// Clock and reset
reg i_clk;
reg i_rst_n;

// ALU inputs
reg [`ALUOPS-1:0] i_alu_op;
reg signed [`XLEN-1:0] i_data_1;
reg signed [`XLEN-1:0] i_data_2;
reg [4:0] shamt;

// ALU output
wire [`XLEN-1:0] ow_result;

// Instantiate DUT
alu uut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_alu_op(i_alu_op),
    .i_data_1(i_data_1),
    .i_data_2(i_data_2),
    .shamt(shamt),
    .ow_result(ow_result)
);

// Clock generation: 10 ns period
always #5 i_clk = ~i_clk;

// Test procedure
initial begin
    // Initialize signals
    i_clk = 0;
    i_rst_n = 0;
    i_alu_op = 0;
    i_data_1 = 0;
    i_data_2 = 0;
    shamt = 0;

    // Apply reset
    #10 i_rst_n = 1;

    // Start ALU tests
    $display("Starting ALU tests...");

    // ADD
    i_alu_op = `ADD;
    i_data_1 = 32'd10;
    i_data_2 = 32'd5;
    #10 $display("ADD: %0d + %0d = %0d", i_data_1, i_data_2, ow_result);

    // SUB
    i_alu_op = `SUB;
    i_data_1 = 32'd15;
    i_data_2 = 32'd20;
    #10 $display("SUB: %0d - %0d = %0d", i_data_1, i_data_2, ow_result);

    // AND
    i_alu_op = `AND;
    i_data_1 = 32'hF0F0F0F0;
    i_data_2 = 32'h0FF00FF0;
    #10 $display("AND: %h & %h = %h", i_data_1, i_data_2, ow_result);

    // OR
    i_alu_op = `OR;
    i_data_1 = 32'hF0F0F0F0;
    i_data_2 = 32'h0FF00FF0;
    #10 $display("OR: %h | %h = %h", i_data_1, i_data_2, ow_result);

    // XOR
    i_alu_op = `XOR;
    i_data_1 = 32'hAAAAAAAA;
    i_data_2 = 32'h55555555;
    #10 $display("XOR: %h ^ %h = %h", i_data_1, i_data_2, ow_result);

    // SLL
    i_alu_op = `SLL;
    i_data_1 = 32'd1;
    i_data_2 = 32'd3; // shift by 3
    #10 $display("SLL: %d << %d = %d", i_data_1, i_data_2[4:0], ow_result);

    // SRL
    i_alu_op = `SRL;
    i_data_1 = 32'd128;
    i_data_2 = 32'd2;
    #10 $display("SRL: %d >> %d = %d", i_data_1, i_data_2[4:0], ow_result);

    // SRA
    i_alu_op = `SRA;
    i_data_1 = -32'd64;
    i_data_2 = 32'd2;
    #10 $display("SRA: %d >>> %d = %d", i_data_1, i_data_2[4:0], ow_result);

    // SLT
    i_alu_op = `SLT;
    i_data_1 = 32'd5;
    i_data_2 = 32'd10;
    #10 $display("SLT: %d < %d = %d", i_data_1, i_data_2, ow_result);

    // GE
    i_alu_op = `GE;
    i_data_1 = 32'd10;
    i_data_2 = 32'd5;
    #10 $display("GE: %d >= %d = %d", i_data_1, i_data_2, ow_result);

    // EQ
    i_alu_op = `EQ;
    i_data_1 = 32'd100;
    i_data_2 = 32'd100;
    #10 $display("EQ: %d == %d = %d", i_data_1, i_data_2, ow_result);

    // NEQ
    i_alu_op = `NEQ;
    i_data_1 = 32'd10;
    i_data_2 = 32'd20;
    #10 $display("NEQ: %d != %d = %d", i_data_1, i_data_2, ow_result);

    $display("ALU test complete.");
    #20 $finish;
end

endmodule



