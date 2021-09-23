 /*
CO 224 (computer architecture) Lab 06 Task 01
Design: Register file module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 31/05/2020
*/

`timescale  1ns/100ps

module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET, BUSYWAIT);

    //ports declaration
    input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS ; 
    input [7:0] IN ; 
    input WRITE, CLK, RESET, BUSYWAIT;
    output [7:0] OUT1, OUT2;
    integer i;
    reg [7:0] R [7:0];

    //This block is used to write operation (synchronous)
    always @ (posedge CLK)
    begin
        #1
        if ((WRITE == 1'b1) && (RESET==0) && (BUSYWAIT == 1'b0)) begin //when reset ==1 or busywait ==1 writing should not happen
            R[INADDRESS] = IN;
        end
    end

    //This block is used to read operation (asynchronous)
    assign #2 OUT1 = R[OUT1ADDRESS];
    assign #2 OUT2 = R[OUT2ADDRESS];  

    //This block is used to reset operation (asynchronous)
    always @ (*)                // because reset is level triggered
    begin
        if (RESET == 1'b1)      //when reset is high
        begin    
            #2                  //artificial time delay when resetting
            for (i = 0; i < 8; i = i + 1) begin     //change all register values to zero 
                R[i] = 8'b00000000;
            end
        end
        
    end

endmodule