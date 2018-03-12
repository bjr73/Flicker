/*******************************************************************************
#                        NORTH CAROLINA STATE UNIVERSITY
#
#                               FabScalar Project
#
# FabScalar Copyright (c) 2007-2011 by Niket K. Choudhary, Salil Wadhavkar,
# and Eric Rotenberg.  All Rights Reserved.
#
# This is a beta-release version.  It must not be redistributed at this time.
#
# Purpose: 
# Author:  FabGen
*******************************************************************************/

`timescale 1ns/100ps

module SRAM_16R8W_PIPE_NEXT(
	data0wr_i,
	data1wr_i,
	data2wr_i,
	data3wr_i,
	data4wr_i,
	data5wr_i,
	data6wr_i,
	data7wr_i,
		clk,
		reset,
	decoded_addr0_i,
	decoded_addr1_i,
	decoded_addr2_i,
	decoded_addr3_i,
	decoded_addr4_i,
	decoded_addr5_i,
	decoded_addr6_i,
	decoded_addr7_i,
	decoded_addr8_i,
	decoded_addr9_i,
	decoded_addr10_i,
	decoded_addr11_i,
	decoded_addr12_i,
	decoded_addr13_i,
	decoded_addr14_i,
	decoded_addr15_i,
	decoded_addr0wr_i,
	decoded_addr1wr_i,
	decoded_addr2wr_i,
	decoded_addr3wr_i,
	decoded_addr4wr_i,
	decoded_addr5wr_i,
	decoded_addr6wr_i,
	decoded_addr7wr_i,
	we0_i,
	we1_i,
	we2_i,
	we3_i,
	we4_i,
	we5_i,
	we6_i,
	we7_i,
	data0_o,
	data1_o,
	data2_o,
	data3_o,
	data4_o,
	data5_o,
	data6_o,
	data7_o,
	data8_o,
	data9_o,
	data10_o,
	data11_o,
	data12_o,
	data13_o,
	data14_o,
	data15_o,

	decoded_addr0_o,
	decoded_addr1_o,
	decoded_addr2_o,
	decoded_addr3_o,
	decoded_addr4_o,
	decoded_addr5_o,
	decoded_addr6_o,
	decoded_addr7_o,
	decoded_addr8_o,
	decoded_addr9_o,
	decoded_addr10_o,
	decoded_addr11_o,
	decoded_addr12_o,
	decoded_addr13_o,
	decoded_addr14_o,
	decoded_addr15_o,
	decoded_addr0wr_o,
	decoded_addr1wr_o,
	decoded_addr2wr_o,
	decoded_addr3wr_o,
	decoded_addr4wr_o,
	decoded_addr5wr_o,
	decoded_addr6wr_o,
	decoded_addr7wr_o,
	we0_o,
	we1_o,
	we2_o,
	we3_o,
	we4_o,
	we5_o,
	we6_o,
	we7_o
);

/* Parameters */
parameter SRAM_DEPTH = 64;
parameter SRAM_INDEX = 6;
parameter SRAM_WIDTH = 8;

	input [SRAM_WIDTH-1:0] data0wr_i;
	input [SRAM_WIDTH-1:0] data1wr_i;
	input [SRAM_WIDTH-1:0] data2wr_i;
	input [SRAM_WIDTH-1:0] data3wr_i;
	input [SRAM_WIDTH-1:0] data4wr_i;
	input [SRAM_WIDTH-1:0] data5wr_i;
	input [SRAM_WIDTH-1:0] data6wr_i;
	input [SRAM_WIDTH-1:0] data7wr_i;

 input clk; 
 input reset;
	input [SRAM_DEPTH-1:0] decoded_addr0_i;
	input [SRAM_DEPTH-1:0] decoded_addr1_i;
	input [SRAM_DEPTH-1:0] decoded_addr2_i;
	input [SRAM_DEPTH-1:0] decoded_addr3_i;
	input [SRAM_DEPTH-1:0] decoded_addr4_i;
	input [SRAM_DEPTH-1:0] decoded_addr5_i;
	input [SRAM_DEPTH-1:0] decoded_addr6_i;
	input [SRAM_DEPTH-1:0] decoded_addr7_i;
	input [SRAM_DEPTH-1:0] decoded_addr8_i;
	input [SRAM_DEPTH-1:0] decoded_addr9_i;
	input [SRAM_DEPTH-1:0] decoded_addr10_i;
	input [SRAM_DEPTH-1:0] decoded_addr11_i;
	input [SRAM_DEPTH-1:0] decoded_addr12_i;
	input [SRAM_DEPTH-1:0] decoded_addr13_i;
	input [SRAM_DEPTH-1:0] decoded_addr14_i;
	input [SRAM_DEPTH-1:0] decoded_addr15_i;
	input [SRAM_DEPTH-1:0] decoded_addr0wr_i;
	input [SRAM_DEPTH-1:0] decoded_addr1wr_i;
	input [SRAM_DEPTH-1:0] decoded_addr2wr_i;
	input [SRAM_DEPTH-1:0] decoded_addr3wr_i;
	input [SRAM_DEPTH-1:0] decoded_addr4wr_i;
	input [SRAM_DEPTH-1:0] decoded_addr5wr_i;
	input [SRAM_DEPTH-1:0] decoded_addr6wr_i;
	input [SRAM_DEPTH-1:0] decoded_addr7wr_i;
	input we0_i;
	input we1_i;
	input we2_i;
	input we3_i;
	input we4_i;
	input we5_i;
	input we6_i;
	input we7_i;
	output we0_o;
	output we1_o;
	output we2_o;
	output we3_o;
	output we4_o;
	output we5_o;
	output we6_o;
	output we7_o;
	output [SRAM_WIDTH-1:0] data0_o;
	output [SRAM_WIDTH-1:0] data1_o;
	output [SRAM_WIDTH-1:0] data2_o;
	output [SRAM_WIDTH-1:0] data3_o;
	output [SRAM_WIDTH-1:0] data4_o;
	output [SRAM_WIDTH-1:0] data5_o;
	output [SRAM_WIDTH-1:0] data6_o;
	output [SRAM_WIDTH-1:0] data7_o;
	output [SRAM_WIDTH-1:0] data8_o;
	output [SRAM_WIDTH-1:0] data9_o;
	output [SRAM_WIDTH-1:0] data10_o;
	output [SRAM_WIDTH-1:0] data11_o;
	output [SRAM_WIDTH-1:0] data12_o;
	output [SRAM_WIDTH-1:0] data13_o;
	output [SRAM_WIDTH-1:0] data14_o;
	output [SRAM_WIDTH-1:0] data15_o;
	output [SRAM_DEPTH-1:0] decoded_addr0_o;
	output [SRAM_DEPTH-1:0] decoded_addr1_o;
	output [SRAM_DEPTH-1:0] decoded_addr2_o;
	output [SRAM_DEPTH-1:0] decoded_addr3_o;
	output [SRAM_DEPTH-1:0] decoded_addr4_o;
	output [SRAM_DEPTH-1:0] decoded_addr5_o;
	output [SRAM_DEPTH-1:0] decoded_addr6_o;
	output [SRAM_DEPTH-1:0] decoded_addr7_o;
	output [SRAM_DEPTH-1:0] decoded_addr8_o;
	output [SRAM_DEPTH-1:0] decoded_addr9_o;
	output [SRAM_DEPTH-1:0] decoded_addr10_o;
	output [SRAM_DEPTH-1:0] decoded_addr11_o;
	output [SRAM_DEPTH-1:0] decoded_addr12_o;
	output [SRAM_DEPTH-1:0] decoded_addr13_o;
	output [SRAM_DEPTH-1:0] decoded_addr14_o;
	output [SRAM_DEPTH-1:0] decoded_addr15_o;
	output [SRAM_DEPTH-1:0] decoded_addr0wr_o;
	output [SRAM_DEPTH-1:0] decoded_addr1wr_o;
	output [SRAM_DEPTH-1:0] decoded_addr2wr_o;
	output [SRAM_DEPTH-1:0] decoded_addr3wr_o;
	output [SRAM_DEPTH-1:0] decoded_addr4wr_o;
	output [SRAM_DEPTH-1:0] decoded_addr5wr_o;
	output [SRAM_DEPTH-1:0] decoded_addr6wr_o;
	output [SRAM_DEPTH-1:0] decoded_addr7wr_o;
	reg [SRAM_WIDTH-1:0] sram [SRAM_DEPTH-1:0];
	reg [SRAM_WIDTH-1:0] data0_o;
	reg [SRAM_WIDTH-1:0] data1_o;
	reg [SRAM_WIDTH-1:0] data2_o;
	reg [SRAM_WIDTH-1:0] data3_o;
	reg [SRAM_WIDTH-1:0] data4_o;
	reg [SRAM_WIDTH-1:0] data5_o;
	reg [SRAM_WIDTH-1:0] data6_o;
	reg [SRAM_WIDTH-1:0] data7_o;
	reg [SRAM_WIDTH-1:0] data8_o;
	reg [SRAM_WIDTH-1:0] data9_o;
	reg [SRAM_WIDTH-1:0] data10_o;
	reg [SRAM_WIDTH-1:0] data11_o;
	reg [SRAM_WIDTH-1:0] data12_o;
	reg [SRAM_WIDTH-1:0] data13_o;
	reg [SRAM_WIDTH-1:0] data14_o;
	reg [SRAM_WIDTH-1:0] data15_o;
integer i,j;

 assign decoded_addr0_o = decoded_addr0_i;
 assign decoded_addr1_o = decoded_addr1_i;
 assign decoded_addr2_o = decoded_addr2_i;
 assign decoded_addr3_o = decoded_addr3_i;
 assign decoded_addr4_o = decoded_addr4_i;
 assign decoded_addr5_o = decoded_addr5_i;
 assign decoded_addr6_o = decoded_addr6_i;
 assign decoded_addr7_o = decoded_addr7_i;
 assign decoded_addr8_o = decoded_addr8_i;
 assign decoded_addr9_o = decoded_addr9_i;
 assign decoded_addr10_o = decoded_addr10_i;
 assign decoded_addr11_o = decoded_addr11_i;
 assign decoded_addr12_o = decoded_addr12_i;
 assign decoded_addr13_o = decoded_addr13_i;
 assign decoded_addr14_o = decoded_addr14_i;
 assign decoded_addr15_o = decoded_addr15_i;
 assign decoded_addr0wr_o = decoded_addr0wr_i;
 assign we0_o = we0_i;
 assign decoded_addr1wr_o = decoded_addr1wr_i;
 assign we1_o = we1_i;
 assign decoded_addr2wr_o = decoded_addr2wr_i;
 assign we2_o = we2_i;
 assign decoded_addr3wr_o = decoded_addr3wr_i;
 assign we3_o = we3_i;
 assign decoded_addr4wr_o = decoded_addr4wr_i;
 assign we4_o = we4_i;
 assign decoded_addr5wr_o = decoded_addr5wr_i;
 assign we5_o = we5_i;
 assign decoded_addr6wr_o = decoded_addr6wr_i;
 assign we6_o = we6_i;
 assign decoded_addr7wr_o = decoded_addr7wr_i;
 assign we7_o = we7_i;
/* Read operation */
always @(*)
begin

	data0_o = 0;
	data1_o = 0;
	data2_o = 0;
	data3_o = 0;
	data4_o = 0;
	data5_o = 0;
	data6_o = 0;
	data7_o = 0;
	data8_o = 0;
	data9_o = 0;
	data10_o = 0;
	data11_o = 0;
	data12_o = 0;
	data13_o = 0;
	data14_o = 0;
	data15_o = 0;
	for(j=0; j<SRAM_DEPTH; j=j+1)
	begin
		if(decoded_addr0_i[j])	data0_o = sram[j];
		if(decoded_addr1_i[j])	data1_o = sram[j];
		if(decoded_addr2_i[j])	data2_o = sram[j];
		if(decoded_addr3_i[j])	data3_o = sram[j];
		if(decoded_addr4_i[j])	data4_o = sram[j];
		if(decoded_addr5_i[j])	data5_o = sram[j];
		if(decoded_addr6_i[j])	data6_o = sram[j];
		if(decoded_addr7_i[j])	data7_o = sram[j];
		if(decoded_addr8_i[j])	data8_o = sram[j];
		if(decoded_addr9_i[j])	data9_o = sram[j];
		if(decoded_addr10_i[j])	data10_o = sram[j];
		if(decoded_addr11_i[j])	data11_o = sram[j];
		if(decoded_addr12_i[j])	data12_o = sram[j];
		if(decoded_addr13_i[j])	data13_o = sram[j];
		if(decoded_addr14_i[j])	data14_o = sram[j];
		if(decoded_addr15_i[j])	data15_o = sram[j];
	end

end

/* Write operation */
always @(posedge clk)
begin

	if(reset)
	begin
		for(i=`SIZE_RMT; i<SRAM_DEPTH; i=i+1)
		begin
			sram[i] <= 0;
		end
	end
	else
	begin
        for(i=0;i<SRAM_DEPTH;i=i+1)
        begin

		if(we0_i)
			if(decoded_addr0wr_i[i]) sram[i] <= data0wr_i;

		if(we1_i)
			if(decoded_addr1wr_i[i]) sram[i] <= data1wr_i;

		if(we2_i)
			if(decoded_addr2wr_i[i]) sram[i] <= data2wr_i;

		if(we3_i)
			if(decoded_addr3wr_i[i]) sram[i] <= data3wr_i;

		if(we4_i)
			if(decoded_addr4wr_i[i]) sram[i] <= data4wr_i;

		if(we5_i)
			if(decoded_addr5wr_i[i]) sram[i] <= data5wr_i;

		if(we6_i)
			if(decoded_addr6wr_i[i]) sram[i] <= data6wr_i;

		if(we7_i)
			if(decoded_addr7wr_i[i]) sram[i] <= data7wr_i;

	end
end
end

endmodule





