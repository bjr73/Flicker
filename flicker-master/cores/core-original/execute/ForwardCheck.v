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


module ForwardCheck (
	input [`SIZE_PHYSICAL_LOG-1:0] srcReg_i,
	input [`SIZE_DATA-1:0] srcData_i,

	input bypassValid0_i,		
	input [`SIZE_PHYSICAL_LOG-1:0] bypassTag0_i,
	input [`SIZE_DATA-1:0] bypassData0_i,
	input bypassValid1_i,		
	input [`SIZE_PHYSICAL_LOG-1:0] bypassTag1_i,
	input [`SIZE_DATA-1:0] bypassData1_i,
	input bypassValid2_i,		
	input [`SIZE_PHYSICAL_LOG-1:0] bypassTag2_i,
	input [`SIZE_DATA-1:0] bypassData2_i,
	input bypassValid3_i,		
	input [`SIZE_PHYSICAL_LOG-1:0] bypassTag3_i,
	input [`SIZE_DATA-1:0] bypassData3_i,
	input bypassValid4_i,		
	input [`SIZE_PHYSICAL_LOG-1:0] bypassTag4_i,
	input [`SIZE_DATA-1:0] bypassData4_i,
	input bypassValid5_i,		
	input [`SIZE_PHYSICAL_LOG-1:0] bypassTag5_i,
	input [`SIZE_DATA-1:0] bypassData5_i,

	output [`SIZE_DATA-1:0] dataOut_o
);	

 /* Defining wire and regs for combinational logic. */
 reg [`SIZE_DATA-1:0] dataOut;

 assign dataOut_o = dataOut;

always @(*)
begin:FORWARD_CHECK
	reg match0;
	reg match1;
	reg match2;
	reg match3;
	reg match4;
	reg match5;
	reg match;
 
	match0 = bypassValid0_i && (srcReg_i == bypassTag0_i);
	match1 = bypassValid1_i && (srcReg_i == bypassTag1_i);
	match2 = bypassValid2_i && (srcReg_i == bypassTag2_i);
	match3 = bypassValid3_i && (srcReg_i == bypassTag3_i);
	match4 = bypassValid4_i && (srcReg_i == bypassTag4_i);
	match5 = bypassValid5_i && (srcReg_i == bypassTag5_i);

	match  = match0 | match1 | match2 | match3 | match4 | match5;

	if(match)
	begin
		case({match5,match4,match3,match2,match1,match0})
			6'b000001: dataOut = bypassData0_i;
			6'b000010: dataOut = bypassData1_i;
			6'b000100: dataOut = bypassData2_i;
			6'b001000: dataOut = bypassData3_i;
			6'b010000: dataOut = bypassData4_i;
			6'b100000: dataOut = bypassData5_i;
		endcase
	end
	else
		dataOut = srcData_i;
end

endmodule
