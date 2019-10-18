`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module word_cpu(
	CLK, CLR,
	DB_A, DB_I, DB_O, DB_OE, DB_WE, DB_RDY,
	IW_A, IW_D,
	DW_A, DW_I, DW_O, DW_OE, DW_WE, DW_RDY,
	DONE_W, STATE
	);

//Parametry
parameter IA_W = 16;
parameter ID_W = 24;
parameter DA_W = 16;
parameter DW_W = 32;
// System
input CLK, CLR;
// Instrukcje
output [IA_W-1:0] IW_A;
input [ID_W-1:0] IW_D;			/// wyjscie z programu uzytkownika
//Data bit memory
output [IA_W-5:0]DB_A;
output DB_O;
input DB_I;
output DB_OE, DB_WE;
input DB_RDY;

input DONE_W;
input [1:0] STATE;
//Data word memory
output [DA_W-1:0] DW_A;
input [DW_W-1:0] DW_I;						//data word input	
output [DW_W-1:0] DW_O;					//data word output
output DW_OE, DW_WE;			// output enable, write enable do pamieci danych
input DW_RDY;


//Data flow control
reg [ID_W-1:0] IR_DAT, IR_EXE;
wire [7:0] IR_OPC = IR_EXE[ID_W-1:ID_W-8];


reg [IA_W-1:0] IP;
reg DW_OE, DW_WE; // redefinicje
reg DB_OE, DB_WE;

reg FLUSH, FLUSH_RQ, FLUSH_DY;
reg STALL;
reg JMP_EN;
reg [1:0] CLR_DY;


reg [15:0] IMM;
// Flagi
reg ZeroFlag, CarryFlag, CompFlag;

//Accumulator Word
reg [DW_W-1:0]CRW, CRW_D; 
reg CRW_EN;

//Accumulator bit
reg CRB, CRB_D, CRB_EN;


assign DW_O = CRW;
assign DB_O = CRB;
assign DW_A = IR_DAT[15:0];
assign DB_A = IR_DAT[11:0];
assign IW_A = IP;
wire [31:0]INW = (IR_OPC == `IA_LDI)? {16'd0,IMM} : CRW;

always @(posedge CLK) begin
	CLR_DY[1:0] <={CLR_DY[0], CLR};
	FLUSH_DY <= FLUSH_RQ;
	if(FLUSH)
		IR_DAT <= {`IA_NOP, 16'h0000};
	else begin
		if(~STALL)
			IR_DAT <= IW_D;
	end
	if(FLUSH | STALL)
		IR_EXE <= {`IA_NOP, 16'h0000};
	else
		IR_EXE <= IR_DAT;
		IMM	<= IR_DAT[ID_W-9:0];				// rejestr do adresowania natychmiastowego
	if(CLR_DY[0] || (STATE != 2'b01))
		IP <= {IA_W{1'b0}};
	else begin
		if(JMP_EN)
			IP <= IR_EXE[15:0];
		else begin
			if(STALL | FLUSH  | DONE_W)
				IP <= IP;	
			else
				IP <= IP + 1;
		end
	end
	
	if(CRW_EN)									
		CRW <= CRW_D;
	if(CRB_EN)
		CRB <= CRB_D;
		
end

always @(*) begin
	//ALU	
	CarryFlag = 1'b0;
	ZeroFlag = 1'b0;
	CompFlag = 1'b0;
	
	case(IR_OPC)
	`IA_LDW: CRW_D = DW_I;
	`IA_ADD: begin
			 	{CarryFlag, CRW_D} = DW_I + INW;
			 	CRB_D = CarryFlag;
			 end
	`IA_SUB: begin
			 	CRW_D = DW_I - INW;
			 	ZeroFlag = ~|(INW - DW_I);
			 	CRB_D = ZeroFlag;
			 end
	`IA_LDI: CRW_D = INW;	
	`IA_LDB: CRB_D = DB_I;
	`IA_MUL: begin
			 	CRW_D = INW[17:0] * DW_I[17:0];
			 	ZeroFlag = ~| (INW[17:0]* DW_I[17:0]);
			 	CRB_D = ZeroFlag;
			 end
	`IA_DIV: CRW_D = INW[17:0] / DW_I[17:0];
	
	`IA_EQ: begin
		if(INW == DW_I) begin
			CompFlag = 1'b1;
			CRB_D = CompFlag; // ????????????????????
		end
		else begin
			CompFlag = 1'b0;
			CRB_D = CompFlag;
			end
		end
	`IA_NEQ: begin
		if(INW != DW_I) begin
			CompFlag = 1'b1;
			CRB_D = CompFlag;
		end
		else begin
			CompFlag = 1'b0;
			CRB_D = CompFlag;
		end
		end
	`IA_GT: begin
		if(DW_I < INW) begin
			CompFlag = 1'b1;
			CRB_D = CompFlag;
		end
		else begin
			CompFlag = 1'b0;
			CRB_D = CompFlag;
		end
		end
	`IA_GE: begin
		if(DW_I <= INW) begin
			CompFlag = 1'b1;
			CRB_D = CompFlag;
		end
		else begin
			CompFlag = 1'b0;
			CRB_D = CompFlag;
		end
		end
	`IA_LT: begin
		if(DW_I > INW) begin
			CompFlag = 1'b1;
			CRB_D = CompFlag;
		end
		else begin
			CompFlag = 1'b0;
			CRB_D = CompFlag;
		end
		end
	`IA_LE: begin
		if(DW_I >= INW) begin
			CompFlag = 1'b1;
			CRB_D = CompFlag;
		end
		else begin
			CompFlag = 1'b0;
			CRB_D = CompFlag;
		end
		end		
			
	default: begin
			 	CRW_D = 32'dx;		
			 	CRB_D = 1'dx;
			 end
	endcase
	
	CRW_EN = 1'b0;
	CRB_EN = 1'b0;
	case(IR_OPC)		  // sterowanie przeplywem danych w akumulatorach 
		`IA_LDW,
		`IA_LDI:
				 CRW_EN = 1'b1;
		`IA_LDB: 
				 CRB_EN = 1'b1;		
		`IA_ADD,
		`IA_SUB,
		`IA_MUL,
		`IA_DIV: begin
				 CRW_EN = 1'b1;
		 		 CRB_EN = 1'b1;
				 end
		`IA_EQ, `IA_NEQ, `IA_GT,
		`IA_GE, `IA_LT, `IA_LE: begin
			CRW_EN = 1'b0;
			CRB_EN = 1'b1;
			end
		
		default: begin
				 CRW_EN = 1'b0;
				 CRB_EN = 1'b0;
		 		 end
	endcase
		
	// Data stage control
	
	DW_OE = 1'b0;
	DB_OE = 1'b0;
	DW_WE = 1'b0;
	DB_WE = 1'b0;
	STALL = 1'b0;	
	case(IR_DAT[23:16])		 // sterowanie pamiecia 
		`IA_LDW, `IA_ADD, `IA_SUB,		  // rozkazy pobrania wartosci z pamieci
		`IA_MUL, `IA_DIV, `IA_EQ,
		`IA_NEQ, `IA_GT, `IA_GE,
		`IA_LT, `IA_LE:
			if(~FLUSH_RQ) begin
				DW_OE = 1'b1;
				STALL = ~DW_RDY;
			end									
		`IA_LDB:
			if(~FLUSH_RQ) begin
				DB_OE = 1'b1;
				STALL = ~DB_RDY;
			end	
		`IA_LDI: if(~FLUSH_RQ) STALL = ~DW_RDY;				
		`IA_STW:
			if(~FLUSH_RQ) begin
				if(CRW_EN)
					STALL = 1'b1;
				else begin
					DW_WE = 1'b1;
					STALL = ~DW_RDY;
				end
			end
		`IA_STB:
	 		if(~FLUSH_RQ) begin
				if(CRB_EN)
					STALL = 1'b1;
				else begin
					DB_WE = 1'b1;
					STALL = ~DB_RDY;
				end
			end
			default: begin
				DW_WE = 1'b0;
				DB_WE = 1'b0;
				STALL = 1'b0;
			end
	endcase
	
	//Dataflow
	FLUSH_RQ = CLR_DY[0] | JMP_EN;
	FLUSH = FLUSH_RQ | FLUSH_DY;
	
	JMP_EN = 1'b0;
	case(IR_EXE[23:16])
		`IA_JMP:
			JMP_EN = 1'b1;
		`IA_JMPC:
			JMP_EN = CRB;
		`IA_JMPCN:
		JMP_EN = ~CRB;
		default: JMP_EN = 1'b0;
	endcase
	
	
/*synthesis translate_off*/
//initial begin
//	SP_Q = 4'd0;
//end
/*synthesis translate_on*/
		
end	


endmodule