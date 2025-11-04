# RV32I_Zicsr
An open-source RISC-V base 32 integer core capable of running FreeRTOS, written in Verilog.

## The Specification
This processor is follows the RV32I_Zicsr specification, which means that it implements the 32 bit base integer RISC-V ISA with the Zicsr extension. The Zicsr extension is necessary for actually implementing the CPU in hardware, as it adds the features needed for atomic operations on 4096 control and status registers. This is required to interface with hardware and store important information like trap handler addresses. This allows our processor to interface with I/O, interupts, run operating systems, etc. In total there are 45 instructions implemented:

| I-Type  | R-Type  | S-Type  | B-Type  | J-Type  | U-Type  | Load  |  System |
|---|---|---|---|---|---|---|---|
| addi  | add  | sb  | beq  | jal  | lui  | lb  | ecall  |
| slti  | sub  | sh  | bne  | jalr  | auipc  | lh  | ebreak  |
| sltiu  | sll  | sw  | blt  |   |   | lw  | csrrw  |
| xori  | slt  |   | bgt  |   |   | lbu  | csrrs  |
| ori  | sltu  |   | bltu  |   |   | lhu  | csrrc  |
| andi  | xor  |   | bgeu  |   |   |   | csrrwi  |
| slli  | srl  |   |   |   |   |   | csrrsi  |
| srli  | sra  |   |   |   |   |   | csrrci  |
| srai  | or  |   |   |   |   |   |   |
|   | and  |   |   |   |   |   |   |

This set of instructions is the smallest set capable of working as a general processor, many common assembly instructions are missing like multiplication, division, and floating point operations. Despite this, all other missing operations can be accomplished by this limited set (although slowly). Multiplication for example can be accomplished through repeated addition.

## Development
We are targeting the Xilinx Artix A7 FPGA development board for our implementation, so we have chosen to do development using Xilinx Vivado. To integrate with git control we use a TCL script & make to recreate the project from the source files found in this repository. To create the project run:  
`make create`  
You can also clean up the project before recreating by running:  
`make clean`  
Additionally for setting up vivado for the lab machines, use:  
`source /ad/eng/opt/Xilinx/Vivado/2020.2/settings64.sh`  

## Architecture
Our project utilizes a classic 5 stage pipeline.
