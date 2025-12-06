`timescale 1ns / 1ps
`include "header.vh"

module cpu_tb;
    /* CPU inputs */
    reg i_clk; // CPU clock
    reg i_rst_n;// Active low reset
    
    wire i_inst_ack; 
    wire [`XLEN-1:0] i_inst_received; 
    wire i_data_ack;
    wire [`XLEN-1:0] i_data_received;
    
    /* CPU outputs */
    wire o_inst_req;
    wire [`XLEN-1:0] o_inst_addr;
    wire o_data_req;
    wire [`XLEN-1:0] o_data_addr;
    wire [`XLEN-1:0] o_data; // Data to be written
    wire [2:0] o_funct3;
    wire o_readwrite_signal;
    
    /* Instantiate the CPU */
    cpu cpu_test(
    .i_clk(i_clk), // CPU clock
    .i_rst_n(i_rst_n),// Active low reset
    
    .i_inst_ack(i_inst_ack), 
    .i_inst_received(i_inst_received), 
    .i_data_ack(i_data_ack),
    .i_data_received(i_data_received),
    
    .o_inst_req(o_inst_req),
    .o_inst_addr(o_inst_addr),
    .o_data_req(o_data_req),
    .o_data_addr(o_data_addr),
    .o_data(o_data),
    .o_funct3(o_funct3),
    .o_readwrite_signal(o_readwrite_signal)
    );
    
    program_memory #("jump_test1.mem") program_memory_test(
        .i_rst_n(i_rst_n),
        .i_pc(o_inst_addr), // Instruction address
        .i_instruction_request(o_inst_req), // Instruction request signal
        
        .or_instruction(i_inst_received), // Instruction data
        .or_ack(i_inst_ack) // Acknoledgement signal
    );
    
    data_memory #("zero.mem") data_memory_test(
        /* Data memory inputs */
        .i_rst_n(i_rst_n),
        .i_mem_req(o_data_req), // Memory request signal
        .i_mem_addr(o_data_addr), // Memory address requested for read/write
        .i_mem_data(o_data), // Data to be written to memory
        .i_funct3(o_funct3), // Indicates what kind of memory operation is being performed
        .i_read_write(o_readwrite_signal), // Indicates read (0) or write (1) operation
        
        /* Data memory outputs */
        .or_mem_ack(i_data_ack), // Acknoledgement from memory (data is ready for read/written to)
        .or_mem_data(i_data_received) // Data from memory address requested
    );
    
    /* Tests */
    initial begin
        /* Initialize inputs */
        i_clk = 0;
        i_rst_n = 0;
        
        /* Start reset signal */
        #10;
        i_rst_n = 1;
        
        /* Stop reset signal */
        //#10
        //i_rst_n = 0;
        
        /* Begin tests */
    end
    
    /* Drive clock */
    always begin
        #5;
        i_clk = ~i_clk;
    end

endmodule