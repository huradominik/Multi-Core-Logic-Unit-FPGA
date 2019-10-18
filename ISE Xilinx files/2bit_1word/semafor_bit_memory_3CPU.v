`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module semafor_bit_memory_3CPU(
	CLK, CLR,
	A_0, DI_0, DQ_0, WE_0, OE_0, WT_0,
	A_1, DI_1, DQ_1, WE_1, OE_1, WT_1,
	A_2, DI_2, DQ_2, WE_2, OE_2, WT_2);	
	
	
input CLK, CLR;
input [11:0] A_0, A_1, A_2; 
input DI_0, DI_1, DI_2;
output reg DQ_0, DQ_1, DQ_2;
input WE_0, WE_1, WE_2;
input OE_0, OE_1, OE_2;
output WT_0, WT_1, WT_2;


(* ram_style = "block" *) reg MEM[1023:0];
reg [11:0]ADR_REG_0;
reg [11:0]ADR_REG_1;
reg [11:0]ADR_REG_2;


always @(posedge CLK) begin
	ADR_REG_0 <= A_0;
	ADR_REG_1 <= A_1;
	ADR_REG_2 <= A_2;
										  // arbiter do zapisu komórki pamiêci
	if(WE_0 & (~|A_0[11:10]))
		MEM[A_0[9:0]] <= DI_0;
	if(WE_1 & (~|A_1[11:10]))
		MEM[A_1[9:0]] <= DI_1;
	if(WE_2 & (~|A_2[11:10]))
		MEM[A_2[9:0]] <= DI_2;
		
end

	
wire SEM_NON_WT_0 = (~|A_0[11:10]);
wire SEM_NON_WT_1 = (~|A_1[11:10]);
wire SEM_NON_WT_2 = (~|A_2[11:10]);


//-----------------------------------------------------------------
//Port 0 semaphores  // ZAPIS BIT_1 // ODCZYT BAJT // ODCZYT BIT_2
//-----------------------------------------------------------------

wire SEM_0_0_WE_0 = WE_0 & A_0[11] & (A_0[4:0] == 5'b0_0000);
wire SEM_0_1_WE_0 = WE_0 & A_0[11] & (A_0[4:0] == 5'b0_0001);
wire SEM_0_2_WE_0 = WE_0 & A_0[11] & (A_0[4:0] == 5'b0_0010);
wire SEM_0_3_WE_0 = WE_0 & A_0[11] & (A_0[4:0] == 5'b0_0011);

wire SEM_0_0_RD_1 = OE_1 & A_1[11] & (A_1[4:0] == 5'b0_0000);
wire SEM_0_1_RD_1 = OE_1 & A_1[11] & (A_1[4:0] == 5'b0_0001);
wire SEM_0_2_RD_1 = OE_1 & A_1[11] & (A_1[4:0] == 5'b0_0010);
wire SEM_0_3_RD_1 = OE_1 & A_1[11] & (A_1[4:0] == 5'b0_0011);

wire SEM_0_0_RD_2 = OE_2 & A_2[11] & (A_2[4:0] == 5'b0_0000);
wire SEM_0_1_RD_2 = OE_2 & A_2[11] & (A_2[4:0] == 5'b0_0001);
wire SEM_0_2_RD_2 = OE_2 & A_2[11] & (A_2[4:0] == 5'b0_0010);
wire SEM_0_3_RD_2 = OE_2 & A_2[11] & (A_2[4:0] == 5'b0_0011);

wire SEM_0_0_DQ, SEM_0_1_DQ, SEM_0_2_DQ, SEM_0_3_DQ; 
wire SEM_0_0_WR_0, SEM_0_1_WR_0, SEM_0_2_WR_0, SEM_0_3_WR_0; 
wire SEM_0_0_RR, SEM_0_1_RR, SEM_0_2_RR, SEM_0_3_RR; 

wire WR_EN_0_0_0 = &(A_0[4:0] == 5'b0_0000);
wire WR_EN_0_1_0 = &(A_0[4:0] == 5'b0_0001);
wire WR_EN_0_2_0 = &(A_0[4:0] == 5'b0_0010);
wire WR_EN_0_3_0 = &(A_0[4:0] == 5'b0_0011);
																				  //Port Semagfora//Komórka pamieci//numer dostepu
wire RD_EN_0_0_1 = &(A_1[4:0] == 5'b0_0000);										 ///0_0_2
wire RD_EN_0_1_1 = &(A_1[4:0] == 5'b0_0001);
wire RD_EN_0_2_1 = &(A_1[4:0] == 5'b0_0010);
wire RD_EN_0_3_1 = &(A_1[4:0] == 5'b0_0011);

wire RD_EN_0_0_2 = &(A_2[4:0] == 5'b0_0000);
wire RD_EN_0_1_2 = &(A_2[4:0] == 5'b0_0001);
wire RD_EN_0_2_2 = &(A_2[4:0] == 5'b0_0010);
wire RD_EN_0_3_2 = &(A_2[4:0] == 5'b0_0011);

// WPIS BIT // ODCZYT BAJT //

semafor_unit SEM_0_0(		   
.CLK(CLK), .CLR(CLR), .DI(DI_0), .DQ(SEM_0_0_DQ),
.WR(SEM_0_0_WE_0), .WR_EN(WR_EN_0_0_0), .WR_RDY(SEM_0_0_WR_0), .RD(SEM_0_0_RD_1 || SEM_0_0_RD_2),
.RD_EN(RD_EN_0_0_1 || RD_EN_0_0_2), .RD_RDY(SEM_0_0_RR), .REALASE(A_1[7] || A_2[7]));

semafor_unit SEM_0_1(		   
.CLK(CLK), .CLR(CLR), .DI(DI_0), .DQ(SEM_0_1_DQ),
.WR(SEM_0_1_WE_0), .WR_EN(WR_EN_0_1_0), .WR_RDY(SEM_0_1_WR_0), .RD(SEM_0_1_RD_1 || SEM_0_1_RD_2),
.RD_EN(RD_EN_0_1_1 || RD_EN_0_1_2), .RD_RDY(SEM_0_1_RR), .REALASE(A_1[7] || A_2[7]));

semafor_unit SEM_0_2(		   
.CLK(CLK), .CLR(CLR), .DI(DI_0), .DQ(SEM_0_2_DQ),
.WR(SEM_0_2_WE_0), .WR_EN(WR_EN_0_2_0), .WR_RDY(SEM_0_2_WR_0), .RD(SEM_0_2_RD_1 || SEM_0_2_RD_2),
.RD_EN(RD_EN_0_2_1 || RD_EN_0_2_2), .RD_RDY(SEM_0_2_RR), .REALASE(A_1[7] || A_2[7]));

semafor_unit SEM_0_3(		   
.CLK(CLK), .CLR(CLR), .DI(DI_0), .DQ(SEM_0_3_DQ),
.WR(SEM_0_3_WE_0), .WR_EN(WR_EN_0_3_0), .WR_RDY(SEM_0_3_WR_0), .RD(SEM_0_3_RD_1 || SEM_0_3_RD_2),
.RD_EN(RD_EN_0_3_1 || RD_EN_0_3_2), .RD_RDY(SEM_0_3_RR), .REALASE(A_1[7] || A_2[7]));

//-------------------------------------------------------------------
//Port 1 semaphores	 // ZAPIS BAJT // ODCZYT BIT_1 //  ODCZYT BIT_2
//--------------------------------------------------------------------

wire SEM_1_0_WE_1 = WE_1 & A_1[11] & (A_1[4:0] == 5'b0_1000);
wire SEM_1_1_WE_1 = WE_1 & A_1[11] & (A_1[4:0] == 5'b0_1001);
wire SEM_1_2_WE_1 = WE_1 & A_1[11] & (A_1[4:0] == 5'b0_1010);
wire SEM_1_3_WE_1 = WE_1 & A_1[11] & (A_1[4:0] == 5'b0_1011);

wire SEM_1_0_RD_0 = OE_0 & A_0[11] & (A_0[4:0] == 5'b0_1000);
wire SEM_1_1_RD_0 = OE_0 & A_0[11] & (A_0[4:0] == 5'b0_1001);
wire SEM_1_2_RD_0 = OE_0 & A_0[11] & (A_0[4:0] == 5'b0_1010);
wire SEM_1_3_RD_0 = OE_0 & A_0[11] & (A_0[4:0] == 5'b0_1011);

wire SEM_1_0_RD_2 = OE_2 & A_2[11] & (A_2[4:0] == 5'b0_1000);
wire SEM_1_1_RD_2 = OE_2 & A_2[11] & (A_2[4:0] == 5'b0_1001);
wire SEM_1_2_RD_2 = OE_2 & A_2[11] & (A_2[4:0] == 5'b0_1010);
wire SEM_1_3_RD_2 = OE_2 & A_2[11] & (A_2[4:0] == 5'b0_1011);

wire SEM_1_0_DQ, SEM_1_1_DQ, SEM_1_2_DQ, SEM_1_3_DQ;
wire SEM_1_0_WR_1, SEM_1_1_WR_1, SEM_1_2_WR_1, SEM_1_3_WR_1; 
wire SEM_1_0_RR, SEM_1_1_RR, SEM_1_2_RR, SEM_1_3_RR;

wire WR_EN_1_0_1 = &(A_1[4:0] == 5'b0_1000);
wire WR_EN_1_1_1 = &(A_1[4:0] == 5'b0_1001);
wire WR_EN_1_2_1 = &(A_1[4:0] == 5'b0_1010);
wire WR_EN_1_3_1 = &(A_1[4:0] == 5'b0_1011);

wire RD_EN_1_0_0 = &(A_0[4:0] == 5'b0_1000);
wire RD_EN_1_1_0 = &(A_0[4:0] == 5'b0_1001);
wire RD_EN_1_2_0 = &(A_0[4:0] == 5'b0_1010);
wire RD_EN_1_3_0 = &(A_0[4:0] == 5'b0_1011);

wire RD_EN_1_0_2 = &(A_2[4:0] == 5'b0_1000);
wire RD_EN_1_1_2 = &(A_2[4:0] == 5'b0_1001);
wire RD_EN_1_2_2 = &(A_2[4:0] == 5'b0_1010);
wire RD_EN_1_3_2 = &(A_2[4:0] == 5'b0_1011);

// WPIS BAJT // ODCZYT BIT //

semafor_unit SEM_1_0(		   
.CLK(CLK), .CLR(CLR), .DI(DI_1), .DQ(SEM_1_0_DQ),
.WR(SEM_1_0_WE_1), .WR_EN(WR_EN_1_0_1), .WR_RDY(SEM_1_0_WR_1), .RD(SEM_1_0_RD_0 || SEM_1_0_RD_2),
.RD_EN(RD_EN_1_0_0 || RD_EN_1_0_2), .RD_RDY(SEM_1_0_RR), .REALASE(A_0[7] || A_2[7]));

semafor_unit SEM_1_1(		   
.CLK(CLK), .CLR(CLR), .DI(DI_1), .DQ(SEM_1_1_DQ),
.WR(SEM_1_1_WE_1), .WR_EN(WR_EN_1_1_1), .WR_RDY(SEM_1_1_WR_1), .RD(SEM_1_1_RD_0 || SEM_1_1_RD_2),
.RD_EN(RD_EN_1_1_0 || RD_EN_1_1_2), .RD_RDY(SEM_1_1_RR), .REALASE(A_0[7] || A_2[7]));

semafor_unit SEM_1_2(		   
.CLK(CLK), .CLR(CLR), .DI(DI_1), .DQ(SEM_1_2_DQ),
.WR(SEM_1_2_WE_1), .WR_EN(WR_EN_1_2_1), .WR_RDY(SEM_1_2_WR_1), .RD(SEM_1_2_RD_0 || SEM_1_2_RD_2),
.RD_EN(RD_EN_1_2_0 || RD_EN_1_2_2), .RD_RDY(SEM_1_2_RR), .REALASE(A_0[7] || A_2[7]));

semafor_unit SEM_1_3(		   
.CLK(CLK), .CLR(CLR), .DI(DI_1), .DQ(SEM_1_3_DQ),
.WR(SEM_1_3_WE_1), .WR_EN(WR_EN_1_3_1), .WR_RDY(SEM_1_3_WR_1), .RD(SEM_1_3_RD_0 || SEM_1_3_RD_2),
.RD_EN(RD_EN_1_3_0 || RD_EN_1_3_2), .RD_RDY(SEM_1_3_RR), .REALASE(A_0[7] || A_2[7]));

//-----------------------------------------------------------------
//Port 2 semaphores  // ZAPIS BIT_2 // ODCZYT BAJT // ODCZYT BIT_1
//-----------------------------------------------------------------

wire SEM_2_0_WE_2 = WE_2 & A_2[11] & (A_2[4:0] == 5'b1_0000);
wire SEM_2_1_WE_2 = WE_2 & A_2[11] & (A_2[4:0] == 5'b1_0001);
wire SEM_2_2_WE_2 = WE_2 & A_2[11] & (A_2[4:0] == 5'b1_0010);
wire SEM_2_3_WE_2 = WE_2 & A_2[11] & (A_2[4:0] == 5'b1_0011);

wire SEM_2_0_RD_0 = OE_0 & A_0[11] & (A_0[4:0] == 5'b1_0000);
wire SEM_2_1_RD_0 = OE_0 & A_0[11] & (A_0[4:0] == 5'b1_0001);
wire SEM_2_2_RD_0 = OE_0 & A_0[11] & (A_0[4:0] == 5'b1_0010);
wire SEM_2_3_RD_0 = OE_0 & A_0[11] & (A_0[4:0] == 5'b1_0011);

wire SEM_2_0_RD_1 = OE_1 & A_1[11] & (A_1[4:0] == 5'b1_0000);
wire SEM_2_1_RD_1 = OE_1 & A_1[11] & (A_1[4:0] == 5'b1_0001);
wire SEM_2_2_RD_1 = OE_1 & A_1[11] & (A_1[4:0] == 5'b1_0010);
wire SEM_2_3_RD_1 = OE_1 & A_1[11] & (A_1[4:0] == 5'b1_0011);
////////////////
wire SEM_2_0_DQ, SEM_2_1_DQ, SEM_2_2_DQ, SEM_2_3_DQ;
wire SEM_2_0_WR_2, SEM_2_1_WR_2, SEM_2_2_WR_2, SEM_2_3_WR_2;
wire SEM_2_0_RR, SEM_2_1_RR, SEM_2_2_RR, SEM_2_3_RR;

wire WR_EN_2_0_2 = &(A_2[4:0] == 5'b1_0000);
wire WR_EN_2_1_2 = &(A_2[4:0] == 5'b1_0001);
wire WR_EN_2_2_2 = &(A_2[4:0] == 5'b1_0010);
wire WR_EN_2_3_2 = &(A_2[4:0] == 5'b1_0011);
																				  //Port Semagfora//Komórka pamieci//numer dostepu
wire RD_EN_2_0_0 = &(A_0[4:0] == 5'b1_0000);										 ///0_0_2
wire RD_EN_2_1_0 = &(A_0[4:0] == 5'b1_0001);
wire RD_EN_2_2_0 = &(A_0[4:0] == 5'b1_0010);
wire RD_EN_2_3_0 = &(A_0[4:0] == 5'b1_0011);

wire RD_EN_2_0_1 = &(A_1[4:0] == 5'b1_0000);
wire RD_EN_2_1_1 = &(A_1[4:0] == 5'b1_0001);
wire RD_EN_2_2_1 = &(A_1[4:0] == 5'b1_0010);
wire RD_EN_2_3_1 = &(A_1[4:0] == 5'b1_0011);

// WPIS BIT_2 // ODCZYT BAJT // ODCZYT BIT_1

semafor_unit SEM_2_0(		   
.CLK(CLK), .CLR(CLR), .DI(DI_2), .DQ(SEM_2_0_DQ),
.WR(SEM_2_0_WE_2), .WR_EN(WR_EN_2_0_2), .WR_RDY(SEM_2_0_WR_2), .RD(SEM_2_0_RD_0 || SEM_0_0_RD_1),
.RD_EN(RD_EN_2_0_0 || RD_EN_2_0_1), .RD_RDY(SEM_2_0_RR), .REALASE(A_0[7] || A_1[7]));

semafor_unit SEM_2_1(		   
.CLK(CLK), .CLR(CLR), .DI(DI_2), .DQ(SEM_2_1_DQ),
.WR(SEM_2_1_WE_2), .WR_EN(WR_EN_2_1_2), .WR_RDY(SEM_2_1_WR_2), .RD(SEM_2_1_RD_0 || SEM_0_1_RD_1),
.RD_EN(RD_EN_2_1_0 || RD_EN_2_1_1), .RD_RDY(SEM_2_1_RR), .REALASE(A_0[7] || A_1[7]));

semafor_unit SEM_2_2(		   
.CLK(CLK), .CLR(CLR), .DI(DI_2), .DQ(SEM_2_2_DQ),
.WR(SEM_2_2_WE_2), .WR_EN(WR_EN_2_2_2), .WR_RDY(SEM_2_2_WR_2), .RD(SEM_2_2_RD_0 || SEM_0_2_RD_1),
.RD_EN(RD_EN_2_2_0 || RD_EN_0_2_1), .RD_RDY(SEM_2_2_RR), .REALASE(A_0[7] || A_1[7]));

semafor_unit SEM_2_3(		   
.CLK(CLK), .CLR(CLR), .DI(DI_2), .DQ(SEM_2_3_DQ),
.WR(SEM_2_3_WE_2), .WR_EN(WR_EN_2_3_2), .WR_RDY(SEM_2_3_WR_2), .RD(SEM_2_3_RD_0 || SEM_0_3_RD_1),
.RD_EN(RD_EN_2_3_0 || RD_EN_2_3_1), .RD_RDY(SEM_2_3_RR), .REALASE(A_0[7] || A_1[7]));


assign WT_0 = (SEM_0_0_WR_0 | SEM_0_1_WR_0 | SEM_0_2_WR_0 | SEM_0_3_WR_0) | 
((SEM_1_0_RR & RD_EN_1_0_0) | (SEM_1_1_RR & RD_EN_1_2_0) | (SEM_1_2_RR & RD_EN_1_2_0) | (SEM_1_3_RR & RD_EN_1_3_0) |				   // uzale¿niæ odczyt od adresu // ¿eby nie bylo problemu z wysokim stanem !zawsze!  
(SEM_2_0_RR & RD_EN_2_0_0) | (SEM_2_1_RR & RD_EN_2_1_0) | (SEM_2_2_RR & RD_EN_2_2_0) | (SEM_2_3_RR & RD_EN_2_3_0)) | 
SEM_NON_WT_0 ;	

assign WT_1 =  (SEM_1_0_WR_1 | SEM_1_1_WR_1 | SEM_1_2_WR_1 | SEM_1_3_WR_1) | 
((SEM_0_0_RR & RD_EN_0_0_1)  | (SEM_0_1_RR & RD_EN_0_1_1) | (SEM_0_2_RR & RD_EN_0_2_1) | (SEM_0_3_RR & RD_EN_0_3_1) | 
(SEM_2_0_RR & RD_EN_2_0_1) | (SEM_2_1_RR & RD_EN_2_1_1) | (SEM_2_2_RR & RD_EN_2_2_1) | (SEM_2_3_RR & RD_EN_2_3_1)) | 
 SEM_NON_WT_1 ;

assign WT_2	= (SEM_2_0_WR_2 | SEM_2_1_WR_2 | SEM_2_2_WR_2 | SEM_2_3_WR_2) |
((SEM_1_0_RR & RD_EN_1_0_2) | (SEM_1_1_RR & RD_EN_1_2_2) | (SEM_1_2_RR & RD_EN_1_2_2) | (SEM_1_3_RR & RD_EN_1_3_2) |
 (SEM_0_0_RR & RD_EN_0_0_2)  | (SEM_0_1_RR & & RD_EN_0_1_2) | (SEM_0_2_RR & & RD_EN_0_2_2) | (SEM_0_3_RR & RD_EN_0_3_2) ) |
SEM_NON_WT_2;





wire DQ_0_M = MEM[ADR_REG_0[9:0]];
wire DQ_1_M = MEM[ADR_REG_1[9:0]];
wire DQ_2_M = MEM[ADR_REG_2[9:0]];
 

always @(*) begin
	casex(ADR_REG_0)								 // odczyt bitowy	  1000 000- 0000
	12'b00xx_xxxx_xxxx: DQ_0 = DQ_0_M;
	12'b1000_x000_1000: DQ_0 = SEM_1_0_DQ;
	12'b1000_x000_1001: DQ_0 = SEM_1_1_DQ;
	12'b1000_x000_1010: DQ_0 = SEM_1_2_DQ;
	12'b1000_x000_1011: DQ_0 = SEM_1_3_DQ;

	12'b1000_x001_0000: DQ_0 = SEM_2_0_DQ;
	12'b1000_x001_0001: DQ_0 = SEM_2_1_DQ;
	12'b1000_x001_0010: DQ_0 = SEM_2_2_DQ;
	12'b1000_x001_0011: DQ_0 = SEM_2_3_DQ;
	default: DQ_0 = 1'bx;	
	endcase
end

always @(*) begin
	casex(ADR_REG_1)
	12'b00xx_xxxx_xxxx: DQ_1 = DQ_1_M;	 		// odczyt bajtowy	   1000_000-_1000
	12'b1000_x000_0000: DQ_1 = SEM_0_0_DQ;
	12'b1000_x000_0001: DQ_1 = SEM_0_1_DQ;
	12'b1000_x000_0010: DQ_1 = SEM_0_2_DQ;
	12'b1000_x000_0011: DQ_1 = SEM_0_3_DQ;

	12'b1000_x001_0000: DQ_1 = SEM_2_0_DQ;
	12'b1000_x001_0001: DQ_1 = SEM_2_1_DQ;
	12'b1000_x001_0010: DQ_1 = SEM_2_2_DQ;
	12'b1000_x001_0011: DQ_1 = SEM_2_3_DQ;
	default: DQ_1 = 1'bx;	
	endcase
end

always @(*) begin
	casex(ADR_REG_2)
	12'b00xx_xxxx_xxxx: DQ_2 = DQ_2_M;	 		// odczyt bajtowy	   1000_000-_1000
	12'b1000_x000_0000: DQ_2 = SEM_0_0_DQ;
	12'b1000_x000_0001: DQ_2 = SEM_0_1_DQ;
	12'b1000_x000_0010: DQ_2 = SEM_0_2_DQ;
	12'b1000_x000_0011: DQ_2 = SEM_0_3_DQ;

	12'b1000_x000_1000: DQ_2 = SEM_1_0_DQ;
	12'b1000_x000_1001: DQ_2 = SEM_1_1_DQ;
	12'b1000_x000_1010: DQ_2 = SEM_1_2_DQ;
	12'b1000_x000_1011: DQ_2 = SEM_1_3_DQ;
	default: DQ_2 = 1'bx;	
	endcase
end

/* synthesis translate_off */
integer i;
initial begin
	for( i = 0; i < 1024; i = i + 1)
		MEM[i] = 1'b0;
		MEM[0] = 1'b1;
		MEM[1] = 1'b1;
		MEM[2] = 1'b1;
		MEM[3] = 1'b1;
		MEM[4] = 1'b1;
		MEM[5] = 1'b1;
		MEM[16] = 1'b0;
		MEM[17] = 1'b0;
		MEM[18] = 1'b0;
		MEM[19] = 1'b0;
		MEM[20] = 1'b0;
		MEM[21] = 1'b0;
		MEM[22] = 1'b0;
		MEM[23] = 1'b0;
		MEM[24] = 1'b0;
		MEM[25] = 1'b0;
		MEM[26] = 1'b0;
		MEM[27] = 1'b0;
		MEM[28] = 1'b0;
		MEM[29] = 1'b0;
		MEM[30] = 1'b0;
		MEM[31] = 1'b0;
		MEM[55] = 1'b0;
end
/* synthesis translate_on */
	
endmodule