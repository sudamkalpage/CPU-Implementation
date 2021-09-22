/*
CO 224 (computer architecture) Lab 06 Task 03
Design: Instruction cache module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 16/06/2020
*/

`timescale  1ns/100ps

`include "mux_4x1_32bits.v" 

`timescale  1ns/100ps

module icache (
    clock,
    reset,
    address,
    readdata,
	busywait,

    mem_read,
    mem_address,
    mem_readdata,
	mem_busywait
);

    input				clock;
    input           	reset;
    input[9:0]      	address;
    output reg [31:0]	readdata;
    output reg      	busywait;

    output reg          mem_read;
    output reg [5:0]    mem_address;
    input[127:0]	    mem_readdata;
    input        	    mem_busywait; 

    reg [127:0] data_array [7:0];    //Declare cache data array 8x32-bits 
    reg [2:0] tag_array [7:0];      //Declare cache tag array 8x3-bits     
    reg valid_array [7:0];          //Declare cache valid bit array 8-bits    

    reg [2:0]  index; 
    reg [2:0]  required_tag;        //tag in the adress of cache (alu result)
    reg [1:0] offset;

    wire hit;                        //hit status(whether hit or miss: if hit hit = 1 )
    reg valid;
    reg [2:0]  tag;                 //current tag in the tag array at the corresponding index
    reg [127:0] instruction_block;
    wire [31:0] word;

    reg readaccess;    
    wire txn1,txn2,txn3;            //temporary xnor gates outputs
    reg cmp_out;                    //comparator output
    integer i;

    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */

    //assert cache busywait
    always @(address)
    begin
        if (address != -10'd4 )
        begin 
             busywait =  1;
             readaccess =  1;
        end
    end

    //reset 
    always@(reset)
    begin
        if (reset)
        begin
            for (i=0; i<8; i=i+1)   
                begin
                    valid_array [i] = 0;
                    tag_array [i] = 3'bx;
                end
            for (i=0; i<1024; i=i+1)
                data_array[i] = 0;               
            busywait = 0;
            readaccess = 0;
        end
    end
    

    always @(*)
     begin
        //indexing
        index = address[6:4] ; 
        required_tag = address[9:7] ; 
        offset = address[3:2];

        //extracting required data from arrays for ongoing operations 
        #1
        instruction_block = data_array[index];
        tag = tag_array[index];
        valid = valid_array[index];
    end


    //tag comparison
    xnor(txn1, tag[0], required_tag[0]);
    xnor(txn2, tag[1], required_tag[1]);
    xnor(txn3, tag[2], required_tag[2]);
    always @(*)
    begin
        #1
        cmp_out = txn1 && txn2 && txn3;
    end
    //deciding the hit status
    and (hit,cmp_out,valid);


    //select word from block
    mux_4x1_32bits instruction_selector(instruction_block[31:0],instruction_block[63:32],instruction_block[95:64],instruction_block[127:96],offset,word);


    //read hit
    always @(*)
    begin
        readdata = word;
    end


    //de-assert busywait at the clock positive edge   
    always @(posedge clock)
    begin
        if (hit)
            begin
                busywait = 0;
            end
    end
       

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001,  UPDATE_CACHE = 3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((readaccess) && !hit)  
                    next_state = MEM_READ;                             
                else
                    next_state = IDLE;
            
            
            MEM_READ:           
                if (!mem_busywait)
                    next_state = UPDATE_CACHE;
                
                else    
                    next_state = MEM_READ;

            UPDATE_CACHE:
                    next_state = IDLE;          
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_address = 6'dx;
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_address = address[9:4];
                busywait = 1;
            end

            UPDATE_CACHE: 
            begin
                mem_read = 0;
                mem_address = address[9:4];         
                data_array[index] = #1 mem_readdata;
                valid_array[index] = 1;
                tag_array[index] = required_tag;
            end
            
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)
            state = IDLE;
        else
            state = next_state;
    end

    /* Cache Controller FSM End */

endmodule