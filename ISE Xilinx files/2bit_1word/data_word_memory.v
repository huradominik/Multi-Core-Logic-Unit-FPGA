`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module data_word_memory(CLK, D_WE, A, DI, DQ);

parameter AW = 16;
parameter DW = 32;

	
input CLK;
input D_WE;
input [AW-1:0] A;
input [DW-1:0] DI;
output [DW-1:0] DQ;

wire [DW-1:0] DQ;

(* ram_style = "block" *) reg [DW-1:0] MEM [4095:0];

reg [AW-1:0] DA;	// rejestr na adres

always @(posedge CLK) begin
	DA <= A;
	if(D_WE) MEM[A] <= DI;
	end
		
assign DQ = MEM[DA];


endmodule