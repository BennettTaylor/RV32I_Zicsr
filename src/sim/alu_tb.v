`timescale 1ns / 1ps
`include "header.vh"

module alu_tb;
    /* ALU inputs */
    reg i_clk; // CPU clock
    reg i_rst_n; // Active low reset
    reg [`ALUOPS-1:0] i_alu_op; // ALU operation to perform
    reg [`XLEN-1:0] i_data_1; // First input data to operate upon (usually rs1)
    reg [`XLEN-1:0] i_data_2; // Second input data to operate upon (usually rs2 or immediate)

    /* ALU outputs */
    wire [`XLEN-1:0] o_result; // ALU result
    
    /* Instantiate the ALU */
    alu alu_test(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_alu_op(i_alu_op),
        .i_data_1(i_data_1),
        .i_data_2(i_data_2),
        .ow_result(o_result)
    );
    
    /* Tests */
    initial begin
        /* Initialize inputs */
        i_clk = 0;
        i_rst_n = 0;
        i_alu_op = 0;
        i_data_1 = 0;
        i_data_2 = 0;
        
        /* Stop reset signal */
        #10;
        i_rst_n = 1;
        
        /* Begin tests */
        #10;
        
    end
    
    /* Drive clock */
    always begin
        #5;
        i_clk = ~i_clk;
    end

endmodule