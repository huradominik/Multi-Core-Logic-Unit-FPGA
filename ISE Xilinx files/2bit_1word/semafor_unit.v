`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"



module semafor_unit(
	CLK, CLR,
	DI, DQ,
	/*AW, AR,*/
	WR, WR_EN, WR_RDY,
	RD, RD_EN, RD_RDY,
	REALASE);
	
	
input CLK, CLR;
input DI;
output reg DQ;

input WR;		// write
input WR_EN;	// write enable
output  WR_RDY;	// write ready

//input [1:0]AR;	// adress read
input RD;
input RD_EN;
output  RD_RDY;
input REALASE;			// jeden bit 

reg MW_DA;
reg MW_QA;
reg MW_QB;


reg MR_DA;
reg MR_QA;
reg MR_QB;

reg WE_MW;
reg WE_MR;


//reg MEM[3:0];
//wire WR_RDY;
//wire RD_RDY;
initial begin
	MR_DA <= 1'b0;
	MW_DA <= 1'b0;
	DQ <= 1'b0;
end

always @(posedge CLK) begin
	if(CLR) begin
		MW_QA <= 0;
		MW_QB <= 0;
		MR_QA <= 0;
		MR_QB <= 0;
	end
else begin
	if(WE_MW) begin 

		MW_QA <= ~MW_QA;
		MW_QB <= ~MW_QB;
		DQ <= DI;  		
	end
	if(WE_MR) begin 
		MR_QA <= ~MR_QA;
		MR_QB <= ~MR_QB;
	
	end
		
end

end

always@(*) begin	
	WE_MW = WR & WR_RDY;
	WE_MR = REALASE & RD & RD_RDY;	
end

assign WR_RDY = (MW_QA ~^ MR_QB) & WR_EN;
assign RD_RDY =  (MW_QB ^ MR_QA) & RD_EN;



endmodule