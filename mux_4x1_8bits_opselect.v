/*
CO 224 (computer architecture) Lab 06 Task 02
Design: 8bit 4:1 mux module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 11/06/2020
*/

//special not: In this mux I have not entered a time delay 

`timescale  1ns/100ps

module mux_4x1_8bits_opselect(in0,in1,in2,in3,sel,out);

    //ports declaration
    input [2:0] sel ;
    input [7:0] in0, in1, in2, in3 ;
    output [7:0] out ;

    reg out;

    always @ (in0, in1, in2, in3,sel)
    begin
        case(sel)
            3'b000 :
            begin
                out = in0;
            end
         
            3'b001: 
            begin
                out = in1;
            end

            3'b010: 
            begin
                out = in2;
            end

            3'b011: 
            begin
                out = in3;
            end
            
        endcase


    end

endmodule
