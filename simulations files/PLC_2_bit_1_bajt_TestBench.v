`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module PLC_2_bit_1_bajt_TestBench;
	
reg CLK, CLR;


//bit cpu 1//
wire [11:0]I_A_1;
wire [17:0]I_D_1;
wire [11:0]D_A_1;
wire D_I_1;
wire D_O_1;
wire D_OE_1;
wire D_WE_1;
wire D_RDY_1;

//bit cpu 2//
wire [11:0]I_A_2;
wire [17:0]I_D_2;
wire [11:0]D_A_2;
wire D_I_2;
wire D_O_2;
wire D_OE_2;
wire D_WE_2;
wire D_RDY_2;

//bajt cpu

wire [15:0]IW_A;
wire [23:0]IW_D;

wire [15:0]DW_A;
wire [31:0]DW_I;
wire [31:0]DW_O;

wire [11:0]DB_A;
wire DB_I;
wire DB_O;

wire DB_OE, DW_OE;
wire DB_WE, DW_WE;

wire DW_RDY;
wire DB_RDY;

wire [1:0]STATE;
//Connection for BIT_CPU_1
bit_cpu BIT_CPU_1(	   // podpiecia/wyprowadzenia dla proc bit
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
.STATE(STATE)
);

prog_bit_mem PROG_MEM_1(	  // podpiecia/wyprowadzenia dla prog mem
.CLK(CLK),
.A(I_A_1),
.WE(1'b0),
.DI(),
.DQ(I_D_1));

//Connection for BIT_CPU_2
bit_cpu BIT_CPU_2(	   // podpiecia/wyprowadzenia dla proc bit
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
.STATE(STATE)
);

prog_bit_mem_2 PROG_MEM_2(	  // podpiecia/wyprowadzenia dla prog mem
.CLK(CLK),
.A(I_A_2),
.WE(1'b0),
.DI(),
.DQ(I_D_2));

//Connection for WORD_CPU
word_cpu PROC_BAJT(
.CLK(CLK),
.CLR(CLR),
.DB_A(DB_A),
.DB_I(DB_I),
.DB_O(DB_O),
.DB_OE(DB_OE),
.DB_WE(DB_WE),
.DB_RDY(WT_1),
.IW_A(IW_A),
.IW_D(IW_D),
.DW_A(DW_A),
.DW_I(DW_I),
.DW_O(DW_O),
.DW_OE(DW_OE),
.DW_WE(DW_WE),
.DW_RDY(1'b1),
.DONE_W(DONE_1),
.STATE(STATE));

program_word_memory PROG_BAJT_MEM(
.CLK(CLK),
.A(IW_A),
.WE(1'b0),
.DI(),
.DQ(IW_D));

data_word_memory DATA_BAJT_MEM(
.CLK(CLK),
.D_WE(DW_WE),
.A(DW_A),
.DI(DW_O),
.DQ(DW_I));

//Connection for common bit_memory

semafor_bit_memory_3CPU SEM_MEM_C(
.CLK(CLK), .CLR(CLR),
.A_0(D_A_1), .DI_0(D_O_1), .DQ_0(D_I_1), .WE_0(D_WE_1 & WT_A_0), .OE_0(D_OE_1),.WT_0(D_RDY_1),	
.A_1(DB_A), .DI_1(DB_O), .DQ_1(DB_I), .WE_1(DB_WE & WT_A_1), .OE_1(DB_OE), .WT_1(DB_RDY),
.A_2(D_A_2), .DI_2(D_O_2), .DQ_2(D_I_2), .WE_2(D_WE_2 & WT_A_2), .OE_2(D_OE_2),.WT_2(D_RDY_2));

wire WT_A_0;
wire WT_A_1;
wire WT_A_2;

Arbiter_3 ARB(
.WE_0(D_WE_1),
.WE_1(DB_WE),
.WE_2(D_WE_2),
.WT_0(WT_A_0),	//bit_1
.WT_1(WT_A_1), // bajt
.WT_2(WT_A_2)); // bit_2

// data flow // arbiter && pamiec bitowa ?//
wire WT_0 = WT_A_0 && D_RDY_1;
wire WT_1 = WT_A_1 && DB_RDY;
wire WT_2 = WT_A_2 && D_RDY_2;

initial begin
	CLK= 1'b0;
	forever #5 CLK = ~CLK;
end

initial begin
	CLR = 1'b1;
	#20
	CLR = 1'b0;
end

endmodule