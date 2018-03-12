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

module BHR (
	input clk,
	input reset,
	input recoverFlag_i,
	input flagRecoverID_i,
	input stall_i,
	
	/*Inputs from Fetch 1*/
	input update_i,
	input dir_i,
	
	/*Inputs from Fetch 2*/
	input update_CP_i,
	input dir_CP_i,
	
	/*inputs from CtrlQueue*/
	input [`RETIRE_WIDTH-1:0]update_ret_i,
	input [`RETIRE_WIDTH-1:0]dir_ret_i,
	
	/*inputs from retired CtrlQueue for updates*/
	input update_upd_i,
	input dir_upd_i,
	
	output [`SIZE_CNT_TBL_LOG-1:0]bhr_o,
	output [`SIZE_CNT_TBL_LOG-1:0]bhr_CP_o,
	output [`SIZE_CNT_TBL_LOG-1:0]bhr_upd_o
	
	);
	
//Registers for 4 different BHRs
reg [`SIZE_CNT_TBL_LOG-1:0] bhr;
reg [`SIZE_CNT_TBL_LOG-1:0] bhr_CP;
reg [`SIZE_CNT_TBL_LOG-1:0] bhr_ret;
reg [`SIZE_CNT_TBL_LOG-1:0] bhr_upd;

reg [`SIZE_CNT_TBL_LOG-1:0]new_bhr;
reg [`SIZE_CNT_TBL_LOG-1:0]new_bhr_CP;
reg [`SIZE_CNT_TBL_LOG-1:0]new_bhr_ret;
reg [`SIZE_CNT_TBL_LOG-1:0]new_bhr_upd;

assign bhr_o = bhr;
assign bhr_CP_o = bhr_CP;
assign bhr_upd_o = bhr_upd;

always@(*)
begin
	new_bhr = bhr;
	casex({recoverFlag_i,flagRecoverID_i,update_i})
		3'b1xx:
		begin
			new_bhr = bhr_ret;
		end
		3'b01x:
		begin
			new_bhr = new_bhr_CP;
		end
		3'b001:
		begin
			new_bhr = (bhr>>1) | {dir_i,15'b0};
		end
	endcase
end

always@(*)
begin
	if(recoverFlag_i)
	begin
		new_bhr_CP = bhr_ret;	
	end
	else if (update_CP_i)
	begin
		new_bhr_CP = (bhr_CP>>1) | {dir_CP_i,15'b0};
	end
	else
	begin
		new_bhr_CP = bhr_CP;
	end
end

always@(*)
begin
	if(update_upd_i)
		new_bhr_upd = (bhr_upd>>1) | {dir_upd_i,15'b0};
	else
		new_bhr_upd = bhr_upd;
end

always@(*)
begin
	case(update_ret_i)
		4'b0000:
		begin
			new_bhr_ret = bhr_ret;
		end
		4'b0001:
		begin
			new_bhr_ret = (bhr_ret>>1) | {dir_ret_i[0],15'b0};
		end
		4'b0010:
		begin
			new_bhr_ret = (bhr_ret>>1) | {dir_ret_i[1],15'b0};
		end
		4'b0011:
		begin
			new_bhr_ret = (bhr_ret>>2) | {dir_ret_i[1],dir_ret_i[0],14'b0};
		end
		4'b0100:
		begin
			new_bhr_ret = (bhr_ret>>1) | {dir_ret_i[2],15'b0};
		end
		4'b0101:
		begin
			new_bhr_ret = (bhr_ret>>2) | {dir_ret_i[2],dir_ret_i[0],14'b0};
		end		
		4'b0110:
		begin
			new_bhr_ret = (bhr_ret>>2) | {dir_ret_i[2],dir_ret_i[1],14'b0};
		end
		4'b0111:
		begin
			new_bhr_ret = (bhr_ret>>3) | {dir_ret_i[2],dir_ret_i[1],dir_ret_i[0],13'b0};
		end
		4'b1000:
		begin
			new_bhr_ret = (bhr_ret>>1) | {dir_ret_i[3],15'b0};			
		end
		4'b1001:
		begin
			new_bhr_ret = (bhr_ret>>2) | {dir_ret_i[3],dir_ret_i[0],14'b0};
		end
		4'b1010:
		begin
			new_bhr_ret = (bhr_ret>>2) | {dir_ret_i[3],dir_ret_i[1],14'b0};
		end
		4'b1011:
		begin
			new_bhr_ret = (bhr_ret>>3) | {dir_ret_i[3],dir_ret_i[1],dir_ret_i[0],13'b0};
		end
		4'b1100:
		begin
			new_bhr_ret = (bhr_ret>>2) | {dir_ret_i[3],dir_ret_i[2],14'b0};
		end		
		4'b1101:
		begin
			new_bhr_ret = (bhr_ret>>3) | {dir_ret_i[3],dir_ret_i[2],dir_ret_i[0],13'b0};
		end		
		4'b1110:
		begin
			new_bhr_ret = (bhr_ret>>3) | {dir_ret_i[3],dir_ret_i[2],dir_ret_i[1],13'b0};
		end		
		4'b1111:
		begin
			new_bhr_ret = (bhr_ret>>4) | {dir_ret_i[3],dir_ret_i[2],dir_ret_i[1],dir_ret_i[0],12'b0};
		end		
	endcase
end

always@(posedge clk)
begin
	if(reset)
	begin
		bhr <= 0;
		bhr_CP <= 0;
	end
	else if(~stall_i|recoverFlag_i)
	begin
		bhr <= new_bhr;
		bhr_CP <= new_bhr_CP;
	end
end

always@(posedge clk)
begin
	if(reset)
	begin
		bhr_ret <= 0;
		bhr_upd <= 0;
	end
	else
	begin
		bhr_ret <= new_bhr_ret;
		bhr_upd <= new_bhr_upd;
	end
end

endmodule
