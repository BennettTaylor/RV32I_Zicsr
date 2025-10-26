`timescale 1ns / 1ps
`include "header.vh"

module register_file_tb;
    /* Register file inputs */
    reg i_clk; // CPU clock
    reg i_rst_n; // Active low reset
    
    reg [`XADDR-1:0] i_rs1_addr; // Source register 1 address
    reg [`XADDR-1:0] i_rs2_addr; // Source register 2 address
    reg [`XADDR-1:0] i_rd_addr; // Destination register address for writing
    reg [`XLEN-1:0] i_rd_data; // Destination register data for writing

    /* Register file outputs */
    wire [`XLEN-1:0] o_rs1_data; // Source register 1 data
    wire [`XLEN-1:0] o_rs2_data; // Source register 2 data
    
    /* Instantiate the register file */
    register_file register_file_test(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_rs1_addr(i_rs1_addr),
        .i_rs2_addr(i_rs2_addr),
        .i_rd_addr(i_rd_addr),
        .i_rd_data(i_rd_data),
        .or_rs1_data(o_rs1_data),
        .or_rs2_data(o_rs2_data)
    );
    
    /* Tests */
    initial begin
        /* Initialize inputs */
        i_clk = 0;
        i_rst_n = 0;
        i_rs1_addr = 0;
        i_rs2_addr = 0;
        i_rd_addr = 0;
        i_rd_data = 0;
        
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