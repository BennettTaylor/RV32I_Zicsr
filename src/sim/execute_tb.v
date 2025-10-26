`timescale 1ns / 1ps
`include "header.vh"

module execute_tb;
    /* Execute stage inputs */
    reg i_clk; // CPU clock
    reg i_rst_n; // Active low reset

    /* execute stage outputs */
    
    /* Instantiate the execute stage */
    execute execute_test(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n)
    );
    
    /* Tests */
    initial begin
        /* Initialize inputs */
        i_clk = 0;
        i_rst_n = 0;
        
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