`timescale 1 ns / 1 ps
`include "mplc_logic_il.v"

module Arbiter_3(
	WE_0, WE_1, WE_2,
	WT_0, WT_1, WT_2
	);


input WE_0;
input WE_1;
input WE_2;
output reg WT_0;
output reg WT_1;
output reg WT_2;
	

always @(*) begin

	if((WE_0 == 1'b1) && (WE_1 == 1'b0) && (WE_2 == 1'b0)) begin
		WT_0 = 1'b1;
		WT_1 = 1'b1;
		WT_2 = 1'b1;
	end
	else if((WE_0 == 1'b0) && (WE_1 == 1'b1) && (WE_2 == 1'b0)) begin
		WT_0 = 1'b1;
		WT_1 = 1'b1;
		WT_2 = 1'b1;
	end
	else if((WE_0 == 1'b0) && (WE_1 == 1'b0) && (WE_2 == 1'b1)) begin
		WT_0 = 1'b1;
		WT_1 = 1'b1;
		WT_2 = 1'b1;
	end
	else if((WE_0 == 1'b1) && (WE_1 == 1'b1) && (WE_2 == 1'b1)) begin
		WT_0 = 1'b1;
		WT_1 = 1'b0;
		WT_2 = 1'b0;
	end
	else if((WE_0 == 1'b1) && (WE_1 == 1'b0) && (WE_2 == 1'b1)) begin
		WT_0 = 1'b1;
		WT_1 = 1'b1;
		WT_2 = 1'b0;
	end
	else if((WE_0 == 1'b1) && (WE_1 == 1'b1) && (WE_2 == 1'b0)) begin
		WT_0 = 1'b1;
		WT_1 = 1'b0;
		WT_2 = 1'b1;
	end
	else if((WE_0 == 1'b0) && (WE_1 == 1'b1) && (WE_2 == 1'b1)) begin
		WT_0 = 1'b1;
		WT_1 = 1'b1;
		WT_2 = 1'b0;
	end
	else if((WE_0 == 1'b0) && (WE_1 == 1'b0) && (WE_2 == 1'b0)) begin
		WT_0 = 1'b1;
		WT_1 = 1'b1;
		WT_2 = 1'b1;
	end

end

endmodule
