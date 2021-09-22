/*
Program	: 256x8-bit data memory (16-Byte blocks)
Author	: Isuru Nawinne
Date	: 10/06/2020

Description	:

This program presents a primitive instruction memory module for CO224 Lab 6 - Part 3
This memory allows instructions to be read as 16-Byte blocks
*/

`timescale  1ns/100ps

module instruction_memory(
    clock,
    read,
    address,
    readdata,
    busywait
);
input               clock;
input               read;
input[5:0]          address;
output reg [127:0]  readdata;
output reg          busywait;

reg readaccess;

//Declare memory array 1024x8-bits 
reg [7:0] memory_array [1023:0];

//Initialize instruction memory
initial
begin
    busywait = 0;
    readaccess = 0;


    // Initialize instruction memory with a set of instructions

    //loadi 1 0x00      //PC = 0
    {memory_array[10'd3], memory_array[10'd2], memory_array[10'd1], memory_array[10'd0]} = 32'b00000000000000010000000000000000;
    //loadi 2 0x04
    {memory_array[10'd7], memory_array[10'd6], memory_array[10'd5], memory_array[10'd4]} = 32'b00000000000000100000000000000100;
    //loadi 3 0x03     
    {memory_array[10'd11], memory_array[10'd10], memory_array[10'd9], memory_array[10'd8]} = 32'b00000000000000110000000000000011;
    //loadi 4 0x05    
    {memory_array[10'd15], memory_array[10'd14], memory_array[10'd13], memory_array[10'd12]} = 32'b00000000000001000000000000000101;
    
    //swd 3 1           //write miss  //PC=16
    {memory_array[10'd19], memory_array[10'd18], memory_array[10'd17], memory_array[10'd16]} = 32'b00001010000000000000001100000001;
    //lwd 5 1           //read hit
    {memory_array[10'd23], memory_array[10'd22], memory_array[10'd21], memory_array[10'd20]} = 32'b00001000000001010000000000000001;
    //mov 6 5     
    {memory_array[10'd27], memory_array[10'd26], memory_array[10'd25], memory_array[10'd24]} = 32'b00000001000001100000000000000101;
    //swi 4 0x04        //check store word immdeiate
    {memory_array[10'd31], memory_array[10'd30], memory_array[10'd29], memory_array[10'd28]} = 32'b00001011000000000000010000000100;

    //lwi 5 0x04        //check load word immediate
    {memory_array[10'd35], memory_array[10'd34], memory_array[10'd33], memory_array[10'd32]} = 32'b00001001000001010000000000000100;
    //mov 6 5
    {memory_array[10'd39], memory_array[10'd38], memory_array[10'd37], memory_array[10'd36]} = 32'b00000001000001100000000000000101;
    //swd 3 2           //write hit - overwriting
    {memory_array[10'd43], memory_array[10'd42], memory_array[10'd41], memory_array[10'd40]} = 32'b00001010000000000000001100000010;
    //lwi 5 0x04
    {memory_array[10'd47], memory_array[10'd46], memory_array[10'd45], memory_array[10'd44]} = 32'b00001001000001010000000000000100;

    //mov 6 5
    {memory_array[10'd51], memory_array[10'd50], memory_array[10'd49], memory_array[10'd48]} = 32'b00000001000001100000000000000101;
    //lwi 5 0x09        //read miss - load empty memory ,and check afer reset data memory also resetted 
    {memory_array[10'd55], memory_array[10'd54], memory_array[10'd53], memory_array[10'd52]} = 32'b00001001000001010000000000001111;
    //mov 6 5    
    {memory_array[10'd59], memory_array[10'd58], memory_array[10'd57], memory_array[10'd56]} = 32'b00000001000001100000000000000101;
    //swi 4 0x20        //chech write back        
    {memory_array[10'd63], memory_array[10'd62], memory_array[10'd61], memory_array[10'd60]} = 32'b00001011000000000000010000100000;

    //lwi 5 0x03        //check updated memory
    {memory_array[10'd67], memory_array[10'd66], memory_array[10'd65], memory_array[10'd64]} = 32'b00001001000001010000000000000011;
    //mov 6 5
    {memory_array[10'd71], memory_array[10'd70], memory_array[10'd69], memory_array[10'd68]} = 32'b00000001000001100000000000000101;
    //lwd 5 1           //check when reset during memory load operation
    {memory_array[10'd75], memory_array[10'd74], memory_array[10'd73], memory_array[10'd72]} = 32'b00001000000001010000000000000001;
    //swd 4 2
    {memory_array[10'd79], memory_array[10'd78], memory_array[10'd77], memory_array[10'd76]} = 32'b00001010000000000000010000000010;

    //swi 4 0x03           //store instruction twice consecutive times
    {memory_array[10'd83], memory_array[10'd82], memory_array[10'd81], memory_array[10'd80]} = 32'b00001011000000000000010000000011;
    //add 7 2 3         
    {memory_array[10'd87], memory_array[10'd86], memory_array[10'd85], memory_array[10'd84]} = 32'b00000010000001110000001000000011;
    //lwi 5 0x04           
    {memory_array[10'd91], memory_array[10'd90], memory_array[10'd89], memory_array[10'd88]} = 32'b00001001000001010000000000000100;
    //lwd 5 1           //load instruction twice consecutively
    {memory_array[10'd95], memory_array[10'd94], memory_array[10'd93], memory_array[10'd92]} = 32'b00001000000001010000000000000001;
    
    //loadi 1 0x01
    {memory_array[10'd99], memory_array[10'd98], memory_array[10'd97], memory_array[10'd96]} = 32'b00000000000000010000000000000001;
    //loadi 3 0x02
    {memory_array[10'd103], memory_array[10'd102], memory_array[10'd101], memory_array[10'd100]} = 32'b00000000000000110000000000000010;
    //mov 2 1
    {memory_array[10'd107], memory_array[10'd106], memory_array[10'd105], memory_array[10'd104]} = 32'b00000001000000100000000000000001;
    //beq 0x02 1 2   //check beq //PC =  108
    {memory_array[10'd111], memory_array[10'd110], memory_array[10'd109], memory_array[10'd108]} = 32'b00000111000000100000000100000010;

    //mov 4 5
    {memory_array[10'd115], memory_array[10'd114], memory_array[10'd113], memory_array[10'd112]} = 32'b00000001000001000000000000000101;
    //mov 2 3
    {memory_array[10'd119], memory_array[10'd118], memory_array[10'd117], memory_array[10'd116]} = 32'b00000001000000100000000000000011;
    //mov 2 1
    {memory_array[10'd123], memory_array[10'd122], memory_array[10'd121], memory_array[10'd120]} = 32'b00000001000000100000000000000001;
    //beq 0x01 1 2 //check failing beq //PC =  124
    {memory_array[10'd127], memory_array[10'd126], memory_array[10'd125], memory_array[10'd124]} = 32'b00000111000000010000000100000010;

    //j 0x02    //check jump to another block with instruction cache 
    {memory_array[10'd131], memory_array[10'd130], memory_array[10'd129], memory_array[10'd128]} = 32'b00000110000000100000000000000000;
    //mov 1 1   //PC = 132
    {memory_array[10'd135], memory_array[10'd134], memory_array[10'd133], memory_array[10'd132]} = 32'b00000001000000010000000000000001;
    //beq 0xFD 1 2  //PC = 136   //check backward beq //PC = 136
    {memory_array[10'd139], memory_array[10'd138], memory_array[10'd137], memory_array[10'd136]} = 32'b00000111111111010000000100000010;
    //mov 1 1   //PC = 140
    {memory_array[10'd143], memory_array[10'd142], memory_array[10'd141], memory_array[10'd140]} = 32'b00000001000000010000000000000001;

    //j 0x02    //check jump with instruction cache 
    {memory_array[10'd147], memory_array[10'd146], memory_array[10'd145], memory_array[10'd144]} = 32'b00000110000000100000000000000000;
    //j 0x00    //check jump with zero offset //PC = 148
    {memory_array[10'd151], memory_array[10'd150], memory_array[10'd149], memory_array[10'd148]} = 32'b00000110000000000000000000000000;
    //j 0x01    //PC = 152
    {memory_array[10'd155], memory_array[10'd154], memory_array[10'd153], memory_array[10'd152]} = 32'b00000110000000010000000000000000;
    //j 0xFD    //check jump with negative offset   //PC = 156 
    {memory_array[10'd159], memory_array[10'd158], memory_array[10'd157], memory_array[10'd156]} = 32'b00000110111111010000000000000000;

    //loadi 4 0x05 //PC = 160
    {memory_array[10'd163], memory_array[10'd162], memory_array[10'd161], memory_array[10'd160]} = 32'b00000000000001000000000000000010;
    //loadi 5 0x01
    {memory_array[10'd167], memory_array[10'd166], memory_array[10'd165], memory_array[10'd164]} = 32'b00000000000001010000000000000001;
    //sub 4 4 5
    {memory_array[10'd171], memory_array[10'd170], memory_array[10'd169], memory_array[10'd168]} = 32'b00000011000001000000010000000101;
    //beq 0xFE 4 5  //loop till reg 4 value not equal to reg 5 value   //PC = 172
    {memory_array[10'd175], memory_array[10'd174], memory_array[10'd173], memory_array[10'd172]} = 32'b00000111111111100000010000000101;

    //mov 5 4 
    {memory_array[10'd179], memory_array[10'd178], memory_array[10'd177], memory_array[10'd176]} = 32'b00000001000001010000000000000100;
    //beq 0x01 4 4  //beq command with comparing same register
    {memory_array[10'd183], memory_array[10'd182], memory_array[10'd181], memory_array[10'd180]} = 32'b00000111000000010000010000000100;
    //mov 4 4       //mov command with same registers   
    {memory_array[10'd187], memory_array[10'd186], memory_array[10'd185], memory_array[10'd184]} = 32'b00000001000001000000000000000100;
    //beq 0xFF 4 5  //iterate within the same instruction (inifinitely) 
    //{memory_array[10'd191], memory_array[10'd190], memory_array[10'd189], memory_array[10'd188]} = 32'b00000111111111110000010000000101;
    //mov 4 4  
    {memory_array[10'd191], memory_array[10'd190], memory_array[10'd189], memory_array[10'd188]} = 32'b00000001000001000000000000000100;

    //loadi 1 0x00      //PC = 192
    {memory_array[10'd195], memory_array[10'd194], memory_array[10'd193], memory_array[10'd192]} = 32'b00000000000000010000000000000000;
    //loadi 2 0x04
    {memory_array[10'd199], memory_array[10'd198], memory_array[10'd197], memory_array[10'd196]} = 32'b00000000000000100000000000000100;
    //j 0x02    //check jump to another block with instruction cache 
    {memory_array[10'd203], memory_array[10'd202], memory_array[10'd201], memory_array[10'd200]} = 32'b00000110000000100000000000000000;
    //loadi 4 0x05
    {memory_array[10'd207], memory_array[10'd206], memory_array[10'd205], memory_array[10'd204]} = 32'b00000000000001000000000000000101;

    //swd 3 1           //check store word dirct    //PC = 208
    {memory_array[10'd211], memory_array[10'd210], memory_array[10'd209], memory_array[10'd208]} = 32'b00001010000000000000001100000001;
    //lwd 5 1           //check load word direct
    {memory_array[10'd215], memory_array[10'd214], memory_array[10'd213], memory_array[10'd212]} = 32'b00001000000001010000000000000001;
    //mov 6 5
    {memory_array[10'd219], memory_array[10'd218], memory_array[10'd217], memory_array[10'd216]} = 32'b00000001000001100000000000000101;
    //swi 4 0x04        //check store word immdeiate
    {memory_array[10'd223], memory_array[10'd222], memory_array[10'd221], memory_array[10'd220]} = 32'b00001011000000000000010000000100;

    //lwi 5 0x04        //check load word immediate  //PC = 224
    {memory_array[10'd227], memory_array[10'd226], memory_array[10'd225], memory_array[10'd224]} = 32'b00001001000001010000000000000100;
    //mov 6 5
    {memory_array[10'd231], memory_array[10'd230], memory_array[10'd229], memory_array[10'd228]} = 32'b00000001000001100000000000000101;
    //swd 4 2           //overwriting a location in the data memory
    {memory_array[10'd235], memory_array[10'd234], memory_array[10'd233], memory_array[10'd232]} = 32'b00001010000000000000010000000010;
    //lwi 5 0x04
    {memory_array[10'd239], memory_array[10'd238], memory_array[10'd237], memory_array[10'd236]} = 32'b00001001000001010000000000000100;

    //mov 6 5           //PC = 240
    {memory_array[10'd243], memory_array[10'd242], memory_array[10'd241], memory_array[10'd240]} = 32'b00000001000001100000000000000101;
    //lwi 5 0x01 
    {memory_array[10'd247], memory_array[10'd246], memory_array[10'd245], memory_array[10'd244]} = 32'b00001001000001010000000000000001;
    //mov 6 5
    {memory_array[10'd251], memory_array[10'd250], memory_array[10'd249], memory_array[10'd248]} = 32'b00000001000001100000000000000101;
    //swi 4 0x01 
    {memory_array[10'd255], memory_array[10'd254], memory_array[10'd253], memory_array[10'd252]} = 32'b00001011000000000000010000000001;

    //lwi 5 0x01 
    {memory_array[10'd259], memory_array[10'd258], memory_array[10'd257], memory_array[10'd256]} = 32'b00001001000001010000000000000001;
    //mov 6 5
    {memory_array[10'd263], memory_array[10'd262], memory_array[10'd261], memory_array[10'd260]} = 32'b00000001000001100000000000000101;
    //lwd 5 1
    {memory_array[10'd267], memory_array[10'd266], memory_array[10'd265], memory_array[10'd264]} = 32'b00001000000001010000000000000001;
    //swd 4 2   
    {memory_array[10'd271], memory_array[10'd270], memory_array[10'd269], memory_array[10'd268]} = 32'b00001010000000000000010000000010;

end

//Detecting an incoming memory access
always @(read)
begin
    busywait = (read)? 1 : 0;
    readaccess = (read)? 1 : 0;
end

//Reading
always @(posedge clock)
begin
    if(readaccess)
    begin
        readdata[7:0]     = #40 memory_array[{address,4'b0000}];
        readdata[15:8]    = #40 memory_array[{address,4'b0001}];
        readdata[23:16]   = #40 memory_array[{address,4'b0010}];
        readdata[31:24]   = #40 memory_array[{address,4'b0011}];
        readdata[39:32]   = #40 memory_array[{address,4'b0100}];
        readdata[47:40]   = #40 memory_array[{address,4'b0101}];
        readdata[55:48]   = #40 memory_array[{address,4'b0110}];
        readdata[63:56]   = #40 memory_array[{address,4'b0111}];
        readdata[71:64]   = #40 memory_array[{address,4'b1000}];
        readdata[79:72]   = #40 memory_array[{address,4'b1001}];
        readdata[87:80]   = #40 memory_array[{address,4'b1010}];
        readdata[95:88]   = #40 memory_array[{address,4'b1011}];
        readdata[103:96]  = #40 memory_array[{address,4'b1100}];
        readdata[111:104] = #40 memory_array[{address,4'b1101}];
        readdata[119:112] = #40 memory_array[{address,4'b1110}];
        readdata[127:120] = #40 memory_array[{address,4'b1111}];
        busywait = 0;
        readaccess = 0;
    end
end
 
endmodule