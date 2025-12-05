`timescale 1ns / 1ps
`include "header.vh"

module data_memory #(
    parameter INIT_FILE = ""
) (
    /* Data memory inputs */
    input wire i_mem_req, // Memory request signal
    input wire [`XLEN-1:0] i_mem_addr, // Memory address requested for read/write
    input wire [`XLEN-1:0] i_mem_data, // Data to be written to memory
    input wire [2:0] i_funct3, // Indicates what kind of memory operation is being performed
    input wire i_read_write, // Indicates read (0) or write (1) operation
    input wire i_rst_n,
    
    /* Data memory outputs */
    output reg or_mem_ack, // Acknoledgement from memory (data is ready for read/written to)
    output reg [`XLEN-1:0] or_mem_data // Data from memory address requested
);

/* Data */
reg [`MEMSIZE-1:0] data [`XLEN-1:0];
integer i;

initial begin 
    for (i = 0; i < 2 ** `MEMSIZE; i = i + 1) begin
        data[i] = 32'b0;
    end
    
    if (INIT_FILE != "") begin
        $readmemh(INIT_FILE, data);
    end
end

/* Handle memory request */
always @(*) begin
    if (!i_rst_n) begin
        or_mem_ack = 0;
        or_mem_data = 32'b0;
    end else if (i_mem_req) begin
        if (i_read_write) begin
            /* Handle read request */
            case (i_funct3)
                /* Load byte */
                3'b000: begin
                    case (i_mem_addr[1:0])
                        2'b00: begin
                            or_mem_data = {24 * data[i_mem_addr[`MEMBITS+1:2]][7], data[i_mem_addr[`MEMBITS+1:2]][7:0]}; 
                        end
                        
                        2'b01: begin
                            or_mem_data = {24 * data[i_mem_addr[`MEMBITS+1:2]][15], data[i_mem_addr[`MEMBITS+1:2]][15:8]};
                        end
                        
                        2'b10: begin
                            or_mem_data = {24 * data[i_mem_addr[`MEMBITS+1:2]][23], data[i_mem_addr[`MEMBITS+1:2]][23:16]};
                        end
                        
                        2'b11: begin
                            or_mem_data = {24 * data[i_mem_addr[`MEMBITS+1:2]][31], data[i_mem_addr[`MEMBITS+1:2]][31:24]};
                        end
                    endcase
                end
                
                /* Load half word */
                3'b001: begin
                    case (i_mem_addr[1])
                        1'b0: begin
                            or_mem_data = {16 * data[i_mem_addr[`MEMBITS+1:2]][15], data[i_mem_addr[`MEMBITS+1:2]][15:0]};
                        end
                        
                        1'b1: begin
                            or_mem_data = {16 * data[i_mem_addr[`MEMBITS+1:2]][31], data[i_mem_addr[`MEMBITS+1:2]][31:16]};
                        end
                    endcase
                end
                
                /* Load word */
                3'b010: begin
                    or_mem_data = data[i_mem_addr[`MEMBITS+1:2]];
                end
                
                /* Load byte unsigned */
                3'b100: begin
                    case (i_mem_addr[1:0])
                        2'b00: begin
                            or_mem_data = {24 * 0, data[i_mem_addr[`MEMBITS+1:2]][7:0]}; 
                        end
                        
                        2'b01: begin
                            or_mem_data = {24 * 0, data[i_mem_addr[`MEMBITS+1:2]][15:8]};
                        end
                        
                        2'b10: begin
                            or_mem_data = {24 * 0, data[i_mem_addr[`MEMBITS+1:2]][23:16]};
                        end
                        
                        2'b11: begin
                            or_mem_data = {24 * 0, data[i_mem_addr[`MEMBITS+1:2]][31:24]};
                        end
                    endcase
                end
                
                /* Load half word unsigned */
                3'b101: begin
                    case (i_mem_addr[1])
                        1'b0: begin
                            or_mem_data = {16 * 0, data[i_mem_addr[`MEMBITS+1:2]][15:0]};
                        end
                        
                        1'b1: begin
                            or_mem_data = {16 * 0, data[i_mem_addr[`MEMBITS+1:2]][31:16]};
                        end
                    endcase
                end
            endcase
        end else begin
            /* Handle write request */
            case (i_funct3)
            /* Store byte */
            3'b000: begin
                case (i_mem_addr[1:0])
                    2'b00: begin
                        data[i_mem_addr[`MEMBITS+1:2]][7:0] = i_mem_data[7:0]; 
                    end
                    
                    2'b01: begin
                        data[i_mem_addr[`MEMBITS+1:2]][15:8] = i_mem_data[7:0];
                    end
                    
                    2'b10: begin
                        data[i_mem_addr[`MEMBITS+1:2]][23:16] = i_mem_data[7:0];
                    end
                    
                    2'b11: begin
                        data[i_mem_addr[`MEMBITS+1:2]][31:24] = i_mem_data[7:0];
                    end
                endcase
            end
            
            /* Store half word */
            3'b001: begin
                case (i_mem_addr[1])
                    1'b0: begin
                        data[i_mem_addr[`MEMBITS+1:2]][15:0] = i_mem_data[15:0];
                    end
                    
                    1'b1: begin
                        data[i_mem_addr[`MEMBITS+1:2]][31:16] = i_mem_data[15:0];
                    end
                endcase                
            end
            
            /* Store word */
            3'b010: begin
                data[i_mem_addr[`MEMBITS+1:2]] = i_mem_data;
            end
        endcase
        end
        or_mem_ack = 1;
    end else begin
        or_mem_ack = 0;
    end
end

endmodule
