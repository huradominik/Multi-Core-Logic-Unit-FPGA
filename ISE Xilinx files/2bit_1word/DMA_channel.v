`timescale 1 ns / 1 ps

module DMA_channel(
	CLK, CLR,					   //STATE - w zale¿noœci czy wymieniamy dane ca³y czas czy tylko podczas programu u¿ytkownika 
	STATE, 				// sygnal pozwalaj¹cy na przes³anie danych blokowo
 	COUNT,
	ONE
	);
	
	input CLK, CLR;
	input STATE;
	output reg [4:0] COUNT;
	output reg ONE;	 // wykonanie jednokrotne przekazania danych
			
	always @(posedge CLK) begin
		if(CLR) begin 
			COUNT <= 5'd0;
			ONE <= 1'd0;
			end
		else if(STATE && (~&COUNT)) begin
			COUNT <= COUNT + 1'b1;
			ONE <= 1'b0;
				end
		else if (!STATE)begin
			COUNT <= 5'd0;
			end
		else if (COUNT == 5'b11111) begin
			ONE <= 1'b1;
		end	
	end					
endmodule
