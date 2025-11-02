`timescale 1ns / 1ps
`include "header.vh"

module tb_decode;

    // Inputs
    reg i_clk;
    reg i_rst_n;
    reg [`XLEN-1:0] i_inst;
    reg [`XLEN-1:0] i_pc;
    reg [`XADDR-1:0] i_rd_addr;
    reg [`XLEN-1:0] i_rd_data;
    reg i_wr_en;

    // Outputs
    wire [`OPLEN-1:0] or_opcode;
    wire [`XADDR-1:0] or_rd_addr;
    wire [`XADDR-1:0] or_rs1_addr;
    wire [`XADDR-1:0] or_rs2_addr;
    wire [`XLEN-1:0] or_rs1_data;
    wire [`XLEN-1:0] or_rs2_data;
    wire [`XLEN-1:0] or_imm;
    wire [6:0] or_funct7;
    wire [2:0] or_funct3;
    wire [`ALUOPS-1:0] or_alu_op;
    wire [`XLEN-1:0] or_pc;

    // Instantiate DUT
    decode uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_inst(i_inst),
        .i_pc(i_pc),
        .i_rd_addr(i_rd_addr),
        .i_rd_data(i_rd_data),
        .i_wr_en(i_wr_en),
        .or_opcode(or_opcode),
        .or_rd_addr(or_rd_addr),
        .or_rs1_addr(or_rs1_addr),
        .or_rs2_addr(or_rs2_addr),
        .or_rs1_data(or_rs1_data),
        .or_rs2_data(or_rs2_data),
        .or_imm(or_imm),
        .or_funct7(or_funct7),
        .or_funct3(or_funct3),
        .or_alu_op(or_alu_op),
        .or_pc(or_pc)
    );

    // Clock generation (10ns period)
    always #5 i_clk = ~i_clk;

    // Task for field verification
    task check_fields;
        input [6:0] exp_opcode;
        input [4:0] exp_rd;
        input [4:0] exp_rs1;
        input [4:0] exp_rs2;
        input [6:0] exp_funct7;
        input [2:0] exp_funct3;
        input [31:0] exp_pc;
        begin
            if (or_opcode == exp_opcode &&
                or_rd_addr == exp_rd &&
                or_rs1_addr == exp_rs1 &&
                or_rs2_addr == exp_rs2 &&
                or_funct7 == exp_funct7 &&
                or_funct3 == exp_funct3 &&
                or_pc == exp_pc)
                $display("PASS: opcode=%b, rd=%d, rs1=%d, rs2=%d funct3=%b @ time %0t",
                         or_opcode, or_rd_addr, or_rs1_addr, or_rs2_addr, or_funct3, $time);
            else begin
                $display("FAIL @ time %0t", $time);
                $display("Expected: opcode=%b rd=%d rs1=%d rs2=%d funct7=%b funct3=%b pc=%h",
                         exp_opcode, exp_rd, exp_rs1, exp_rs2, exp_funct7, exp_funct3, exp_pc);
                $display("Got:      opcode=%b rd=%d rs1=%d rs2=%d funct7=%b funct3=%b pc=%h",
                         or_opcode, or_rd_addr, or_rs1_addr, or_rs2_addr, or_funct7, or_funct3, or_pc);
            end
        end
    endtask

    // Stimulus
    initial begin
        $display("Starting Decode Testbench...");
        $dumpfile("tb_decode.vcd");
        $dumpvars(0, tb_decode);

        // Initialize
        i_clk = 0;
        i_rst_n = 0;
        i_inst = 0;
        i_pc = 0;
        i_rd_addr = 0;
        i_rd_data = 0;
        i_wr_en = 0;

        // Reset pulse
        #15 i_rst_n = 1;

        // -------------------------
        // Base 5 tests
        // -------------------------
        // 1: R-type ADD
        #10 i_inst = 32'b0000000_00011_00010_000_00001_0110011;
        i_pc = 32'h00000004;
        #10 check_fields(7'b0110011, 5'd1, 5'd2, 5'd3, 7'b0000000, 3'b000, 32'h00000004);

        // 2: I-type ADDI
        #10 i_inst = 32'b000000000110_00001_000_00101_0010011;
        i_pc = 32'h00000008;
        #10 check_fields(7'b0010011, 5'd5, 5'd1, 5'd0, 7'b0000000, 3'b000, 32'h00000008);

        // 3: BEQ
        #10 i_inst = 32'b0000000_00011_00010_000_00100_1100011;
        i_pc = 32'h0000000C;
        #10 check_fields(7'b1100011, 5'd4, 5'd2, 5'd3, 7'b0000000, 3'b000, 32'h0000000C);

        // 4: LW
        #10 i_inst = 32'b000000000000_00001_010_00111_0000011;
        i_pc = 32'h00000010;
        #10 check_fields(7'b0000011, 5'd7, 5'd1, 5'd0, 7'b0000000, 3'b010, 32'h00000010);

        // 5: SW
        #10 i_inst = 32'b0000000_00101_00010_010_01000_0100011;
        i_pc = 32'h00000014;
        #10 check_fields(7'b0100011, 5'd8, 5'd2, 5'd5, 7'b0000000, 3'b010, 32'h00000014);

        // -------------------------
        // Additional 5 funct3 variation tests
        // -------------------------
        // 6: XOR (R-type)
        #10 i_inst = 32'b0000000_00011_00010_100_00001_0110011;
        i_pc = 32'h00000018;
        #10 check_fields(7'b0110011, 5'd1, 5'd2, 5'd3, 7'b0000000, 3'b100, 32'h00000018);

        // 7: OR (R-type)
        #10 i_inst = 32'b0000000_00011_00010_110_00001_0110011;
        i_pc = 32'h0000001C;
        #10 check_fields(7'b0110011, 5'd1, 5'd2, 5'd3, 7'b0000000, 3'b110, 32'h0000001C);

        // 8: AND (R-type)
        #10 i_inst = 32'b0000000_00011_00010_111_00001_0110011;
        i_pc = 32'h00000020;
        #10 check_fields(7'b0110011, 5'd1, 5'd2, 5'd3, 7'b0000000, 3'b111, 32'h00000020);

        // 9: BEQ (funct3=000)
        #10 i_inst = 32'b0000000_00011_00010_000_00100_1100011;
        i_pc = 32'h00000024;
        #10 check_fields(7'b1100011, 5'd4, 5'd2, 5'd3, 7'b0000000, 3'b000, 32'h00000024);

        // 10: BNE (funct3=001)
        #10 i_inst = 32'b0000000_00011_00010_001_00100_1100011;
        i_pc = 32'h00000028;
        #10 check_fields(7'b1100011, 5'd4, 5'd2, 5'd3, 7'b0000000, 3'b001, 32'h00000028);

        // -------------------------
        // Register writeback test
        // -------------------------
        i_wr_en = 1;
        i_rd_addr = 5'd10;
        i_rd_data = 32'hDEADBEEF;
        #10 i_wr_en = 0;

        #20;
        $display("Decode Testbench Finished.");
        $finish;
    end

endmodule
