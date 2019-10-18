`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"


module bit_cpu(CLK, CLR, I_A, I_D, D_A, D_I, D_O, D_OE, D_WE, D_RDY,	DONE_B, STATE);

// Parametry

parameter IA_W = 12; // Instruction adress word
parameter ID_W = 18; // Instruction data word
parameter DA_W = 12; // Data adress word

input CLK, CLR;

// Instrukcje
output [IA_W-1:0] I_A;  // wejscie adresowe do pamieci uzytkownika
input [ID_W-1:0] I_D;		// dane pochodzace z pamieci uzytkownika (15:12 instrukcja 11:0 adres do pamieci data memory)

input DONE_B;
input [1:0]STATE;
// Blok danych we/wy
output [DA_W-1:0] D_A;	// adres pamieci danych
input D_I; 				// wejscie do LU z pamieci danych
output D_O;				// wyjscie zapisu danych do pamieci
output D_OE;			// Data output enable  NIEWYKORZYSTANE ale chyba cos do pamieci
output D_WE;			// Data write enable (mozliwosc wpisu do pamieci do ST)
input D_RDY;			// sygnal zezwolenia na odczyt z pamieci (jesli 0 to STALL = 1)

//Data flow control - kontrola przeplywu danych

reg [ID_W-1:0] IR_DAT, IR_EXE;   // rejestry do przetwarzania potokowego 
//wire [3:0] IR_OPC = IR_EXE[ID_W-1:ID_W-4];	// polaczenie z rejestru do LU - kodu instrukcji
wire [1:0] IR_MOD = IR_EXE[13:12];	// polaczenie z rejestru do LU - modyfikatora
reg [IA_W-1:0] IP;				// rejestry licznika rozkazow (obecny i poprzedni) 
reg D_OE, D_WE;			// data output enable // data write enable
reg FLUSH, FLUSH_RQ, FLUSH_DY;		// rejestry do potokowosci (do instrukcji JMP)
reg STALL;						// zatrzask (zatrzymanie programu w celu mozliwosci pobrania danej z pamieci danych)
reg JMP_EN;					// zeswolenie na skok
reg [1:0] CLR_DY;			// dwu krokowy clear

//modyfikator//
reg [3:0]STACK[3:0];
//reg [3:0]STACK_Q[3:0];
reg CR_MOD[3:0];	   	// 4 max liczba nawiasów
reg CR_MOD_O;
reg CR_MOD_C;

reg [3:0]licz;	  	// licznik do operandu
reg licz_o; // inkrementacja i dekrementacja enable

// Akumlator
reg CR, CR_D, CR_EN;		//	CR_EN zezwolenie na wpisanie LU do akumlatora (rejestr)



wire [3:0]IR_OPC = (IR_EXE[13:12] == 2'b10) ? STACK[licz] : IR_EXE[ID_W-1:ID_W-4];   // do IR_OPC wchodzi STACK_Q gdy jest ")" w IR_EXE
assign D_O = CR; 			// wyjscie acc wpiete do wyjscia ktore idzie do pamieci danych
assign D_A = IR_DAT[11:0]; 	// wyjscie do adresu pamieci danych z rejestru DATA (adres bloku pamieci danych)
assign I_A = IP;			// wyjsie z licznika programu do pamieci programu (adresowe) 
wire INP = (IR_EXE[13:12] == 2'b10)? CR_MOD[licz] : D_I;

//assign IP =

// sterowanie //
always @(posedge CLK) begin
	CLR_DY <= {CLR_DY[0], CLR};		// rejestr przesuwny dwu bitowy;
	FLUSH_DY <= FLUSH_RQ;
	if(FLUSH)
		IR_DAT <= {`I_NOP,`M_N, 12'h000};		// jesli flush to w rejestrze data nop
	else begin
		if(~STALL)
			IR_DAT <= I_D;					// jesli zatrzask = 0 to wpisuje dane z pamieci programu do rej DATA
	end										// jesli jest JMP to czyszcze 2 rejestry DATA i EXE
	if(FLUSH | STALL)
		IR_EXE <= {`I_NOP,`M_N, 12'h000};		// sygnal wysoki STALL zatrzymuje tylko do rej EXE
	else 
		IR_EXE <= IR_DAT;
	if(CLR_DY[0] || (STATE != 2'b01)) begin
		IP <= {IA_W{1'b0}};				 	// podczas clr licznik rozkazow ustawia sie na adres 0 programu uzytkownika	
		CR_MOD[0] <= 1'b0;				   // napisac w bloku niesyntezowalnym!!
		CR_MOD[1] <= 1'b0;
		CR_MOD[2] <= 1'b0;
		CR_MOD[3] <= 1'b0;
		STACK[0] <= 4'b0000;
		STACK[1] <= 4'b0000;
		STACK[2] <= 4'b0000;
		STACK[3] <= 4'b0000;
	end
	else begin
		if(JMP_EN)
			IP <= IR_EXE[11:0];				// jestli jmp_en to wpisuje wartosc adresu z rejestru EXE do licznika rozkazow
		else if(STALL | FLUSH | DONE_B)
				IP <= IP;				// jesli zatrzask to wpisuje jeden adres instrukcji wczesniej 
		else
				IP <= IP +1'b1;			// inkrementacja licznika rozkazow
	end
	
	if(CR_EN)
		CR <= CR_D;							// przepisanie wyniku LU do akumlatora dla CR_EN wysokiego
	
	if(licz_o) begin
		STACK[licz] <= IR_DAT[17:14];
		CR_MOD[licz] <= CR_D;
	//	licz <= licz + 1'b1;
	end
	
end

always @(*) begin
	//ALU  uklad asynchroniczny
	case (IR_OPC) 				// poczaczenie z rej EXE do LU
	`I_LD:   CR_D = (IR_MOD == 2'b01)? CR_D :  INP;
	`I_LDN:  CR_D = (IR_MOD == 2'b01)? CR_D : ~INP;
	`I_OR:   CR_D = (IR_MOD == 2'b01)? CR_D : (CR | INP);
	`I_ORN:  CR_D = (IR_MOD == 2'b01)? CR_D : (CR | ~INP);
	`I_AND:  CR_D = (IR_MOD == 2'b01)? CR_D : (CR & INP);
	`I_ANDN: CR_D = (IR_MOD == 2'b01)? CR_D : (CR & ~INP);
	`I_XOR:	 CR_D = (IR_MOD == 2'b01)? CR_D : (CR ^ INP);
	`I_XORN: CR_D = (IR_MOD == 2'b01)? CR_D : (CR ^ ~INP);
	default: CR_D = 1'bx;	  
	endcase
	
	CR_EN = 1'b0;
	case(IR_OPC)  // nie zezwala na przepisanie wartosci do CR gdy jest "("	
		`I_LD, `I_LDN, `I_OR, `I_ORN,
		`I_AND,`I_ANDN, `I_XOR, `I_XORN:
		CR_EN = 1'b1;
	default: CR_EN = 1'b0;
	endcase
	
	// Data stage control
	D_OE = 1'b0;				
	D_WE = 1'b0;
	STALL = 1'b0;
	case(IR_DAT[17:14])
		`I_LD, `I_LDN, `I_OR, `I_ORN,
		`I_AND,`I_ANDN, `I_XOR, `I_XORN: begin
			if(~FLUSH_RQ) begin
				D_OE = 1'b1;				// data output enable  - mozliwosc pobrania zmiennej z pamieci
				STALL = ~D_RDY;
			end
		end
		`I_ST, `I_STN:
		if(~FLUSH_RQ) begin
			if(CR_EN)			  	// podczas zapisu wprowadzam jednego NOP zeby przeniesc wartosc z acc do D_O
				STALL = 1'b1;
			else begin				// nastepny rozkaz przenosi instrukcje zapisu jeszcze raz i wpisywana jest wartosc D_O do pamieci
				D_WE = 1'b1;
				STALL = ~D_RDY;
			end
		end
		default: begin
			STALL = 1'b0;
			D_WE = 1'b0;
			D_OE = 1'b0;
			end
	endcase

	licz_o = 1'b0;
   case (IR_DAT[13:12])
	   `M_O: begin
	   licz_o = 1'b1;	// nawias otwarty
	   end
	   `M_C:// nawias zamkniety	
	   licz = licz - 1'b1;
	   default:   licz_o = 1'bx;
	endcase   
	// modyfikatory
	CR_MOD_O = 1'b0;
	CR_MOD_C = 1'b0;
	case(IR_EXE[13:12])
		`M_O: begin
		CR_MOD_O = 1'b1;
		licz = licz + 1'b1;
		end

		default: begin
			CR_MOD_O = 1'bx;

		end
	endcase
	
   
	// Datflow
	
// JMP

JMP_EN = 1'b0;
case(IR_EXE[17:14])
`I_JMP:
	JMP_EN = 1'b1;
`I_JMPC:
	JMP_EN = CR;
`I_JMPCN:
JMP_EN = ~CR;
default: JMP_EN = 1'b0;
endcase


// Pipe flushing			   
	
FLUSH_RQ = CLR_DY[0] | JMP_EN;
FLUSH = FLUSH_RQ | FLUSH_DY;

end						
endmodule