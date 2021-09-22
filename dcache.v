/*
CO 224 (computer architecture) Lab 06 Task 01
Design: Data cache module
Author: Kalpage S.W.
Reg no: E/16/168
Date  : 31/05/2020
*/

`include "mux_4x1_8bits.v" 

`timescale  1ns/100ps

module dcache (
    clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
	busywait,

    mem_read,
    mem_write,
    mem_address,
    mem_writedata,
    mem_readdata,
	mem_busywait

);

    input				clock;
    input           	reset;
    input           	read;
    input           	write;
    input[7:0]      	address;
    input[7:0]     	    writedata;
    output reg [7:0]	readdata;
    output reg      	busywait;

    output reg          mem_read;
    output reg          mem_write;
    output reg [5:0]    mem_address;
    output reg [31:0]   mem_writedata;
    input[31:0]	        mem_readdata;
    input        	    mem_busywait; 

    reg [31:0] data_array [7:0];    //Declare cache data array 8x32-bits 
    reg [2:0] tag_array [7:0];      //Declare cache tag array 8x3-bits     
    reg valid_array [7:0];          //Declare cache valid bit array 8-bits 
    reg dirty_array [7:0];          //Declare cache dirty array 8-bits   

    reg [2:0]  index; 
    reg [2:0]  required_tag;        //tag in the adress of cache (alu result)
    reg [1:0] offset;

    wire hit;                        //hit status(whether hit or miss: if hit hit = 1 )
    reg dirty;
    reg valid;
    reg [2:0]  tag;                 //current tag in the tag array at the corresponding index
    reg [31:0] data_block;
    wire [7:0] word;

    reg readaccess, writeaccess;    
    wire txn1,txn2,txn3;            //temporary xnor gates outputs
    reg cmp_out;                    //comparator output
    integer i;

    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */

    //assert cache busywait
    always @(read, write)
    begin
        busywait = (read || write)? 1 : 0;
        readaccess = (read && !write)? 1 : 0;
        writeaccess = (!read && write)? 1 : 0;
    end

    //reset 
    always@(reset)
    begin
        if (reset)
        begin
            for (i = 0; i < 8; i = i + 1)
                begin     
                        valid_array [i] = 0;
                        dirty_array [i] = 0;
                end
            for (i=0;i<256; i=i+1)
                data_array[i] = 0;               
            busywait = 0;
            readaccess = 0;
            writeaccess = 0;
        end
    end
    

    always @(*)
     begin
        //indexing
        index = address[4:2] ; 
        required_tag = address[7:5] ; 
        offset = address[1:0];

        //extracting required data from arrays for ongoing operations 
        #1
        data_block = data_array[index];
        tag = tag_array[index];
        valid = valid_array[index];
        dirty = dirty_array[index];
    end


    //tag comparison
    xnor(txn1, tag[0], required_tag[0]);
    xnor(txn2, tag[1], required_tag[1]);
    xnor(txn3, tag[2], required_tag[2]);
    always @(*)
    begin
        #0.9
        cmp_out = txn1 && txn2 && txn3;
    end
    //deciding the hit status
    and (hit,cmp_out,valid);


    //select word from block
    mux_4x1_8bits word_selector(data_block[7:0],data_block[15:8],data_block[23:16],data_block[31:24],offset,word);


    //read hit
    always @(*)
    begin
        readdata = word;  
    end

    //write hit
    always @(posedge clock)
    begin
        if (hit && writeaccess)
            begin              
                case(offset)
                    2'b00 : data_array[index][7:0] = #1 writedata;
                    2'b01 : data_array[index][15:8] = #1 writedata;
                    2'b10 : data_array[index][23:16] = #1 writedata;
                    2'b11 : data_array[index][31:24] = #1 writedata;
                endcase
                writeaccess = 0;
                valid_array[index] = 1;
                dirty_array[index] = 1;       //for write hit
            end
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

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010, UPDATE_CACHE = 3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)  
                    next_state = MEM_READ;
                
                else if ((read || write) && dirty && !hit)
                    next_state = MEM_WRITE;
                             
                else
                    next_state = IDLE;
            
            
            MEM_READ:           
                if (!mem_busywait)
                    next_state = UPDATE_CACHE;
                
                else    
                    next_state = MEM_READ;

            MEM_WRITE:           
                if (!mem_busywait)
                    next_state = MEM_READ;
                
                else    
                    next_state = MEM_WRITE;

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
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = address[7:2];
                mem_writedata = 32'dx;
                busywait = 1;
            end

            MEM_WRITE: 
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = address[7:2];
                mem_writedata = data_block;
                busywait = 1;
            end

            UPDATE_CACHE: 
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = address[7:2];
                mem_writedata = 32'dx;              
                data_array[index] = #1 mem_readdata;
                valid_array[index] = 1;
                tag_array[index] = required_tag;
                dirty_array[index] = 0;
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