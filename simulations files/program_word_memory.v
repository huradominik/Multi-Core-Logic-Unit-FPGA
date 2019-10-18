`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module program_word_memory(
	CLK,
	A, WE, DI, DQ);
	
parameter IA_W = 16;	
parameter ID_W = 24;	//
parameter MEM_SIZE = (1 << IA_W);


input CLK;
input [IA_W-1:0] A;
input WE;
input [ID_W-1:0] DI;
output [ID_W-1:0] DQ;

reg [ID_W-1:0] MEM [MEM_SIZE-1:0];

reg [IA_W-1:0] IWA_Q;		// rejestr do potoku

integer d_org;
initial begin
	for(d_org = 0; d_org < 65536; d_org = d_org + 1)
	MEM[d_org] = 24'd0;
	MEM[0] = {`IA_LDI, 16'h0005};
	MEM[1] = {`IA_MUL, 16'h0001};
	MEM[2] = {`IA_DIV, 16'h0005};
	MEM[3] = {`IA_STW, 16'h000A};
	MEM[4] = {`IA_LDI, 16'h0005};
	MEM[5] = {`IA_MUL, 16'h0001};
	MEM[6] = {`IA_DIV, 16'h0005};
	MEM[7] = {`IA_STW, 16'h000A};
	MEM[8] = {`IA_STB, 16'h0001};
	MEM[9] = {`IA_LDI, 16'h0002};
	MEM[10] = {`IA_STW, 16'h0002};
	MEM[11] = {`IA_LDI, 16'h0008};
	MEM[12] = {`IA_DIV, 16'h0002};
	MEM[13] = {`IA_STW, 16'h000C};
	MEM[14] = {`IA_JMP, 16'hffff};
	//MEM[12] = {`IA_JMP, 16'h0000};
				
end

always @(posedge CLK) begin
	IWA_Q <= A;
	if(WE) MEM[A] <= DI;	
end
	
assign DQ = MEM[A];	

/*synthesis translate_off*/ //
integer org = 0;


task WR_MEM;
input [ID_W-1:0] IDD;
begin
	MEM[org] = IDD;
	org = org + 1;
end
endtask

task ORG;
input [IA_W-1:0] IAA;
begin
	org = IAA;
end
endtask

/*synthesis translate_on*/ 


endmodule