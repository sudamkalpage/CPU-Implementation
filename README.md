# CPU-Implementation

Here i have designed a simple 8-bit single-cycle processor which includes 

<ul>
<li>an ALU</li>
<li> a register file</li>
<li>control logic</li>
 <li>memory sub-system</li>
  
</ul>

using Verilog HDL. The microarchitecture of a processor is designed based on an Instruction Set. this
processor can implement the instructions add, sub, and, or, mov, loadi, j
and beq, lwi, lwd, swi, swd. All instructions are of 32-bit fixed length and in the seperate memory system according to harvard architecture.

To compile 
```
iverilog -o cpu_tb.vvp cpu_tb.v
```

To run
```
vvp cpu_tb.vvp
```

To open with gtkwave tool
```
iverilog -o cpu_tb.vvp cpu_tb.v
```
