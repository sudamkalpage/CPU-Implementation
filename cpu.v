/*
CO 224 (computer architecture) Lab 06 Task 01
Design: CPU module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 31/05/2020
*/

`include "control_unit.v" 
`include "reg_file.v" 
`include "mux_2x1_8bits.v"
`include "mux_2x1_32bits.v"
`include "alu.v"
`include "pc.v"

`timescale  1ns/100ps

//module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);
module cpu (PC, ALURESULT, WRITEDATA, READ, WRITE, INSTRUCTION, CLK, RESET, READDATA, BUSYWAIT);

    //ports declaration
    input [31:0] INSTRUCTION ; 
    input CLK, RESET, BUSYWAIT;
    input [7:0] READDATA ;
    output [31:0] PC ;
    output [7:0] ALURESULT, WRITEDATA ;
    output READ, WRITE ;
    

    wire [31:0] NEXT_PC, NEXT_tmp_PC ;
    reg [31:0] DEF_NEXT_PC, JUMPED_PC ;
    reg [2:0] WRITEREG, READREG1, READREG2 ;
    reg [7:0] IMMEDIATE, WRITEDATA ;
    wire [2:0] ALUOp ;
    wire WRITEENABLE, ALUSrc, Sign, Jump, Branch, ZERO, Branch_ctrl, WRITESrc ; 
    wire [7:0] REGOUT1, REGOUT2, REG_WRITEDATA, tmp_out1, tmp_out2; 
    reg [7:0] NEG_REGOUT2, INPUT_OFFSET ; 
    reg [31:0] REAL_OFFSET ; 
/*

//port descriptions

    DEF_NEXT_PC     - default current PC + 4 value
    JUMPED_PC       - jump/beq offset added PC
    NEXT_tmp_PC     - output of jump mux (DEF_NEXT_PC or JUMPED_PC)    
    NEXT_PC         - value of PC at the next positive edge
    INPUT_OFFSET    - input amount to jump or branch in the destination 8 bits
    REAL_OFFSET     - shifted amount to branch or jump
    Sign            - first mux control signal (2's complement)
    ALUSrc          - second mux control signal (operand of alu)
    Jump            - control signal to use jump or not 
    Branch          - control unit output signal whether to branch or not
    Branch_ctrl     - control signal to mux whether to branch or not
    tmp_out1        - output of mux1 (2's complement)
    tmp_out2        - output of mux2 (operand of alu)
    NEG_REGOUT2     - holds negative value of REGOUT2
    ZERO            - ALU ZERO output signal
    ALURESULT       - result of the alu module
    READDATA        - data read from the data memory 
    REG_WRITEDATA   - data to write in to register file in the next positive clock edge
    READ            - read access signal output from data memory
    WRITE           - write access signal output from data memory
    BUSYWAIT        - stall signal from data memory 
    REGOUT1         - data to store in the memory from register read register 1 
    WRITESrc        - control signal to choose register file write source

 */
    //PC update
    pc mypc(PC,NEXT_PC,RESET,CLK,BUSYWAIT);

    //default PC NEXT value is PC + 4 (if no offset)
    always @ (PC)
    #1
    begin
        if (BUSYWAIT == 1'b0) begin
            DEF_NEXT_PC = PC + 32'd4 ;
        end
    end 

    always @ (INSTRUCTION)
    begin
        //for any opcode we should take IMMEDDIATE, READREG1, READREG2, WRITEREG, INPUT_OFFSET from the same positions of instruction
        IMMEDIATE = INSTRUCTION[7:0] ;
        READREG1 = INSTRUCTION [10:8] ;
        READREG2 = INSTRUCTION [2:0] ;
        WRITEREG = INSTRUCTION [18:16] ;
        INPUT_OFFSET = INSTRUCTION [23:16] ;
    end
        
    //left shift and sign extension to get branch or jump 32 bit amount
    always @ (INPUT_OFFSET, DEF_NEXT_PC) 
    begin
        // sign extension and multiply by 4 (shit left 2)
        REAL_OFFSET = {{22{INPUT_OFFSET[7]}}, INPUT_OFFSET, 2'b00} ;
    end

    //get offsetted PC
    always @ (INPUT_OFFSET, DEF_NEXT_PC) 
    begin
        // add offset to PC + 1
        #2 
        JUMPED_PC = DEF_NEXT_PC + REAL_OFFSET ;     
    end

    //Multiplexer to choose PC next jumped address or not
    mux_2x1_32bits jump_mux(DEF_NEXT_PC, JUMPED_PC, Jump, NEXT_tmp_PC) ;

    // Decoding - Control unit module to generate control signals
    control_unit mycontrol_unit (INSTRUCTION, RESET, PC, BUSYWAIT, WRITEENABLE, ALUSrc, Sign, ALUOp, Jump, Branch, WRITE, READ, WRITESrc );

    // register file module
    reg_file myregfile(REG_WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET, BUSYWAIT);
    always @ (REGOUT1) 
    begin
        WRITEDATA = REGOUT1 ;
    end

    //2's complement - To get negative value of REGOUT2 (for sub command)
    always @ (REGOUT2) 
    #1
    begin
        NEG_REGOUT2 = ~(REGOUT2) + 8'b00000001 ;
    end

    //Multiplexer which choose REGOUT2 or negative value of REGOUT2 (depend on sub or other (add))
    mux_2x1_8bits regout_2(REGOUT2,NEG_REGOUT2,Sign,tmp_out1);

    //Multiplexer to choose alu second operand (immediate value or register file read)
    mux_2x1_8bits operand_2(IMMEDIATE,tmp_out1,ALUSrc,tmp_out2);

    //alu module
    alu  myalu(REGOUT1, tmp_out2, ALURESULT, ALUOp, ZERO); 

    //multiplexer to chhoose write data whether alu result or writedata from data memory 
    mux_2x1_8bits WRITESrc_mux(READDATA, ALURESULT, WRITESrc, REG_WRITEDATA);

    //and to decide whether branch or not
    and and_branch(Branch_ctrl, ZERO, Branch);

    //Multiplexer to choose PC next branch address or not
    mux_2x1_32bits branch_mux(NEXT_tmp_PC, JUMPED_PC, Branch_ctrl, NEXT_PC) ;

    


endmodule

