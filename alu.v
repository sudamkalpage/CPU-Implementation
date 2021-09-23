/*
CO 224 (computer architecture) Lab 06 Task 02 (updated)
Design: Alu module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 31/05/2020
*/

`include "mux_4x1_8bits_opselect.v" 

`timescale  1ns/100ps

module alu (DATA1, DATA2, RESULT, SELECT, ZERO); 

    /*Ports declaration*/ 
    input [7:0] DATA1, DATA2;       // DATA1 = OPERAND1 , DATA2 = OPERAND2 (8 bit inputs)
    input [2:0] SELECT;             //SELECT = ALUOP (8 bit input)
    output [7:0] RESULT;            //RESULT = ALURESULT (8 bit output)
    output ZERO ;                   //ZERO flag to indictae alu result 0 or not
    
    wire [7:0] FORWARD_RESULT, ADD_RESULT, AND_RESULT, OR_RESULT;       //temporary wires to assign results of each operation

    //assigning results of each operation
    assign #1 FORWARD_RESULT = DATA2 ; 
    assign #2 ADD_RESULT = DATA1 + DATA2 ;  
    assign #1 AND_RESULT = DATA1 & DATA2 ;  
    assign #1 OR_RESULT = DATA1 | DATA2 ;

    //choose the correct result from temporary results using a multiplexer
    mux_4x1_8bits_opselect operation_selector(FORWARD_RESULT,ADD_RESULT,AND_RESULT,OR_RESULT,SELECT,RESULT);


    //multiple bit input nor gate to update ZERO from alu output (depend on alu result 0 or not)
    nor nor1(ZERO, RESULT[0], RESULT[1], RESULT[2], RESULT[3], RESULT[4], RESULT[5], RESULT[6], RESULT[7]) ;



endmodule