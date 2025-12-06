`timescale 1ns / 100ps
`include "header.vh"

module register_file(
    /* register file inputs */
    input wire i_clk, // CPU clock
    input wire i_rst_n, // Active low reset
    input wire i_wr_en, // Write enable
    input wire [`XADDR-1:0] i_rs1_addr, // Source register 1 address
    input wire [`XADDR-1:0] i_rs2_addr, // Source register 2 address
    input wire [`XADDR-1:0] i_rd_addr, // Destination register address for writing
    input wire [`XLEN-1:0] i_rd_data, // Destination register data for writing

    /* Register file output registers */
    output reg [`XLEN-1:0] or_rs1_data, // Source register 1 data
    output reg [`XLEN-1:0] or_rs2_data // Source register 2 data
);

integer i;

/*Registers */
reg [`REGISTERS-1:0] registers [`XLEN-1:0];

/* Asynchronous read */
always @(*) begin
     /* Read rs1, checking if rs1 is x0 or begin written to */
        if (i_rs1_addr == 0) begin
            or_rs1_data <= 0;
        end else if (i_rs1_addr == i_rd_addr) begin
            or_rs1_data <= i_rd_data;
        end else begin
            or_rs1_data <= registers[i_rs1_addr];
        end
        
        /* Read rs2, checking if rs2 is x0 or begin written to */
        if (i_rs2_addr == 0) begin
            or_rs2_data <= 0;
        end else if (i_rs2_addr == i_rd_addr) begin
            or_rs2_data <= i_rd_data;
        end else begin
            or_rs2_data <= registers[i_rs2_addr];
        end
end

/* Synchronous write */
always @(posedge i_clk) begin
    /* Perform reset */
    if (!i_rst_n) begin
        for (i = 0; i < `REGISTERS; i = i + 1)
            registers[i] <= 0;
    end else begin
        /* Write to register file if write is enabled and not writing to x0 (always 0) */
        if (i_wr_en && (i_rd_addr != 0)) begin
            registers[i_rd_addr] = i_rd_data;
        end
    end    
end

endmodule