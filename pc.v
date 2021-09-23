/*
CO 224 (computer architecture) Lab 06 Task 01
Design: PC module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 31/05/2020
*/

`timescale  1ns/100ps

module pc(PC,NEXT_PC,RESET,CLK,BUSYWAIT);

    //ports declaration
    input RESET,CLK, BUSYWAIT ;
    input [31:0] NEXT_PC ;
    output [31:0] PC ;

    reg PC;

    //PC update at postive clock edge
    always @ (posedge CLK)
    begin
        #1
        if ((RESET == 1'b0) && (BUSYWAIT == 1'b0)) begin
            PC = NEXT_PC ;
        end
    end

    //chencge PC when resetting
    always @ (RESET)
    begin
        if (RESET == 1'b1) 
        #1
        begin
            PC = -32'd4 ;
        end
    end

endmodule
