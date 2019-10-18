`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module data_word_memory(
	CLK,
	D_WE,
	A, DI, DQ);

parameter AW = 16;
parameter DW = 32;

	
input CLK;
input D_WE;
input [AW-1:0] A;
input [DW-1:0] DI;
output [DW-1:0] DQ;

wire [DW-1:0] DQ;

reg [DW-1:0] MEM [31:0];

reg [AW-1:0] DA;	// rejestr na adres

always @(posedge CLK) begin
	DA <= A;
	if(D_WE) MEM[A] <= DI;
	end
		
assign DQ = MEM[DA];

integer d_org;
initial begin
	for(d_org = 0; d_org < 65536; d_org = d_org + 1)
		MEM[d_org] = 32'd0;
		MEM[0] = 32'd200;
		MEM[1] = 32'd300;
		MEM[2] = 32'd800;
		MEM[3] = 32'd500;
		MEM[4] = 32'd500;
		MEM[5] = 32'd2;
		MEM[9] = 32'hf5;
		MEM[11] = 32'h75;
		
end	
endmodule