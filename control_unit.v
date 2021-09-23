/*
CO 224 (computer architecture) Lab 06 Task 01
Design: Control unit module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 31/05/2020
*/

`timescale  1ns/100ps

module control_unit(INSTRUCTION, RESET, PC, BUSYWAIT, WRITEENABLE, ALUSrc, Sign, ALUOp, Jump, Branch, WRITE, READ, WRITESrc );

    //ports declaration
    input [31:0] INSTRUCTION, PC ;
    input RESET, BUSYWAIT ; 
    output [7:0] IMMEDIATE ;
    output [2:0] READREG1, READREG2, WRITEREG ;
    output WRITEENABLE, ALUSrc, Sign, Jump, Branch, WRITE, READ, WRITESrc ;
    output [2:0] ALUOp ;

    reg ALUOp, WRITEENABLE, ALUSrc, Sign, Jump, Branch, WRITE, READ, WRITESrc ;

    //this block stop wrting already loaded value if reset entered and stop taking offseted PC in next cycle
    always @ (RESET)
    begin
        WRITEENABLE = 1'b0 ;
        Jump = 1'b0 ;
        Branch = 1'b0 ; 
        WRITE = 1'b0 ;
        READ = 1'b0 ;
    end

    //This block is used to decode the new instruction
    always @ (INSTRUCTION)
    begin

        //these two commands to solve the problem of not executing two consecetive loading or storing commands   
        WRITE = 1'b0 ;
        READ = 1'b0 ;

        #1
        //Case block - Generate control signals for different OPCODE S
        case(INSTRUCTION[31:24])
        8'b00000000    : 
                    begin             //if OPCODE == 0000 0000 -->  loadi
                        if (PC != -32'd4) begin //if tiny reset pulse occured withing decoding time this ensure writeanable keep 0
                            WRITEENABLE = 1'b1 ; 
                            ALUSrc = 1'b0 ;
                            ALUOp = 3'b000 ;
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b0 ;
                            WRITESrc = 1'b1 ;
                        end
                            
                    end                   
        8'b00000001    : 
                    begin           //if SELECT == 0000 0001 ;  --> mov
                        if (PC != -32'd4) begin //avoid collision when reset and writeanable both active same time
                            WRITEENABLE = 1'b1 ;
                            Sign = 1'b0 ;
                            ALUSrc = 1'b1 ;
                            ALUOp = 3'b000 ;
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b0 ;
                            WRITESrc = 1'b1 ;
                        end                       
                    end           
        8'b00000010    : 
                    begin           //if SELECT == 0000 0010 ; --> add
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b1 ;
                            Sign = 1'b0 ;
                            ALUSrc = 1'b1 ;
                            ALUOp = 3'b001 ; 
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b0 ;
                            WRITESrc = 1'b1 ;
                        end                                             
                    end
        8'b00000011    : 
                    begin           //if SELECT == 0000 0011 ; --> sub
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b1 ;
                            Sign = 1'b1 ;
                            ALUSrc = 1'b1 ;
                            ALUOp = 3'b001 ;
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b0 ;
                            WRITESrc = 1'b1 ;
                        end                        
                    end         
        8'b00000100    : 
                    begin           //if SELECT == 0000 0100 ; --> and
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b1 ;
                            Sign = 1'b0 ;
                            ALUSrc = 1'b1 ;
                            ALUOp = 3'b010 ; 
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b0 ;
                            WRITESrc = 1'b1 ;
                        end
                    end 
        8'b00000101    : 
                    begin           //if SELECT == 0000 0101 ; --> or
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b1 ;
                            Sign = 1'b0 ;
                            ALUSrc = 1'b1 ;
                            ALUOp = 3'b011 ; 
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b0 ;
                            WRITESrc = 1'b1 ;
                        end                       
                    end 
        8'b00000110    : 
                    begin           //if SELECT == 0000 0110 ; --> j
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b0 ;
                            Jump = 1'b1 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b0 ;
                            WRITESrc = 1'b1 ;
                        end                       
                    end 
        8'b00000111    : 
                    begin           //if SELECT == 0000 0111 ; --> beq
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b0 ;
                            Sign = 1'b1 ;
                            ALUSrc = 1'b1 ;
                            ALUOp = 3'b001 ; 
                            Jump = 1'b0 ;
                            Branch = 1'b1 ;
                            WRITE = 1'b0 ;
                            READ = 1'b0 ;
                            WRITESrc = 1'b1 ;
                        end                       
                    end    

        8'b00001000    : 
                    begin           //if SELECT == 0000 1000 ; --> lwd
                        if (PC != -32'd4) begin                            
                            WRITEENABLE = 1'b1 ;
                            Sign = 1'b0 ;
                            ALUSrc = 1'b1 ;
                            ALUOp = 3'b000 ;
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b1 ;
                            WRITESrc = 1'b0 ;
                        end                       
                    end 

        8'b00001001    : 
                    begin           //if SELECT == 0000 1001 ; --> lwi
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b1 ; 
                            ALUSrc = 1'b0 ;
                            ALUOp = 3'b000 ;
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b0 ;
                            READ = 1'b1 ;
                            WRITESrc = 1'b0 ; 
                        end                       
                    end 

        8'b00001010    : 
                    begin           //if SELECT == 0000 1010 ; --> swd
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b0 ;
                            Sign = 1'b0 ;
                            ALUSrc = 1'b1 ;
                            ALUOp = 3'b000 ; 
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b1 ;
                            READ = 1'b0 ;
                        end                       
                    end 

        8'b00001011    : 
                    begin           //if SELECT == 0000 1011 ; --> swi
                        if (PC != -32'd4) begin
                            WRITEENABLE = 1'b0 ;
                            ALUSrc = 1'b0;
                            ALUOp = 3'b000 ; 
                            Jump = 1'b0 ;
                            Branch = 1'b0 ;
                            WRITE = 1'b1 ;
                            READ = 1'b0 ;
                        end                       
                    end 
        endcase
    end
    

endmodule 