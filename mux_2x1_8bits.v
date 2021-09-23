/*
CO 224 (computer architecture) Lab 06 Task 01
Design: 8bit 2:1 mux module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 31/05/2020
*/

`timescale  1ns/100ps

module mux_2x1_8bits(in0,in1,sel,out);

    //ports declaration
    input sel ;
    input [7:0] in0, in1 ;
    output [7:0] out ;

    reg out;

    always @ (in0, in1, sel)
    begin
        if (sel == 1'b0) begin
            out = in0;
        end else begin
            out = in1;
        end
    end

endmodule
