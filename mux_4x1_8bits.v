/*
CO 224 (computer architecture) Lab 06 Task 02
Design: 8bit 4:1 mux module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 11/06/2020
*/

//special not: In this mux I have entered a time delay of one time unit

`timescale  1ns/100ps

module mux_4x1_8bits(in0,in1,in2,in3,sel,out);

    //ports declaration
    input [1:0] sel ;
    input [7:0] in0, in1, in2, in3 ;
    output [7:0] out ;

    reg out;

    always @ (in0, in1, in2, in3,sel)
    begin
        #1
        case(sel)
            2'b00 :
            begin
                out = in0;
            end
         
            2'b01: 
            begin
                out = in1;
            end

            2'b10: 
            begin
                out = in2;
            end

            2'b11: 
            begin
                out = in3;
            end
            
        endcase


    end

endmodule
