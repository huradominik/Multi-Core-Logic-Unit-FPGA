`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module prog_bit_mem(
	CLK, 
	A, WE, DI, DQ);

parameter DW = 18;
parameter AW = 12;
parameter MEM_SIZE = (1 << AW);

input CLK;
input [AW-1:0] A;
input WE;
input [DW-1:0] DI;
output [DW-1:0] DQ;
	
(* ram_style = "block" *) reg [DW-1:0] MEM [MEM_SIZE - 1 : 0];

reg	[11:0] IA_Q; 

always @(posedge CLK) begin
	if(WE) MEM[A] <= DI;
end	
	
assign DQ = MEM[A];


endmodule