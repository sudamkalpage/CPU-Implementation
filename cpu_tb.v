/*
CO 224 (computer architecture) Lab 06 Task 03
Design: CPU testbench
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 31/05/2020
*/

`include "cpu.v" 
`include "data_memory.v" 
`include "dcache.v" 
`include "instruction_memory.v" 
`include "icache.v" 

//adjust time scale and precision
`timescale  1ns/100ps

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION; 
    wire [7:0] ALURESULT, READDATA, WRITEDATA;
    wire BUSYWAIT, READ, WRITE;
    wire [31:0] MEM_READDATA, MEM_WRITEDATA;
    wire [5:0] MEM_ADDRESS;
    wire CPU_BUSYWAIT, CPU_READ,CPU_WRITE, i_mem_read;
    wire d_buywait, i_busywait, i_mem_busywait;
    wire [5:0] i_mem_address;
    wire [127:0] i_mem_readdata;

    
    // Initialize an array of registers (8x1024) to be used as instruction memory
    reg [7:0] instr_mem [1023:0] ;

    //instruction cache module
    icache my_icache(CLK,RESET,PC[9:0],INSTRUCTION,i_busywait,
                    i_mem_read,i_mem_address,i_mem_readdata,i_mem_busywait);

    //instruction memory
    instruction_memory my_instruction_memory(CLK,i_mem_read,i_mem_address,i_mem_readdata,i_mem_busywait);

    //or gate to decide final busywait from data cache busywait and instruction cache busy wait to stall the cpu
    or busywait_or(BUSYWAIT, d_buywait, i_busywait) ;

    //cpu module
    cpu mycpu(PC, ALURESULT, WRITEDATA, READ, WRITE, INSTRUCTION, CLK, RESET, READDATA, BUSYWAIT);

    //cache module
    dcache my_data_cache(CLK, RESET, READ, WRITE, ALURESULT, WRITEDATA, READDATA, d_buywait,
                    MEM_READ, MEM_WRITE, MEM_ADDRESS, MEM_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT);

    //memory module
    data_memory mydata_memory(CLK, RESET, MEM_READ, MEM_WRITE, MEM_ADDRESS, MEM_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT);
    //module data_memory(clock,reset,read,write,address,writedata,readdata,busywait);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        //check values inside the registers
        $monitor($time, " reg0: %b, reg1: %b, reg2: %b, reg3: %b, reg4: %b, reg5: %b, reg6: %b, reg7: %b",mycpu.myregfile.R[0],mycpu.myregfile.R[1],mycpu.myregfile.R[2],mycpu.myregfile.R[3],mycpu.myregfile.R[4],mycpu.myregfile.R[5],mycpu.myregfile.R[6],mycpu.myregfile.R[7]);
               
        CLK = 1'b1;
        RESET = 1'b0 ;
        #1
        // reset pulse at the begining
        RESET = 1'b1;
        #15
        RESET = 1'b0 ;
        
        
        #1000
        //reset during cache operation
        RESET = 1'b1;
        #10
        RESET = 1'b0 ;

        // finish simulation after some time
        #14000
        $finish;
        
    end
   
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule