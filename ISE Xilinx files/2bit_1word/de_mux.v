`timescale 1 ns / 1 ps



module de_mux(
	CLK,
	COUNT, WR_EN,
	IN, OUT);
	
	
	input CLK;
	input [3:0] COUNT;
	input WR_EN;  // ONE + 5 bit licznika
	input IN;
	output reg[15:0] OUT;
		
	always@(*) begin
		if(WR_EN) begin
		case(COUNT)
			4'd0: OUT[COUNT] = IN;
			4'd1: OUT[COUNT] = IN;
			4'd2: OUT[COUNT] = IN;
			4'd3: OUT[COUNT] = IN;
			4'd4: OUT[COUNT] = IN;
			4'd5: OUT[COUNT] = IN;
			4'd6: OUT[COUNT] = IN;
			4'd7: OUT[COUNT] = IN;
			4'd8: OUT[COUNT] = IN;
			4'd9: OUT[COUNT] = IN;
			4'd10: OUT[COUNT] = IN;
			4'd11: OUT[COUNT] = IN;
			4'd12: OUT[COUNT] = IN;
			4'd13: OUT[COUNT] = IN;
			4'd14: OUT[COUNT] = IN;
			4'd15: OUT[COUNT] = IN;
			default : OUT[COUNT] = IN;
			endcase

end
end

endmodule