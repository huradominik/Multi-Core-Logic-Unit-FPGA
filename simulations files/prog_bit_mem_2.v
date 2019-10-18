`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module prog_bit_mem_2(
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
	
reg [DW-1:0] MEM [MEM_SIZE - 1 : 0];

reg	[11:0] IA_Q; 

initial begin
	ORG(12'd0);
	WR_MEM({`I_LD,`M_N, 12'h000});
	WR_MEM({`I_OR,`M_N, 12'h001});
	WR_MEM({`I_AND,`M_O, 12'h00b});
	WR_MEM({`I_LD,`M_N, 12'h800});
	WR_MEM({`I_OR,`M_N, 12'h004});
	WR_MEM({`I_NOP,`M_C, 12'h005});
	WR_MEM({`I_AND,`M_O, 12'h008});
	WR_MEM({`I_LD,`M_N, 12'h000});
	WR_MEM({`I_ORN,`M_N, 12'h001});
	WR_MEM({`I_NOP,`M_C, 12'h001});
	WR_MEM({`I_ST,`M_N, 12'h003});
	WR_MEM({`I_LD,`M_N, 12'h000});
	WR_MEM({`I_JMP,`M_N, 12'hfff});
	/*WR_MEM({`I_JMPC, 12'h000});
	WR_MEM({`I_ST, 12'h003});
	WR_MEM({`I_LD, 12'h005});
	WR_MEM({`I_ST, 12'h004});
	WR_MEM({`I_LD, 12'h000});
	WR_MEM({`I_ST, 12'h006});
	WR_MEM({`I_LD, 12'h001});
	WR_MEM({`I_ST, 12'h806});
	WR_MEM({`I_LD, 12'h003});
	WR_MEM({`I_ST, 12'h807});
	//WR_MEM({`I_ST, 12'h007});
	WR_MEM({`I_LD, 12'h007});
	WR_MEM({`I_ST, 12'h002});
	WR_MEM({`I_LD, 12'h003});
	WR_MEM({`I_ST, 12'h000});
	WR_MEM({`I_LD, 12'h001});
	WR_MEM({`I_ST, 12'h00B});
	WR_MEM({`I_LD, 12'h818});
	WR_MEM({`I_ST, 12'h800});
	WR_MEM({`I_LDN, 12'h00F});
	WR_MEM({`I_JMP, 12'hfff});
	*/
end

always @(posedge CLK) begin
	IA_Q <= A;
	if(WE) MEM[A] <= DI;
end	
	
assign DQ = MEM[A];

/*synthesis translate_off*/
integer org = 0;


task WR_MEM;
input [DW-1:0] IDD;
begin
	MEM[org] = IDD;
	org = org + 1;
end
endtask

task ORG;
input [AW-1:0] IAA;
begin
	org = IAA;
end
endtask

/*synthesis translate_on*/

endmodule