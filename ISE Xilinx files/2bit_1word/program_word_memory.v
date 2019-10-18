`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module program_word_memory(CLK, A, WE, DI, DQ);
	
parameter IA_W = 16;	
parameter ID_W = 24;	//
parameter MEM_SIZE = (1 << IA_W);


input CLK;
input [IA_W-1:0] A;
input WE;
input [ID_W-1:0] DI;
output [ID_W-1:0] DQ;

(* ram_style = "block" *) reg [ID_W-1:0] MEM [MEM_SIZE-1:0];

reg [IA_W-1:0] IWA_Q;		// rejestr do potoku


always @(posedge CLK) begin
	if(WE) MEM[A] <= DI;	
end
	
assign DQ = MEM[A];	

endmodule