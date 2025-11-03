`timescale 1ns / 1ps
`include "header.vh"

module execute_tb;

    // -------------------------
    // Inputs
    // -------------------------
    reg i_clk;
    reg i_rst_n;
    reg [`OPLEN:0] i_opcode;
    reg [`XADDR-1:0] i_rd_addr;
    reg [`XLEN-1:0] i_rd_mem;
    reg [`XADDR-1:0] i_rd_addr_mem;
    reg i_rd_mem_wr_en;
    reg [`XLEN-1:0] i_rd_wb;
    reg [`XADDR-1:0] i_rd_addr_wb;
    reg i_rd_wb_wr_en;
    reg [`XADDR-1:0] i_rs1_addr;
    reg [`XADDR-1:0] i_rs2_addr;
    reg [`XLEN-1:0] i_rs1_data;
    reg [`XLEN-1:0] i_rs2_data;
    reg [`XLEN-1:0] i_imm;
    reg [6:0] i_funct7;
    reg [2:0] i_funct3;
    reg [`ALUOPS-1:0] i_alu_op;
    reg [`XLEN-1:0] i_pc;

    // -------------------------
    // Outputs
    // -------------------------
    wire [`OPLEN:0] or_opcode;
    wire [`XADDR-1:0] or_rd_addr;
    wire [`XLEN-1:0] or_alu_result;
    wire [`XLEN-1:0] or_pc;
    wire [`XLEN-1:0] or_pc_next;

    // -------------------------
    // DUT Instantiation
    // -------------------------
    execute uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_opcode(i_opcode),
        .i_rd_addr(i_rd_addr),
        .i_rd_mem(i_rd_mem),
        .i_rd_addr_mem(i_rd_addr_mem),
        .i_rd_mem_wr_en(i_rd_mem_wr_en),
        .i_rd_wb(i_rd_wb),
        .i_rd_addr_wb(i_rd_addr_wb),
        .i_rd_wb_wr_en(i_rd_wb_wr_en),
        .i_rs1_addr(i_rs1_addr),
        .i_rs2_addr(i_rs2_addr),
        .i_rs1_data(i_rs1_data),
        .i_rs2_data(i_rs2_data),
        .i_imm(i_imm),
        .i_funct7(i_funct7),
        .i_funct3(i_funct3),
        .i_alu_op(i_alu_op),
        .i_pc(i_pc),
        .or_opcode(or_opcode),
        .or_rd_addr(or_rd_addr),
        .or_alu_result(or_alu_result),
        .or_pc(or_pc),
        .or_pc_next(or_pc_next)
    );

    // -------------------------
    // Clock Generation (10ns)
    // -------------------------
    always #5 i_clk = ~i_clk;

    // -------------------------
    // Task for checking ALU result
    // -------------------------
    task check_result;
        input [31:0] exp_result;
        input [31:0] exp_pc_next;
        begin
            if (or_alu_result === exp_result && or_pc_next === exp_pc_next)
                $display("PASS: alu_result=%h pc_next=%h @ time %0t", or_alu_result, or_pc_next, $time);
            else begin
                $display("FAIL @ time %0t", $time);
                $display("Expected: alu_result=%h pc_next=%h", exp_result, exp_pc_next);
                $display("Got:      alu_result=%h pc_next=%h", or_alu_result, or_pc_next);
            end
        end
    endtask

    // -------------------------
    // Stimulus
    // -------------------------
    initial begin
        $display("Starting Execute Testbench...");
        $dumpfile("tb_execute.vcd");
        $dumpvars(0, tb_execute);

        // Init
        i_clk = 0;
        i_rst_n = 0;
        i_opcode = 0;
        i_rd_addr = 0;
        i_rd_mem = 0;
        i_rd_addr_mem = 0;
        i_rd_mem_wr_en = 0;
        i_rd_wb = 0;
        i_rd_addr_wb = 0;
        i_rd_wb_wr_en = 0;
        i_rs1_addr = 0;
        i_rs2_addr = 0;
        i_rs1_data = 0;
        i_rs2_data = 0;
        i_imm = 0;
        i_funct7 = 0;
        i_funct3 = 0;
        i_alu_op = 0;
        i_pc = 0;

        // Reset
        #12 i_rst_n = 1;

        // ----------------------------------------
        // 1. R-type ADD test
        // ----------------------------------------
        i_opcode = `R_OP;
        i_alu_op = `ALU_ADD;
        i_rs1_data = 32'd10;
        i_rs2_data = 32'd15;
        i_pc = 32'h00000000;
        i_rd_addr = 5'd1;
        #10;
        check_result(32'd25, 32'h00000004);

        // ----------------------------------------
        // 2. I-type ADDI test
        // ----------------------------------------
        i_opcode = `I_OP;
        i_alu_op = `ALU_ADD;
        i_rs1_data = 32'd5;
        i_imm = 32'd7;
        i_pc = 32'h00000004;
        i_rd_addr = 5'd2;
        #10;
        check_result(32'd12, 32'h00000008);

        // ----------------------------------------
        // 3. LUI test
        // ----------------------------------------
        i_opcode = `LUI_OP;
        i_alu_op = `ALU_PASS;
        i_imm = 32'hABCD0000;
        i_pc = 32'h00000008;
        #10;
        check_result(32'hABCD0000, 32'h0000000C);

        // ----------------------------------------
        // 4. Branch (BEQ) test with taken branch
        // ----------------------------------------
        i_opcode = `B_OP;
        i_alu_op = `ALU_EQ;
        i_rs1_data = 32'd4;
        i_rs2_data = 32'd4;
        i_imm = 32'd8; // branch offset
        i_pc = 32'h0000000C;
        #10;
        check_result(32'd1, 32'h00000014);

        // ----------------------------------------
        // 5. JAL test
        // ----------------------------------------
        i_opcode = `JAL_OP;
        i_alu_op = `ALU_ADD;
        i_imm = 32'd100;
        i_pc = 32'h00000020;
        #10;
        check_result(32'd100, 32'h00000084);

        // ----------------------------------------
        // 6. AUIPC test
        // ----------------------------------------
        i_opcode = `AUIPC_OP;
        i_alu_op = `ALU_ADD;
        i_imm = 32'd40;
        i_pc = 32'h00000040;
        #10;
        check_result(32'd40, 32'h0000006C);

        // ----------------------------------------
        // 7. Forwarding test (from MEM stage)
        // ----------------------------------------
        i_opcode = `R_OP;
        i_alu_op = `ALU_ADD;
        i_rs1_addr = 5'd1;
        i_rs2_addr = 5'd2;
        i_rd_addr_mem = 5'd1;
        i_rd_mem = 32'd50;
        i_rd_mem_wr_en = 1;
        i_rs1_data = 32'd0; // should be overridden by forward
        i_rs2_data = 32'd5;
        i_pc = 32'h00000080;
        #10;
        check_result(32'd55, 32'h00000084);

        #20;
        $display("Execute Testbench Finished.");
        $finish;
    end
endmodule
