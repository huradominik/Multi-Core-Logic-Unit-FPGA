`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module central_unit_3_RDZENIE (
CLK, CLR, A, WE, OUT, RUN);

parameter IA_W = 16;
parameter ID_W = 24;
parameter DA_W = 16;
parameter DW_W = 32;

parameter IA_B = 12; // Instruction adress word
parameter ID_B = 18; // Instruction data word
parameter DA_B = 12; // Data adress word

input CLK, CLR;
input RUN;
output [4:0] A;
input [15:0] WE;
output [15:0] OUT;

// Connections for WORD CPU //
wire [11:0] DB_A;
wire DB_I;
wire DB_O;

wire [15:0] IW_A;
wire [23:0] IW_D;

wire [15:0] DW_A;
wire [31:0] DW_I;
wire [31:0] DW_O;


wire DB_OE, DW_OE;
wire DB_WE, DW_WE;
wire DB_RDY;

wire D_WT_1;


// Connections for BIT CPU_1 //
wire [IA_B-1:0] I_A_1;
wire [ID_B-1:0] I_D_1;
wire [DA_B-1:0] D_A_1;
wire D_I_1;
wire D_O_1;
wire D_WE_1;
wire D_OE_1;
wire D_RDY_1;

// Connections for BIT CPU_2 //
wire [IA_B-1:0] I_A_2;
wire [ID_B-1:0] I_D_2;
wire [DA_B-1:0] D_A_2;
wire D_I_2;
wire D_O_2;
wire D_WE_2;
wire D_OE_2;
wire D_RDY_2;

//wire D_WT_0;
// Connections for Image Memory //
wire [4:0]A_IM;
wire DQ_IM;
// Cibbectuibs for DMA Channel //
wire ONE;
wire [4:0]COUNT_DMA;

	
// Connections for System Control //
wire [1:0]STATE;
wire [4:0] COUNT_SYS;
wire START;
wire DONE_0;
wire DONE_1;
wire DONE_2;
wire S_WE_1;
wire WR_IMAGE;

// arbiter
wire WT_A_0;
wire WT_A_1;
wire WT_A_2;


wire WT_0 = (WT_A_0 && D_RDY_1 && !DONE_0) && START;
wire WT_1 = (WT_A_1 && DB_RDY && !DONE_1) && START;
wire WT_2 = (WT_A_2 && D_RDY_2 && !DONE_2) && START;
wire DW_RDY = !DONE_1 && START;
		
wire B_OUT = (STATE[1] == 1'b1)? DQ_IM : D_O_1;
wire [11:0] A_IN = (STATE[1] == 1'b1)? {7'b0000000,STATE[0],COUNT_SYS[3:0]} : D_A_1;
wire DW_WE_1 = (STATE[1] == 1'b1)? WR_IMAGE : D_WE_1;

system_control SYS_CONTROL(	
.CLK(CLK),
.CLR(CLR),
.RUN(RUN),
.STATE(STATE),
.COUNT(COUNT_SYS),
.START(START),
.S_WE_1(S_WE_1),
.WR_IMAGE(WR_IMAGE),
.A_0(I_A_1),
.A_1(IW_A),
.A_2(I_A_2),
.DONE_0(DONE_0),
.DONE_1(DONE_1),
.DONE_2(DONE_2));	
	
de_mux DE_MUX(
.CLK(CLK),
.COUNT(COUNT_DMA[3:0]),
.WR_EN(COUNT_DMA[4] & !ONE),
.IN(OUT_1),
.OUT(OUT));

DMA_channel DMA(
.CLK(CLK),
.CLR(CLR),
.STATE(STATE[0]),
.COUNT(COUNT_DMA),
.ONE(ONE));

Arbiter_3 ARB(
.WE_0(DW_WE_1),
.WE_1(DB_WE),
.WE_2(D_WE_2),
.WT_0(WT_A_0),	//bit_1
.WT_1(WT_A_1), // bajt
.WT_2(WT_A_2)); // bit_2

image_memory IMAGE_MEMORY(
.CLK(CLK),
.A_0(COUNT_DMA),
.DI_0(IN_1),
.DQ_0(OUT_1),
.WE_0(!COUNT_DMA[4] & STATE[0]),
.A_1({!STATE[1], COUNT_SYS[3:0]}),
.DI_1(D_I_1),
.DQ_1(DQ_IM),
.WE_1(S_WE_1));

semafor_bit_memory_3CPU SEM_MEM_C(
.CLK(CLK), .CLR(CLR),
.A_0(A_IN), .DI_0(B_OUT), .DQ_0(D_I_1), .WE_0(DW_WE_1 & WT_A_0), .OE_0(D_OE_1),.WT_0(D_RDY_1),	
.A_1(DB_A), .DI_1(DB_O), .DQ_1(DB_I), .WE_1(DB_WE & WT_A_1), .OE_1(DB_OE), .WT_1(DB_RDY),
.A_2(D_A_2), .DI_2(D_O_2), .DQ_2(D_I_2), .WE_2(D_WE_2 & WT_A_2), .OE_2(D_OE_2),.WT_2(D_RDY_2));

///Connection for BAJT CPU
program_word_memory USER_WORD_MEM(
.CLK(CLK),
.A(IW_A), 
.WE(1'b0), 
.DI(24'h0), 
.DQ(IW_D));

data_word_memory CPU_WORD_MEM(
.CLK(CLK),
.D_WE(DW_WE),
.A(DW_A),
.DI(DW_O),
.DQ(DW_I));

word_cpu CPU_WORD(
.CLK(CLK),
.CLR(CLR),
.DB_A(DB_A),
.DB_I(DB_I),
.DB_O(DB_O),
.DB_OE(DB_OE),
.DB_WE(DB_WE),
.DB_RDY(WT_1), // WT
.IW_A(IW_A),
.IW_D(IW_D),
.DW_A(DW_A),
.DW_I(DW_I),
.DW_O(DW_O),
.DW_WE(DW_WE),
.DW_RDY(DW_RDY),
.DONE_W(DONE_1),
.STATE(STATE));  /// ?



//Connection for CPU BIT 1
bit_cpu CPU_BIT_1(
.CLK(CLK),
.CLR(CLR),
.I_A(I_A_1),
.I_D(I_D_1),
.D_A(D_A_1),
.D_I(D_I_1),
.D_O(D_O_1),
.D_OE(D_OE_1),
.D_WE(D_WE_1),
.D_RDY(WT_0),
.DONE_B(DONE_0),
.STATE(STATE));	

prog_bit_mem USER_BIT_MEM_1(
.CLK(CLK), 
.A(I_A_1), 
.WE(1'b0), 
.DI(18'h0), 
.DQ(I_D_1));

//Connection for CPU BIT 2
bit_cpu CPU_BIT_2(
.CLK(CLK),
.CLR(CLR),
.I_A(I_A_2),
.I_D(I_D_2),
.D_A(D_A_2),
.D_I(D_I_2),
.D_O(D_O_2),
.D_OE(D_OE_2),
.D_WE(D_WE_2),
.D_RDY(WT_2),
.DONE_B(DONE_2),
.STATE(STATE));	// WT 	

prog_bit_mem_2 USER_BIT_MEM_2(
.CLK(CLK), 
.A(I_A_2), 
.WE(1'b0), 
.DI(18'h0), 
.DQ(I_D_2));







// data flow // arbiter && pamiec bitowa ?//
 


assign IN_1 = WE[COUNT_DMA[3:0]];
//assign WY = OUT;

	
endmodule 
