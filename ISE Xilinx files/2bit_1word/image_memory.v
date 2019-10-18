`timescale 1 ns / 1 ps

module image_memory(
	CLK,
	A_0, DI_0, DQ_0, WE_0,
	A_1, DI_1, DQ_1, WE_1);
	
parameter A_W = 5;
parameter D_W = 1;
	
	input CLK;
	
	// input-output area //
	
	input [A_W-1:0] A_0;
	input [D_W-1:0] DI_0;
	input WE_0;
	output [D_W-1:0] DQ_0;
	
	// exchange area //
	
	input [A_W-1:0] A_1;
	input [D_W-1:0] DI_1;
	input WE_1;
	output [D_W-1:0] DQ_1;

	(* ram_style = "block" *) reg MEM [31:0];
	reg [A_W-1:0] addr;
	
	reg [A_W-1:0] addr_0;
	reg rwe_1;


	integer i;
initial begin
	for( i = 0; i < 32; i = i + 1)
	MEM[0] = 1'b0;
	MEM[1] = 1'b0;
	MEM[2] = 1'b0;
	MEM[3] = 1'b0;
	MEM[4] = 1'b1;
	MEM[5] = 1'b1;
	MEM[6] = 1'b1;
	MEM[7] = 1'b1;
	MEM[8] = 1'b1;
	MEM[9] = 1'b0;
	MEM[10] = 1'b1;
	MEM[11] = 1'b0;
	MEM[12] = 1'b1;
	MEM[13] = 1'b1;
	MEM[14] = 1'b1;
	MEM[15] = 1'b1;
	MEM[16] = 1'b1;
	MEM[17] = 1'b0;
	MEM[18] = 1'b1;
	MEM[19] = 1'b0;
	MEM[20] = 1'b1;
	MEM[21] = 1'b0;
	MEM[22] = 1'b1;
	MEM[23] = 1'b0;
	MEM[24] = 1'b1;
	MEM[25] = 1'b0;
	MEM[26] = 1'b1;
	MEM[27] = 1'b0;
	MEM[28] = 1'b1;
	MEM[29] = 1'b0;
	MEM[30] = 1'b1;
	MEM[31] = 1'b0;
end
	
always @(posedge CLK) begin
	addr <= A_1;
	//addr_0 <= A_0;
	rwe_1 <= WE_1;
	if(WE_0) MEM[A_0] <= DI_0;
	if(rwe_1) MEM[addr] <= DI_1;
	end
	
	
	assign DQ_0 = MEM[A_0];
	assign DQ_1 = MEM[A_1];
		
		
	
endmodule	