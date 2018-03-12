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

module ActiveList(
		   input clk,
		   input reset,
		   input backEndReady_i,			   

                   /* Active List packet contains following information:
			(6) isInstLoad        "bit-2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG"
			(5) isInst Store      "bit-1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG"	       	
			(4) Program Counter   "bits-`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1"
			(3) Logical Dest      "bits-`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:2*`SIZE_PHYSICAL_LOG+1"
			(2) Physical Dest     "bits-2*`SIZE_PHYSICAL_LOG:`SIZE_PHYSICAL_LOG+1"
			(1) Old Physical Dest "bits-`SIZE_PHYSICAL_LOG:1"
			(0) Valid Dest        "bit-0"
		   */ 
      		   input [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] alPacket0_i,
      		   input [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] alPacket1_i,
      		   input [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] alPacket2_i,
      		   input [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] alPacket3_i,
		   input validFU0_i,
 		   input [`SIZE_PC-1:0] computedAddr0_i,	
		   input [`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:0] ctrlFU0_i,
		   input validFU1_i,
 		   input [`SIZE_PC-1:0] computedAddr1_i,	
		   input [`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:0] ctrlFU1_i,
		   input validFU2_i,
 		   input [`SIZE_PC-1:0] computedAddr2_i,	
		   input [`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:0] ctrlFU2_i,
		   input validFU3_i,
 		   input [`SIZE_PC-1:0] computedAddr3_i,	
		   input [`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:0] ctrlFU3_i,
		   input validFU4_i,
 		   input [`SIZE_PC-1:0] computedAddr4_i,	
		   input [`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:0] ctrlFU4_i,
		   input validFU5_i,
 		   input [`SIZE_PC-1:0] computedAddr5_i,	
		   input [`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:0] ctrlFU5_i,

		   input [`SIZE_ACTIVELIST_LOG:0]   ldViolationPacket_i,		

                   output [`SIZE_ACTIVELIST_LOG-1:0] activeListId0_o,
                   output [`SIZE_ACTIVELIST_LOG-1:0] activeListId1_o,
                   output [`SIZE_ACTIVELIST_LOG-1:0] activeListId2_o,
                   output [`SIZE_ACTIVELIST_LOG-1:0] activeListId3_o,

		   output [`SIZE_ACTIVELIST_LOG:0] activeListCnt_o,

		   output commitValid0_o,
		   output [`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG-1:0] commitPacket0_o,
 		   output commitStore0_o,
 		   output commitLoad0_o,
		   output commitValid1_o,
		   output [`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG-1:0] commitPacket1_o,
 		   output commitStore1_o,
 		   output commitLoad1_o,
		   output commitValid2_o,
		   output [`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG-1:0] commitPacket2_o,
 		   output commitStore2_o,
 		   output commitLoad2_o,
		   output commitValid3_o,
		   output [`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG-1:0] commitPacket3_o,
 		   output commitStore3_o,
 		   output commitLoad3_o,

		   output [`RETIRE_WIDTH-1:0] commitCti_o,

                   output recoverFlag_o,
		   output [`SIZE_PC-1:0] recoverPC_o,	

                   output exceptionFlag_o,
		   output [`SIZE_PC-1:0] exceptionPC_o,

       input [2:0] frontEndWidth_i

);

//Flicker
reg [3:0] frontEndMask;
reg [1:0] front;
always@(*)
begin
   frontEndMask = 4'd0;
   case(frontEndWidth_i)
     3'd4: begin
	frontEndMask = 4'b1111;
     end
     3'd3: begin
	frontEndMask = 4'b1110;
     end
     3'd2: begin
	frontEndMask = 4'b1100;
     end
     3'd1: begin
	frontEndMask = 4'b1000;
     end
   endcase

end 	

always@(*)
begin
 case(frontEndWidth_i)
     3'd4: begin
      front=2'd3;

     end
     3'd3: begin
      front=2'd2;

     end
     3'd2: begin
      front=2'd1;

     end
     3'd1: begin
      front=2'd0;
          end
     default: begin
       front=2'd3;
       
     end
endcase 
end


/* Following declares the Active head pointer and tail pointer.
*/
reg [`SIZE_ACTIVELIST_LOG-1:0] 			headAL;
reg [`SIZE_ACTIVELIST_LOG-1:0] 			tailAL;
reg [`SIZE_ACTIVELIST_LOG:0]			activeListCount;

reg 						recoverFlag;
reg [`SIZE_PC-1:0]                     		recoverPC;
reg 						mispredFlag;
reg [`SIZE_PC-1:0]                     		targetPC;
reg 						exceptionFlag;
reg [`SIZE_PC-1:0]                     		exceptionPC;



/* Following declares Wires and regs for the combinatorial logic.
*/
reg [`SIZE_ACTIVELIST_LOG-1:0] 		       tailAddr0;
reg [`SIZE_ACTIVELIST_LOG-2:0]                 tailAddr0_1;
reg [`SIZE_ACTIVELIST_LOG-3:0]                 tailAddr0_2;
reg [`SIZE_ACTIVELIST_LOG-4:0]                 tailAddr0_3;

reg [`SIZE_ACTIVELIST_LOG-1:0] 		       tailAddr1;
reg [`SIZE_ACTIVELIST_LOG-2:0]                 tailAddr1_1;
reg [`SIZE_ACTIVELIST_LOG-3:0]                 tailAddr1_2;
reg [`SIZE_ACTIVELIST_LOG-4:0]                 tailAddr1_3;

reg [`SIZE_ACTIVELIST_LOG-1:0] 		       tailAddr2;
reg [`SIZE_ACTIVELIST_LOG-2:0]                 tailAddr2_1;
reg [`SIZE_ACTIVELIST_LOG-3:0]                 tailAddr2_2;
reg [`SIZE_ACTIVELIST_LOG-4:0]                 tailAddr2_3;

reg [`SIZE_ACTIVELIST_LOG-1:0] 		       tailAddr3;
reg [`SIZE_ACTIVELIST_LOG-2:0]                 tailAddr3_1;
reg [`SIZE_ACTIVELIST_LOG-3:0]                 tailAddr3_2;
reg [`SIZE_ACTIVELIST_LOG-4:0]                 tailAddr3_3;

reg [`SIZE_ACTIVELIST_LOG-1:0] 		       headAddr0;
reg [`SIZE_ACTIVELIST_LOG-2:0]                 headAddr0_1;
reg [`SIZE_ACTIVELIST_LOG-3:0]                 headAddr0_2;
reg [`SIZE_ACTIVELIST_LOG-4:0]                 headAddr0_3;

reg [`SIZE_ACTIVELIST_LOG-1:0] 		       headAddr1;
reg [`SIZE_ACTIVELIST_LOG-2:0]                 headAddr1_1;
reg [`SIZE_ACTIVELIST_LOG-3:0]                 headAddr1_2;
reg [`SIZE_ACTIVELIST_LOG-4:0]                 headAddr1_3;

reg [`SIZE_ACTIVELIST_LOG-1:0] 		       headAddr2;
reg [`SIZE_ACTIVELIST_LOG-2:0]                 headAddr2_1;
reg [`SIZE_ACTIVELIST_LOG-3:0]                 headAddr2_2;
reg [`SIZE_ACTIVELIST_LOG-4:0]                 headAddr2_3;

reg [`SIZE_ACTIVELIST_LOG-1:0] 		       headAddr3;
reg [`SIZE_ACTIVELIST_LOG-2:0]                 headAddr3_1;
reg [`SIZE_ACTIVELIST_LOG-3:0]                 headAddr3_2;
reg [`SIZE_ACTIVELIST_LOG-4:0]                 headAddr3_3;


wire [`SIZE_ACTIVELIST_LOG-1:0] 		fuAddr0;
wire 						fuEn0;
wire [`WRITEBACK_FLAGS-1:0] 			fuData0;
wire [`SIZE_ACTIVELIST_LOG-1:0] 		fuAddr1;
wire 						fuEn1;
wire [`WRITEBACK_FLAGS-1:0] 			fuData1;
wire [`SIZE_ACTIVELIST_LOG-1:0] 		fuAddr2;
wire 						fuEn2;
wire [`WRITEBACK_FLAGS-1:0] 			fuData2;
wire [`SIZE_ACTIVELIST_LOG-1:0] 		fuAddr3;
wire 						fuEn3;
wire [`WRITEBACK_FLAGS-1:0] 			fuData3;
wire [`SIZE_ACTIVELIST_LOG-1:0] 		fuAddr4;
wire 						fuEn4;
wire [`WRITEBACK_FLAGS-1:0] 			fuData4;
wire [`SIZE_ACTIVELIST_LOG-1:0] 		fuAddr5;
wire 						fuEn5;
wire [`WRITEBACK_FLAGS-1:0] 			fuData5;

wire 						ctrlMispredict;
wire 						ctrlMispredict_f;
wire [`SIZE_ACTIVELIST_LOG-1:0]			mispredictEntry;

reg [`SIZE_ACTIVELIST_LOG:0]			activeListCount_f;

reg [`SIZE_ACTIVELIST_LOG-1:0] 			newheadAL;
reg [`SIZE_ACTIVELIST_LOG-2:0] 			newheadAL1;
reg [`SIZE_ACTIVELIST_LOG-3:0] 			newheadAL2;
reg [`SIZE_ACTIVELIST_LOG-4:0] 			newheadAL3;

reg [`SIZE_ACTIVELIST_LOG-1:0] 			tailAL_f;
reg [`SIZE_ACTIVELIST_LOG-2:0] 			tailAL_f1;
reg [`SIZE_ACTIVELIST_LOG-3:0] 			tailAL_f2;
reg [`SIZE_ACTIVELIST_LOG-4:0] 			tailAL_f3;
reg [`COMMIT_WIDTH-1:0]				totalCommit;

reg [`COMMIT_WIDTH-1:0]				commitVector;
reg 						commitValid0;
reg [`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG-1:0] 	commitPacket0;
reg 						commitStore0;
reg 						commitLoad0;
reg						commitFission0;

reg 						commitValid1;
reg [`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG-1:0] 	commitPacket1;
reg 						commitStore1;
reg 						commitLoad1;
reg						commitFission1;

reg 						commitValid2;
reg [`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG-1:0] 	commitPacket2;
reg 						commitStore2;
reg 						commitLoad2;
reg						commitFission2;

reg 						commitValid3;
reg [`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG-1:0] 	commitPacket3;
reg 						commitStore3;
reg 						commitLoad3;
reg						commitFission3;

reg [`RETIRE_WIDTH-1:0]				commitCti;

wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl0;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl1;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl2;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl3;

wire [`WRITEBACK_FLAGS-1:0] 			ctrlAl0;
wire [`WRITEBACK_FLAGS-1:0] 			ctrlAl1;
wire [`WRITEBACK_FLAGS-1:0] 			ctrlAl2;
wire [`WRITEBACK_FLAGS-1:0] 			ctrlAl3;

wire [`BRANCH_TYPE-1:0]				ctiType0;
wire [`BRANCH_TYPE-1:0]				ctiType1;
wire [`BRANCH_TYPE-1:0]				ctiType2;
wire [`BRANCH_TYPE-1:0]				ctiType3;
reg [`SIZE_RAS_LOG-1:0] 			tos3;

wire						violateBit0;
wire						violateBit1;
wire						violateBit2;
wire						violateBit3;

wire 						mispredictBit0_f;
wire 						mispredictBit1_f;
wire 						mispredictBit2_f;
wire 						mispredictBit3_f;

wire						violateBit0_f;
wire						violateBit1_f;
wire						violateBit2_f;
wire						violateBit3_f;

wire						exceptionBit0_f;
wire						exceptionBit1_f;
wire						exceptionBit2_f;
wire						exceptionBit3_f;

wire [`SIZE_PC-1:0]				targetAddr0;
wire [`SIZE_PC-1:0]				targetAddr1;
wire [`SIZE_PC-1:0]				targetAddr2;
wire [`SIZE_PC-1:0]				targetAddr3;

`ifdef VERIFY
wire [`SIZE_PC-1:0] 				commitPC0;
wire [`SIZE_PC-1:0] 				commitPC1;
wire [`SIZE_PC-1:0] 				commitPC2;
wire [`SIZE_PC-1:0] 				commitPC3;

reg						commitVerify0;
reg						commitVerify1;
reg						commitVerify2;
reg						commitVerify3;

integer 					commitCount;
integer 					commitCount_f;

integer 					commitCnt0;
integer 					commitCnt1;
integer 					commitCnt2;
integer 					commitCnt3;
`endif

/************************************************************************************ 
   Following instantiates RAM modules for Active List. 2 seperate RAM modules have
   been instantisted each for static and control information associated with each
   instruction.
   Modules "activeList" and "ctrlActiveList" have different Read/Write ports 
   requirements. "ctrlActiveList" needs additional write ports to write the control
   information when an instruction has completed execution.
************************************************************************************/

reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr0_sram0;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr0_sram1;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr0_sram2;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr0_sram3;

reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr1_sram0;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr1_sram1;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr1_sram2;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr1_sram3;

reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr2_sram0;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr2_sram1;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr2_sram2;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr2_sram3;

reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr3_sram0;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr3_sram1;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr3_sram2;
reg [`SIZE_ACTIVELIST_LOG-1:0]  headAddr3_sram3;

reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr0_sram0;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr0_sram1;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr0_sram2;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr0_sram3;

reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr1_sram0;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr1_sram1;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr1_sram2;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr1_sram3;

reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr2_sram0;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr2_sram1;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr2_sram2;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr2_sram3;

reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr3_sram0;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr3_sram1;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr3_sram2;
reg [`SIZE_ACTIVELIST_LOG-1:0]  tailAddr3_sram3;

wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl0_s0;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl1_s0;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl2_s0;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl3_s0;

wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl0_s1;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl1_s1;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl2_s1;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl3_s1;

wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl0_s2;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl1_s2;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl2_s2;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl3_s2;

wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl0_s3;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl1_s3;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl2_s3;
wire [2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:0] dataAl3_s3;


reg                             sram0_a0_wen;
reg                             sram0_a1_wen;
reg                             sram0_a2_wen;
reg                             sram0_a3_wen;
reg                             sram1_a0_wen;
reg                             sram1_a1_wen;
reg                             sram1_a2_wen;
reg                             sram1_a3_wen;

reg                             sram2_a0_wen;
reg                             sram2_a1_wen;
reg                             sram2_a2_wen;
reg                             sram2_a3_wen;
reg                             sram3_a0_wen;
reg                             sram3_a1_wen;
reg                             sram3_a2_wen;
reg                             sram3_a3_wen;


reg       [1:0]                 data0_sel;
reg       [1:0]                 data1_sel;
reg       [1:0]                 data2_sel;
reg       [1:0]                 data3_sel;

always@(*) begin
if (headAddr0 >=96  && headAddr0 < 128 ) begin 
    headAddr0_sram0 = headAddr0;
//    headAddr0_sram1 = headAddr0 - 96;
//    headAddr0_sram2 = headAddr0 - 96;
    headAddr0_sram3 = headAddr0 - 96;
    data0_sel       = 3;
end
else if (headAddr0 >=64  && headAddr0 <= 95 ) begin 
    headAddr0_sram0 = headAddr0;
    headAddr0_sram2 = headAddr0 - 64;
    data0_sel       = 2;
end
else if (headAddr0 >=32  && headAddr0 <= 63 ) begin 
    headAddr0_sram0 = headAddr0;
    headAddr0_sram1 = headAddr0 - 32;
    data0_sel       = 1;
end
else begin
    headAddr0_sram0 = headAddr0;
    headAddr0_sram1 = headAddr0;
    data0_sel       = 0;
end
if (headAddr1 >=96 && headAddr1 < 128 ) begin 
    headAddr1_sram0 = headAddr1;
    headAddr1_sram3 = headAddr1 - 96;
    data1_sel       = 3;
end
else if (headAddr1 >= 64 && headAddr1 <= 95 ) begin 
    headAddr1_sram0 = headAddr1;
    headAddr1_sram2 = headAddr1 - 64;
    data1_sel       = 2;

end
else if (headAddr1 >= 32 && headAddr1 <= 63 ) begin 
    headAddr1_sram0 = headAddr1;
    headAddr1_sram1 = headAddr1 - 32;
    data1_sel       = 1;

end

else begin
    headAddr1_sram0 = headAddr1;
    headAddr1_sram1 = headAddr1;
    data1_sel       = 0;
end
if(headAddr2 >= 96 && headAddr2 < 128 ) begin 
    headAddr2_sram0 = headAddr2;
    headAddr2_sram3 = headAddr2 - 96;
    data2_sel       = 3;
end
else if(headAddr2 >= 64 && headAddr2 <= 95 ) begin 
    headAddr2_sram0 = headAddr2;
    headAddr2_sram2 = headAddr2 - 64;
    data2_sel       = 2;
end
else if (headAddr2 >= 32 && headAddr2 <= 63 ) begin 
    headAddr2_sram0 = headAddr2;
    headAddr2_sram1 = headAddr2 - 32;
    data2_sel       = 1;
end

else begin
    headAddr2_sram0 = headAddr2;
    headAddr2_sram1 = headAddr2;
    data2_sel       = 0;

end
if (headAddr3 >= 96 && headAddr3 < 128 ) begin 
    headAddr3_sram0 = headAddr3;
    headAddr3_sram3 = headAddr3 - 96;
    data3_sel       = 3;

end
else if (headAddr3 >= 64 && headAddr3 <= 95 ) begin 
    headAddr3_sram0 = headAddr3;
    headAddr3_sram2 = headAddr3 - 64;
    data3_sel       = 2;

end
else if (headAddr3 >= 32 && headAddr3 <= 63 ) begin 
    headAddr3_sram0 = headAddr3;
    headAddr3_sram1 = headAddr3 - 32;
    data3_sel       = 1;

end

else begin
    headAddr3_sram0 = headAddr3;
    headAddr3_sram1 = headAddr3;
    data3_sel       = 0;

end
if (tailAddr0 >= 96 && tailAddr0 < 128 ) begin
    tailAddr0_sram0  = tailAddr0;
    tailAddr0_sram3  = tailAddr0 - 96;
    sram0_a0_wen         = 0;
    sram1_a0_wen         = 0;
    sram2_a0_wen         = 0;
    sram3_a0_wen         = 1;
end
else if (tailAddr0 >= 64 && tailAddr0 <= 95 ) begin
    tailAddr0_sram0  = tailAddr0;
    tailAddr0_sram2  = tailAddr0 - 64;
    sram0_a0_wen         = 0;
    sram1_a0_wen         = 0;
    sram2_a0_wen         = 1;
    sram3_a0_wen         = 0;
end
else if (tailAddr0 >= 32 && tailAddr0 <= 63 ) begin
    tailAddr0_sram0  = tailAddr0;
    tailAddr0_sram1  = tailAddr0 - 32;
    sram0_a0_wen         = 0;
    sram1_a0_wen         = 1;
    sram2_a0_wen         = 0;
    sram3_a0_wen         = 0;
end

else begin
    tailAddr0_sram0  = tailAddr0;
    tailAddr0_sram1  = tailAddr0;
    sram0_a0_wen         = 1;
    sram1_a0_wen         = 0;
    sram2_a0_wen         = 0;
    sram3_a0_wen         = 0;
end
if (tailAddr1 >= 96 && tailAddr1 < 128 ) begin
    tailAddr1_sram0  = tailAddr1;
    tailAddr1_sram3  = tailAddr1 - 96;
    sram0_a1_wen         = 0;
    sram1_a1_wen         = 0;
    sram2_a1_wen         = 0;
    sram3_a1_wen         = 1;
end
else if (tailAddr1 >= 64 && tailAddr1 <= 95 ) begin
    tailAddr1_sram0  = tailAddr1;
    tailAddr1_sram2  = tailAddr1 - 64;
    sram0_a1_wen         = 0;
    sram1_a1_wen         = 0;
    sram2_a1_wen         = 1;
    sram3_a1_wen         = 0;
end
else if (tailAddr1 >= 32 && tailAddr1 <= 63 ) begin
    tailAddr1_sram0  = tailAddr1;
    tailAddr1_sram1  = tailAddr1 - 32;
    sram0_a1_wen         = 0;
    sram1_a1_wen         = 1;
    sram2_a1_wen         = 0;
    sram3_a1_wen         = 0;
end
else begin
    tailAddr1_sram0  = tailAddr1;
    tailAddr1_sram1  = tailAddr1;
    sram0_a1_wen         = 1;
    sram1_a1_wen         = 0;
    sram2_a1_wen         = 0;
    sram3_a1_wen         = 0;
end
if (tailAddr2 >= 96 && tailAddr2 < 128 ) begin
    tailAddr2_sram0  = tailAddr2;
    tailAddr2_sram3  = tailAddr2 - 96;
    sram0_a2_wen         = 0;
    sram1_a2_wen         = 0;
    sram2_a2_wen         = 0;
    sram3_a2_wen         = 1;
end
else if(tailAddr2 >= 64 && tailAddr2 <= 95 ) begin
    tailAddr2_sram0  = tailAddr2;
    tailAddr2_sram2  = tailAddr2 - 64;
    sram0_a2_wen         = 0;
    sram1_a2_wen         = 0;
    sram2_a2_wen         = 1;
    sram3_a2_wen         = 0;
end
else if (tailAddr2 >= 32 && tailAddr2 <= 63 ) begin
    tailAddr2_sram0  = tailAddr2;
    tailAddr2_sram1  = tailAddr2 - 32;
    sram0_a2_wen         = 0;
    sram1_a2_wen         = 1;
    sram2_a2_wen         = 0;
    sram3_a2_wen         = 0;
end
else begin
    tailAddr2_sram0  = tailAddr2;
    tailAddr2_sram1  = tailAddr2;
    sram0_a2_wen         = 1;
    sram1_a2_wen         = 0;
    sram2_a2_wen         = 0;
    sram3_a2_wen         = 0;
end
if (tailAddr3 >= 96 && tailAddr3 < 128 ) begin
    tailAddr3_sram0  = tailAddr3;
    tailAddr3_sram3  = tailAddr3 - 96;
    sram0_a3_wen         = 0;
    sram1_a3_wen         = 0;
    sram2_a3_wen         = 0;
    sram3_a3_wen         = 1;
end
else if (tailAddr3 >= 64 && tailAddr3 <= 95 ) begin
    tailAddr3_sram0  = tailAddr3;
    tailAddr3_sram2  = tailAddr3 - 64;
    sram0_a3_wen         = 0;
    sram1_a3_wen         = 0;
    sram2_a3_wen         = 1;
    sram3_a3_wen         = 0;
end
else if (tailAddr3 >= 32 && tailAddr3 <= 63 ) begin
    tailAddr3_sram0  = tailAddr3;
    tailAddr3_sram1  = tailAddr3 - 32;
    sram0_a3_wen         = 0;
    sram1_a3_wen         = 1;
    sram2_a3_wen         = 0;
    sram3_a3_wen         = 0;
end

else begin
    tailAddr3_sram0  = tailAddr3;
    tailAddr3_sram1  = tailAddr3;
    sram0_a3_wen         = 1;
    sram1_a3_wen         = 0;
    sram2_a3_wen         = 0;
    sram3_a3_wen         = 0;
end


end

SRAM_4R4W #(`SIZE_ACTIVELIST/4,`SIZE_ACTIVELIST_LOG,2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1)
        activeList0 ( .clk(clk),
                     .reset(reset | recoverFlag | mispredFlag | exceptionFlag),
		     .addr0_i(headAddr0_sram0),
		     .addr1_i(headAddr1_sram0),
		     .addr2_i(headAddr2_sram0),
		     .addr3_i(headAddr3_sram0),

                     .addr0wr_i(tailAddr0_sram0),
		     .we0_i(backEndReady_i & sram0_a0_wen),
		     .data0wr_i(alPacket0_i),
                     .addr1wr_i(tailAddr1_sram0),
		     .we1_i(backEndReady_i & frontEndMask[2] & sram0_a1_wen ),
		     .data1wr_i(alPacket1_i),
                     .addr2wr_i(tailAddr2_sram0),
		     .we2_i(backEndReady_i & frontEndMask[1] & sram0_a2_wen ),
		     .data2wr_i(alPacket2_i),
                     .addr3wr_i(tailAddr3_sram0),
		     .we3_i(backEndReady_i & frontEndMask[0] & sram0_a3_wen ),
		     .data3wr_i(alPacket3_i),

                     .data0_o(dataAl0_s0),
                     .data1_o(dataAl1_s0),
                     .data2_o(dataAl2_s0),
                     .data3_o(dataAl3_s0)
		   );
SRAM_4R4W #(`SIZE_ACTIVELIST/4,`SIZE_ACTIVELIST_LOG,2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1)
        activeList1 ( .clk(clk),
                     .reset(reset | recoverFlag | mispredFlag | exceptionFlag),
		     .addr0_i(headAddr0_sram1),
		     .addr1_i(headAddr1_sram1),
		     .addr2_i(headAddr2_sram1),
		     .addr3_i(headAddr3_sram1),

                     .addr0wr_i(tailAddr0_sram1),
		     .we0_i(backEndReady_i & sram1_a0_wen),
		     .data0wr_i(alPacket0_i),
                     .addr1wr_i(tailAddr1_sram1),
		     .we1_i(backEndReady_i & frontEndMask[2] & sram1_a1_wen),
		     .data1wr_i(alPacket1_i),
                     .addr2wr_i(tailAddr2_sram1),
		     .we2_i(backEndReady_i & frontEndMask[1] & sram1_a2_wen),
		     .data2wr_i(alPacket2_i),
                     .addr3wr_i(tailAddr3_sram1),
		     .we3_i(backEndReady_i & frontEndMask[0] & sram1_a3_wen),
		     .data3wr_i(alPacket3_i),

                     .data0_o(dataAl0_s1),
                     .data1_o(dataAl1_s1),
                     .data2_o(dataAl2_s1),
                     .data3_o(dataAl3_s1)
		   );
SRAM_4R4W #(`SIZE_ACTIVELIST/4,`SIZE_ACTIVELIST_LOG,2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1)
        activeList2 ( .clk(clk),
                     .reset(reset | recoverFlag | mispredFlag | exceptionFlag),
		     .addr0_i(headAddr0_sram2),
		     .addr1_i(headAddr1_sram2),
		     .addr2_i(headAddr2_sram2),
		     .addr3_i(headAddr3_sram2),

                     .addr0wr_i(tailAddr0_sram2),
		     .we0_i(backEndReady_i & sram2_a0_wen),
		     .data0wr_i(alPacket0_i),
                     .addr1wr_i(tailAddr1_sram2),
		     .we1_i(backEndReady_i & frontEndMask[2] & sram2_a1_wen ),
		     .data1wr_i(alPacket1_i),
                     .addr2wr_i(tailAddr2_sram2),
		     .we2_i(backEndReady_i & frontEndMask[1] & sram2_a2_wen ),
		     .data2wr_i(alPacket2_i),
                     .addr3wr_i(tailAddr3_sram2),
		     .we3_i(backEndReady_i & frontEndMask[0] & sram2_a3_wen ),
		     .data3wr_i(alPacket3_i),

                     .data0_o(dataAl0_s2),
                     .data1_o(dataAl1_s2),
                     .data2_o(dataAl2_s2),
                     .data3_o(dataAl3_s2)
		   );
SRAM_4R4W #(`SIZE_ACTIVELIST/4,`SIZE_ACTIVELIST_LOG,2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1)
        activeList3 ( .clk(clk),
                     .reset(reset | recoverFlag | mispredFlag | exceptionFlag),
		     .addr0_i(headAddr0_sram3),
		     .addr1_i(headAddr1_sram3),
		     .addr2_i(headAddr2_sram3),
		     .addr3_i(headAddr3_sram3),

                     .addr0wr_i(tailAddr0_sram3),
		     .we0_i(backEndReady_i & sram3_a0_wen),
		     .data0wr_i(alPacket0_i),
                     .addr1wr_i(tailAddr1_sram3),
		     .we1_i(backEndReady_i & frontEndMask[2] & sram3_a1_wen ),
		     .data1wr_i(alPacket1_i),
                     .addr2wr_i(tailAddr2_sram3),
		     .we2_i(backEndReady_i & frontEndMask[1] & sram3_a2_wen ),
		     .data2wr_i(alPacket2_i),
                     .addr3wr_i(tailAddr3_sram3),
		     .we3_i(backEndReady_i & frontEndMask[0] & sram3_a3_wen ),
		     .data3wr_i(alPacket3_i),

                     .data0_o(dataAl0_s3),
                     .data1_o(dataAl1_s3),
                     .data2_o(dataAl2_s3),
                     .data3_o(dataAl3_s3)
		   );

assign    dataAl0 = (data0_sel == 3) ? dataAl0_s3 :
                    (data0_sel == 2) ? dataAl0_s2 :
                    (data0_sel == 1) ? dataAl0_s1 : dataAl0_s0;

assign    dataAl1 = (data1_sel == 3) ? dataAl1_s3 :
                    (data1_sel == 2) ? dataAl1_s2 :
                    (data1_sel == 1) ? dataAl1_s1 : dataAl1_s0;
assign    dataAl2 = (data2_sel == 3) ? dataAl2_s3 :
                    (data2_sel == 2) ? dataAl2_s2 :
                    (data2_sel == 1) ? dataAl2_s1 : dataAl2_s0;
assign    dataAl3 = (data3_sel == 3) ? dataAl3_s3 :
                    (data3_sel == 2) ? dataAl3_s2 :
                    (data3_sel == 1) ? dataAl3_s1 : dataAl3_s0;



//assign    dataAl1 = (data1_sel) ? dataAl1_s1 : dataAl1_s0;

//assign    dataAl2 = (data2_sel) ? dataAl2_s1 : dataAl2_s0;
//assign    dataAl3 = (data3_sel) ? dataAl3_s1 : dataAl3_s0;



SRAM_4R6W #(`SIZE_ACTIVELIST,`SIZE_ACTIVELIST_LOG,`WRITEBACK_FLAGS)
    ctrlActiveList ( .clk(clk),
                     .reset(reset | violateBit0_f | ctrlMispredict_f | exceptionBit0_f),
                     .addr0_i(headAddr0),
                     .addr1_i(headAddr1),
                     .addr2_i(headAddr2),
                     .addr3_i(headAddr3),

                     .addr0wr_i(fuAddr0),
                     .we0_i(fuEn0),
                     .data0wr_i(fuData0),
                     .addr1wr_i(fuAddr1),
                     .we1_i(fuEn1),
                     .data1wr_i(fuData1),
                     .addr2wr_i(fuAddr2),
                     .we2_i(fuEn2),
                     .data2wr_i(fuData2),
                     .addr3wr_i(fuAddr3),
                     .we3_i(fuEn3),
                     .data3wr_i(fuData3),
                     .addr4wr_i(fuAddr4),
                     .we4_i(fuEn4),
                     .data4wr_i(fuData4),
                     .addr5wr_i(fuAddr5),
                     .we5_i(fuEn5),
                     .data5wr_i(fuData5),

                     .data0_o(ctrlAl0),
                     .data1_o(ctrlAl1),
                     .data2_o(ctrlAl2),
                     .data3_o(ctrlAl3)
		   );


/* The "targetAddrActiveList" RAM contain computed target address of control
 * instructions. 
 * The target address is required for the mis-prediction recovery model being
 * supported, currently. The mis-predicted contol instruction is resolved when 
 * it reaches the head of the Active List.
 */
SRAM_4R6W #(`SIZE_ACTIVELIST,`SIZE_ACTIVELIST_LOG,`SIZE_PC)
    targetAddrActiveList ( .clk(clk),
                     .reset(reset | recoverFlag | mispredFlag | exceptionFlag),
                     .addr0_i(headAddr0),
                     .addr1_i(headAddr1),
                     .addr2_i(headAddr2),
                     .addr3_i(headAddr3),

                     .addr0wr_i(fuAddr0),
                     .we0_i(fuEn0),
                     .data0wr_i(computedAddr0_i),
                     .addr1wr_i(fuAddr1),
                     .we1_i(fuEn1),
                     .data1wr_i(computedAddr1_i),
                     .addr2wr_i(fuAddr2),
                     .we2_i(fuEn2),
                     .data2wr_i(computedAddr2_i),
                     .addr3wr_i(fuAddr3),
                     .we3_i(fuEn3),
                     .data3wr_i(computedAddr3_i),
                     .addr4wr_i(fuAddr4),
                     .we4_i(fuEn4),
                     .data4wr_i(computedAddr4_i),
                     .addr5wr_i(fuAddr5),
                     .we5_i(fuEn5),
                     .data5wr_i(computedAddr5_i),

                     .data0_o(targetAddr0),
                     .data1_o(targetAddr1),
                     .data2_o(targetAddr2),
                     .data3_o(targetAddr3)
                   );


SRAM_4R1W #(`SIZE_ACTIVELIST,`SIZE_ACTIVELIST_LOG,1)
    ldViolateVector( .clk(clk),
                     .reset(reset | recoverFlag | mispredFlag | exceptionFlag),
                     .addr0_i(headAddr0),
                     .addr1_i(headAddr1),
                     .addr2_i(headAddr2),
                     .addr3_i(headAddr3),

                     .addr0wr_i(ldViolationPacket_i[`SIZE_ACTIVELIST_LOG:1]),
                     .we0_i(ldViolationPacket_i[0]),
                     .data0wr_i(ldViolationPacket_i[0]),
                     .data0_o(violateBit0),
                     .data1_o(violateBit1),
                     .data2_o(violateBit2),
                     .data3_o(violateBit3)
                   );



/*******************************************************************************
* In case of load violation or control mis-prediction, recover flag is raised to 
* flush the pipeline.
*
* In case of load violation, nextPC is PC of the offending instruction. 
* In case of control mis-prediction, nextPC is the target address.
*******************************************************************************/
assign recoverFlag_o = recoverFlag | mispredFlag;
assign recoverPC_o   = (mispredFlag) ? targetPC:recoverPC;	


/*******************************************************************************
* In case of SYSCALL, exception flag is raised to flush the pipeline. 
* A behavioral code to handle SYSCALL is called.
*******************************************************************************/
assign exceptionFlag_o 	= exceptionFlag;
assign exceptionPC_o	= exceptionPC;


/* Following generates write address for writing into Active List, starting 
 * from the tail.
 */
always@(*) begin
  
  case(front)
  
  2'd3: begin 
  tailAddr0  = tailAL+0;
  tailAddr1  = tailAL+1;
  tailAddr2  = tailAL+2;
  tailAddr3  = tailAL+3;
  end

  2'd2: begin
  tailAddr0_1  = tailAL+0;
  tailAddr1_1  = tailAL+1;
  tailAddr2_1  = tailAL+2;
  tailAddr3_1  = tailAL+3;
  tailAddr0    = tailAddr0_1;
  tailAddr1    = tailAddr1_1;
  tailAddr2    = tailAddr2_1;
  tailAddr3    = tailAddr3_1;

  end

2'd1: begin
  tailAddr0_2  = tailAL+0;
  tailAddr1_2  = tailAL+1;
  tailAddr2_2  = tailAL+2;
  tailAddr3_2  = tailAL+3;
  tailAddr0    = tailAddr0_2;
  tailAddr1    = tailAddr1_2;
  tailAddr2    = tailAddr2_2;
  tailAddr3    = tailAddr3_2;

  end

2'd0: begin
  tailAddr0_3  = tailAL+0;
  tailAddr1_3  = tailAL+1;
  tailAddr2_3  = tailAL+2;
  tailAddr3_3  = tailAL+3;
  tailAddr0    = tailAddr0_3;
  tailAddr1    = tailAddr1_3;
  tailAddr2    = tailAddr2_3;
  tailAddr3    = tailAddr3_3;

  end

default: begin

  tailAddr0  = tailAL+0;
  tailAddr1  = tailAL+1;
  tailAddr2  = tailAL+2;
  tailAddr3  = tailAL+3;
  
  end
endcase





 /* Following generates read address for reading from Active List, starting 
  * from the head.
  */
 case(front)
 2'd3:begin
  headAddr0  = headAL+0;
  headAddr1  = headAL+1;
  headAddr2  = headAL+2;
  headAddr3  = headAL+3;
end

 2'd2:begin
  headAddr0_1  = headAL+0;
  headAddr1_1  = headAL+1;
  headAddr2_1  = headAL+2;
  headAddr3_1  = headAL+3;
  
  headAddr0    = headAddr0_1;
  headAddr1    = headAddr1_1;
  headAddr2    = headAddr2_1;
  headAddr3    = headAddr3_1;
end

  2'd1:begin
  headAddr0_2  = headAL+0;
  headAddr1_2  = headAL+1;
  headAddr2_2  = headAL+2;
  headAddr3_2  = headAL+3;
  
  headAddr0    = headAddr0_2;
  headAddr1    = headAddr1_2;
  headAddr2    = headAddr2_2;
  headAddr3    = headAddr3_2;
end

2'd0:begin
  headAddr0_3  = headAL+0;
  headAddr1_3  = headAL+1;
  headAddr2_3  = headAL+2;
  headAddr3_3  = headAL+3;
  
  headAddr0    = headAddr0_3;
  headAddr1    = headAddr1_3;
  headAddr2    = headAddr2_3;
  headAddr3    = headAddr3_3;
end

default: begin
  headAddr0  = headAL+0;
  headAddr1  = headAL+1;
  headAddr2  = headAL+2;
  headAddr3  = headAL+3;
end

endcase

end
 /* Following extracts write addr, enable and data information from the control
  * packet sent by FU. 
  * The information is written into ctrlActiveList RAM module. 
  */
 assign fuAddr0  = ctrlFU0_i[`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:`WRITEBACK_FLAGS]; 
 assign fuData0  = ctrlFU0_i[`WRITEBACK_FLAGS-1:0];
 assign fuEn0    = validFU0_i; 
 assign fuAddr1  = ctrlFU1_i[`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:`WRITEBACK_FLAGS]; 
 assign fuData1  = ctrlFU1_i[`WRITEBACK_FLAGS-1:0];
 assign fuEn1    = validFU1_i; 
 assign fuAddr2  = ctrlFU2_i[`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:`WRITEBACK_FLAGS]; 
 assign fuData2  = ctrlFU2_i[`WRITEBACK_FLAGS-1:0];
 assign fuEn2    = validFU2_i; 
 assign fuAddr3  = ctrlFU3_i[`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:`WRITEBACK_FLAGS]; 
 assign fuData3  = ctrlFU3_i[`WRITEBACK_FLAGS-1:0];
 assign fuEn3    = validFU3_i; 
 assign fuAddr4  = ctrlFU4_i[`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:`WRITEBACK_FLAGS]; 
 assign fuData4  = ctrlFU4_i[`WRITEBACK_FLAGS-1:0];
 assign fuEn4    = validFU4_i; 
 assign fuAddr5  = ctrlFU5_i[`SIZE_ACTIVELIST_LOG+`WRITEBACK_FLAGS-1:`WRITEBACK_FLAGS]; 
 assign fuData5  = ctrlFU5_i[`WRITEBACK_FLAGS-1:0];
 assign fuEn5    = validFU5_i; 

 assign ctrlMispredict_f  = mispredictBit0_f && ctrlAl0[2];
 /* Following generates the active list empty entries count each cycle.
  *  
  * In the normal operation, difference between tail and head pointer (taking warpping into
  * account) is the count.
  *
  * In the case of branch misprediction, differnce between offending instruction's active
  * list ID and head pointer is the count. Active list ID of the offending instruction is
  * sent by the corresponding functional unit.
  */
 always @(*)
 begin:GENERATE_COUNT
  reg [`SIZE_ACTIVELIST_LOG-1:0] tailAL_mispre;
  /*reg [`SIZE_ACTIVELIST_LOG-2:0] tailAL_mispre_1;
  reg [`SIZE_ACTIVELIST_LOG-3:0] tailAL_mispre_2;
  reg [`SIZE_ACTIVELIST_LOG-4:0] tailAL_mispre_3;*/
  reg                            isWrap1;
  reg [`SIZE_ACTIVELIST_LOG-1:0] diff1;
  reg [`SIZE_ACTIVELIST_LOG-1:0] diff2;
  reg [`SIZE_ACTIVELIST_LOG-1:0] cnt1;

 // case(front)
  
 // 2'd3: begin
 tailAL_f       = (backEndReady_i) ? (tailAL+frontEndWidth_i):tailAL;
/* end
 2'd2: begin
  tailAL_f1      = (backEndReady_i) ? (tailAL+frontEndWidth_i):tailAL;
  tailAL_f       = tailAL_f1;
  end 
  2'd1: begin
  tailAL_f2      = (backEndReady_i) ? (tailAL+frontEndWidth_i):tailAL;
  tailAL_f       = tailAL_f2;
  end  
  2'd0:begin
  tailAL_f3      = (backEndReady_i) ? (tailAL+frontEndWidth_i):tailAL;
  tailAL_f       = tailAL_f3;
  end 
  
  default:begin
  tailAL_f       = (backEndReady_i) ? (tailAL+frontEndWidth_i):tailAL;
  end
  endcase*/
 // case(front)
 // 2'd3: begin
  tailAL_mispre  =  mispredictEntry + 1'b1;
 /* end
  
  2'd2: begin
  tailAL_mispre_1=  mispredictEntry + 1'b1;
  tailAL_mispre    =  tailAL_mispre_1;
  end

   2'd1: begin
  tailAL_mispre_2=  mispredictEntry + 1'b1;
  tailAL_mispre    =  tailAL_mispre_2;
  end
  
  2'd0: begin
  tailAL_mispre_3=  mispredictEntry + 1'b1;
  tailAL_mispre    =  tailAL_mispre_3;
  end
  
  default: begin
  tailAL_mispre  =  mispredictEntry + 1'b1;
  end

  endcase
  */
  isWrap1        = (newheadAL > tailAL_mispre);
 
  diff1          =  tailAL_mispre - newheadAL;
  diff2          =  newheadAL     - tailAL_mispre;
  cnt1           = (isWrap1) ? (`SIZE_ACTIVELIST - diff2):diff1;
 
  activeListCount_f  = (activeListCount+((backEndReady_i) ? frontEndWidth_i:0))-totalCommit;
 end
 
  
 
 /* Following is the commit logic. Every cycle upto max COMMIT_WIDTH instructions
    can be retired. 
    "Executed" bit associated with each entry is checked from the head pointer. If
    the bit is one, then it is ready to retire (provided preceding entries have this
    bit set to 1). 
    
    IMP: commitValid is set to 1 only if the retiring instruction has a valid 
 	destination register. 
  */ 
 assign violateBit0_f	= violateBit0 & dataAl0[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
 assign violateBit1_f	= violateBit1 & dataAl1[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
 assign violateBit2_f	= violateBit2 & dataAl2[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
 assign violateBit3_f	= violateBit3 & dataAl3[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];

 /* Control mispredict bit is used to mark the misprediction. 
  * If there is a control instruction mispredicting in the commit group, the 
  * instruction is waited till it reaches head of the Active List. 
  */
 assign mispredictBit0_f = ctrlAl0[0];
 assign mispredictBit1_f = ctrlAl1[0];
 assign mispredictBit2_f = ctrlAl2[0];
 assign mispredictBit3_f = ctrlAl3[0];

 /* Exception bit is used to mark the system call. If there is a system call 
  * in the commit group, the instruction is waited till it reaches head of 
  * the Active List. Following, an appropriate function (behavioral) is called
  * to handle it.
  */
 assign exceptionBit0_f 	= ctrlAl0[1];
 assign exceptionBit1_f 	= ctrlAl1[1];
 assign exceptionBit2_f 	= ctrlAl2[1];
 assign exceptionBit3_f 	= ctrlAl3[1];

 always @(*)
 begin:COMMIT
 reg [`COMMIT_WIDTH-1:0]        commitVector_f;
 
  newheadAL     	= headAL; 
  totalCommit	= 0;
 
  commitValid0  	= 0; 
  commitPacket0 	= 0;
  commitStore0  	= 0;
  commitLoad0   	= 0;
  commitFission0 = 0;
  commitValid1  	= 0; 
  commitPacket1 	= 0;
  commitStore1  	= 0;
  commitLoad1   	= 0;
  commitFission1 = 0;
  commitValid2  	= 0; 
  commitPacket2 	= 0;
  commitStore2  	= 0;
  commitLoad2   	= 0;
  commitFission2 = 0;
  commitValid3  	= 0; 
  commitPacket3 	= 0;
  commitStore3  	= 0;
  commitLoad3   	= 0;
  commitFission3 = 0;

  commitCti	= 0;
 
  `ifdef VERIFY
  commitVerify0 	= 0;
  commitVerify1 	= 0;
  commitVerify2 	= 0;
  commitVerify3 	= 0;
  commitCount_f  = commitCount;
  `endif

  commitFission0  = ctrlAl0[3];
  commitFission1  = ctrlAl1[3];
  commitFission2  = ctrlAl2[3];
  commitFission3  = ctrlAl3[3];

  commitVector_f[0] = (activeListCount>0) & ctrlAl0[2] & ~violateBit0_f    & ~exceptionBit0_f;
  commitVector_f[1] = (activeListCount>1) & ctrlAl1[2] & ~mispredictBit1_f & ~mispredictBit0_f & ~violateBit1_f & ~exceptionBit1_f;
  commitVector_f[2] = (activeListCount>2) & ctrlAl2[2] & ~mispredictBit2_f & ~mispredictBit0_f & ~violateBit2_f & ~exceptionBit2_f;
  commitVector_f[3] = (activeListCount>3) & ctrlAl3[2] & ~mispredictBit3_f & ~mispredictBit0_f & ~violateBit3_f & ~exceptionBit3_f;

  /* Following makes sure the fission instrucitons retire together.
   */
  if(commitFission0)
 	commitVector[0] = commitVector_f[0] & commitVector_f[1];
  else
 	commitVector[0] = commitVector_f[0];
 
  if(commitFission1)
 	commitVector[1] = commitVector_f[1] & commitVector_f[2];
  else
 	commitVector[1] = commitVector_f[1];
 
  if(commitFission2)
 	commitVector[2] = commitVector_f[2] & commitVector_f[3];
  else
 	commitVector[2] = commitVector_f[2];
 

  if(commitFission3)
 	commitVector[3] = 1'b0;
  else
 	commitVector[3] = commitVector_f[3];

  casex(commitVector)
	4'bxx01:
    begin
       // case(front)
       // 2'd3: begin
       	newheadAL     	= headAL+1;
      /*  end
        2'd2: begin
        newheadAL1      = headAL+1;
        newheadAL       = newheadAL1;
        end
        2'd1: begin
        newheadAL2      = headAL+1;
        newheadAL       = newheadAL2;
        end
        2'd0: begin
        newheadAL3      = headAL+1;
        newheadAL       = newheadAL3;
        end
        default: begin
        newheadAL	= headAL+1;
        end
        endcase */
 	totalCommit	= 1;
	commitValid0  	= dataAl0[0];
	commitPacket0 	= dataAl0[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore0  	= dataAl0[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad0   	= dataAl0[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[0]	= ctrlAl0[7];

 	`ifdef VERIFY
  	commitVerify0 	= 1'b1;

 	commitCnt0      = commitCount+1;

 	commitCount_f   = commitCount+1;
 	`endif
    end	

	4'bx011:
    begin
        // case(front)
       // 2'd3: begin
       	newheadAL     	= headAL+2;
       /* end
        2'd2: begin
        newheadAL1      = headAL+2;
        newheadAL       = newheadAL1;
        end
        2'd1: begin
        newheadAL2      = headAL+2;
        newheadAL       = newheadAL2;
        end
        2'd0: begin
        newheadAL3      = headAL+2;
        newheadAL       = newheadAL3;
        end
        default: begin
        newheadAL	= headAL+2;
        end
        endcase*/
       //if(front == 2'd3)
       //	newheadAL     	= headAL+2;
       /* else if (front == 2'd2) begin
        newheadAL1      = headAL+2;
        newheadAL       = newheadAL1;
        end
        else if (front == 2'd1) begin
        newheadAL2      = headAL+2;
        newheadAL       = newheadAL2;
        end
        else begin
        newheadAL3      = headAL+2;    
        newheadAL       = newheadAL3;
        end */
 	totalCommit	= 2;
	commitValid0  	= dataAl0[0];
	commitPacket0 	= dataAl0[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore0  	= dataAl0[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad0   	= dataAl0[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[0]	= ctrlAl0[7];

	commitValid1  	= dataAl1[0];
	commitPacket1 	= dataAl1[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore1  	= dataAl1[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad1   	= dataAl1[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[1]	= ctrlAl1[7];

 	`ifdef VERIFY
  	commitVerify0 	= 1'b1;
  	commitVerify1 	= 1'b1;

 	commitCnt0      = commitCount+1;
 	commitCnt1      = commitCount+2;

 	commitCount_f   = commitCount+2;
 	`endif
    end	

	4'b0111:
    begin
       //  case(front)
       // 2'd3: begin
       	newheadAL     	= headAL+3;
       /* end
        2'd2: begin
        newheadAL1      = headAL+3;
        newheadAL       = newheadAL1;
        end
        2'd1: begin
        newheadAL2      = headAL+3;
        newheadAL       = newheadAL2;
        end
        2'd0: begin
        newheadAL3      = headAL+3;
        newheadAL       = newheadAL3;
        end
        default: begin
        newheadAL	= headAL+3;
        end
        endcase */
       //if(front == 2'd3)
      // 	newheadAL     	= headAL+3;
       /* else if (front == 2'd2) begin
        newheadAL1      = headAL+3;
        newheadAL       = newheadAL1;
        end
        else if (front == 2'd1) begin
        newheadAL2      = headAL+3;
        newheadAL       = newheadAL2;
        end
        else begin
        newheadAL3      = headAL+3;   
        newheadAL       = newheadAL3;
        end */
 	totalCommit	= 3;
	commitValid0  	= dataAl0[0];
	commitPacket0 	= dataAl0[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore0  	= dataAl0[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad0   	= dataAl0[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[0]	= ctrlAl0[7];

	commitValid1  	= dataAl1[0];
	commitPacket1 	= dataAl1[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore1  	= dataAl1[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad1   	= dataAl1[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[1]	= ctrlAl1[7];

	commitValid2  	= dataAl2[0];
	commitPacket2 	= dataAl2[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore2  	= dataAl2[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad2   	= dataAl2[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[2]	= ctrlAl2[7];

 	`ifdef VERIFY
  	commitVerify0 	= 1'b1;
  	commitVerify1 	= 1'b1;
  	commitVerify2 	= 1'b1;

 	commitCnt0      = commitCount+1;
 	commitCnt1      = commitCount+2;
 	commitCnt2      = commitCount+3;

 	commitCount_f   = commitCount+3;
 	`endif
    end	

	4'b1111:
    begin
        //case(front)
       // 2'd3: begin
       	newheadAL     	= headAL+4;
       /* end
        2'd2: begin
        newheadAL1      = headAL+4;
        newheadAL       = newheadAL1;
        end
        2'd1: begin
        newheadAL2      = headAL+4;
        newheadAL       = newheadAL2;
        end
        2'd0: begin
        newheadAL3      = headAL+4;
        newheadAL       = newheadAL3;
        end
        default: begin
        newheadAL	= headAL+4;
        end
        endcase*/
       // if(front == 2'd3)
       //	newheadAL     	= headAL+4;
       /* else if (front == 2'd2) begin
        newheadAL1      = headAL+4;
        newheadAL       = newheadAL1;
        end
        else if (front == 2'd1) begin
        newheadAL2      = headAL+4;
        newheadAL       = newheadAL2;
        end
        else begin
        newheadAL3      = headAL+4;    
        newheadAL       = newheadAL3;
        end */
 	totalCommit	= 4;
	commitValid0  	= dataAl0[0];
	commitPacket0 	= dataAl0[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore0  	= dataAl0[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad0   	= dataAl0[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[0]	= ctrlAl0[7];

	commitValid1  	= dataAl1[0];
	commitPacket1 	= dataAl1[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore1  	= dataAl1[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad1   	= dataAl1[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[1]	= ctrlAl1[7];

	commitValid2  	= dataAl2[0];
	commitPacket2 	= dataAl2[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore2  	= dataAl2[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad2   	= dataAl2[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[2]	= ctrlAl2[7];

	commitValid3  	= dataAl3[0];
	commitPacket3 	= dataAl3[`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:1];
	commitStore3  	= dataAl3[1+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitLoad3   	= dataAl3[2+`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG];
	commitCti[3]	= ctrlAl3[7];

 	`ifdef VERIFY
  	commitVerify0 	= 1'b1;
  	commitVerify1 	= 1'b1;
  	commitVerify2 	= 1'b1;
  	commitVerify3 	= 1'b1;

 	commitCnt0      = commitCount+1;
 	commitCnt1      = commitCount+2;
 	commitCnt2      = commitCount+3;
 	commitCnt3      = commitCount+4;

 	commitCount_f   = commitCount+4;
 	`endif
    end	

  endcase
 end
 
 
 /* Following assigns output signals of this module.
  */
reg [`SIZE_ACTIVELIST_LOG-1:0] activeListId0_0;
reg [`SIZE_ACTIVELIST_LOG-1:0] activeListId1_0;
reg [`SIZE_ACTIVELIST_LOG-1:0] activeListId2_0;
reg [`SIZE_ACTIVELIST_LOG-1:0] activeListId3_0;

reg [`SIZE_ACTIVELIST_LOG-2:0] activeListId0_1;
reg [`SIZE_ACTIVELIST_LOG-2:0] activeListId1_1;
reg [`SIZE_ACTIVELIST_LOG-2:0] activeListId2_1;
reg [`SIZE_ACTIVELIST_LOG-2:0] activeListId3_1;

reg [`SIZE_ACTIVELIST_LOG-3:0] activeListId0_2;
reg [`SIZE_ACTIVELIST_LOG-3:0] activeListId1_2;
reg [`SIZE_ACTIVELIST_LOG-3:0] activeListId2_2;
reg [`SIZE_ACTIVELIST_LOG-3:0] activeListId3_2;

reg [`SIZE_ACTIVELIST_LOG-4:0] activeListId0_3;
reg [`SIZE_ACTIVELIST_LOG-4:0] activeListId1_3;
reg [`SIZE_ACTIVELIST_LOG-4:0] activeListId2_3;
reg [`SIZE_ACTIVELIST_LOG-4:0] activeListId3_3;

always@(*)
begin: ALID
case(front)
2'd3:begin
 activeListId0_0  = tailAL+0;
 activeListId1_0  = tailAL+1;
 activeListId2_0  = tailAL+2;
 activeListId3_0  = tailAL+3;
end
2'd2:begin
 activeListId0_1  = tailAL+0;
 activeListId1_1  = tailAL+1;
 activeListId2_1  = tailAL+2;
 activeListId3_1  = tailAL+3;
 
 activeListId0_0  = activeListId0_1;
 activeListId1_0  = activeListId1_1;
 activeListId2_0  = activeListId2_1;
 activeListId3_0  = activeListId3_1;

end
2'd1:begin
 activeListId0_2  = tailAL+0;
 activeListId1_2  = tailAL+1;
 activeListId2_2  = tailAL+2;
 activeListId3_2  = tailAL+3;
 
 activeListId0_0  = activeListId0_2;
 activeListId1_0  = activeListId1_2;
 activeListId2_0  = activeListId2_2;
 activeListId3_0  = activeListId3_2;

end
2'd0:begin
 activeListId0_3  = tailAL+0;
 activeListId1_3  = tailAL+1;
 activeListId2_3  = tailAL+2;
 activeListId3_3  = tailAL+3; 
 activeListId0_0  = activeListId0_3;
 activeListId1_0  = activeListId1_3;
 activeListId2_0  = activeListId2_3;
 activeListId3_0  = activeListId3_3;


end
default: begin
 activeListId0_0  = tailAL+0;
 activeListId1_0  = tailAL+1;
 activeListId2_0  = tailAL+2;
 activeListId3_0  = tailAL+3;
 end
endcase
end

 assign activeListId0_o = activeListId0_0;
 assign activeListId1_o = activeListId1_0;
 assign activeListId2_o = activeListId2_0;
 assign activeListId3_o = activeListId3_0;



 assign activeListCnt_o  = activeListCount;

 assign commitValid0_o   = commitValid0;
 assign commitPacket0_o  = commitPacket0;
 assign commitStore0_o   = commitStore0;
 assign commitLoad0_o    = commitLoad0  & commitValid0;
 
 assign commitValid1_o   = commitValid1;
 assign commitPacket1_o  = commitPacket1;
 assign commitStore1_o   = commitStore1;
 assign commitLoad1_o    = commitLoad1  & commitValid1;
 
 assign commitValid2_o   = commitValid2;
 assign commitPacket2_o  = commitPacket2;
 assign commitStore2_o   = commitStore2;
 assign commitLoad2_o    = commitLoad2  & commitValid2;
 
 assign commitValid3_o   = commitValid3;
 assign commitPacket3_o  = commitPacket3;
 assign commitStore3_o   = commitStore3;
 assign commitLoad3_o    = commitLoad3  & commitValid3;
 

 assign commitCti_o	= commitCti;
 
 `ifdef VERIFY
 assign commitPC0	= dataAl0[`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1];
 assign commitPC1	= dataAl1[`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1];
 assign commitPC2	= dataAl2[`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1];
 assign commitPC3	= dataAl3[`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1];

 `endif
 
 /* Following updates the Active List tail pointer:
  * If, there is a branch mispredict, move the tail pointer to the next entry of
  * the offending instruction's entry.
  * Else if, back-end ready signal is high increament the tail pointer by dispatch
  * bandwidth.
  */
 always @(posedge clk)
 begin
  if(reset || recoverFlag || mispredFlag || exceptionFlag)
  begin
 	tailAL  <= 0;
  end
  else
  begin
 	tailAL <= tailAL_f;
  end
 end
 
 
 /* Following updates the Active List head pointer:
      newheadAL is computed above depending upto the number of instruction committing
      this cycle.    
 */
 always @(posedge clk)
 begin
  if(reset || recoverFlag || mispredFlag || exceptionFlag)
  begin
 	headAL  <= 0;
  end
  else
  begin
 	headAL  <= newheadAL;
  end
 end
 
 
 /*  Follwoing maintains the active list occupancy count each cycle.
  */
 always @(posedge clk)
 begin
  if(reset || recoverFlag || mispredFlag || exceptionFlag) 
  begin
 	activeListCount	<= 0;
  end
  else
  begin
 	activeListCount	<= activeListCount_f;
  end
 end
 
  
 /*  Following maintains the recover flag register. If the recover flag is high,
  *  it should be treated like an exception. 
  */
 always @(posedge clk)
 begin
  if(reset || recoverFlag || mispredFlag || exceptionFlag)
  begin
 	recoverFlag	<= 1'b0;
 	mispredFlag	<= 1'b0;
 	exceptionFlag	<= 1'b0;
  end
  else
  begin
 	if(ctrlMispredict_f && (|activeListCount))
 	begin
 		mispredFlag	<= 1'b1;
 		targetPC	<= targetAddr0;
 		
 	end
 	if(violateBit0_f && (|activeListCount))
 	begin
 		recoverFlag	<= 1'b1;
 		recoverPC	<= dataAl0[`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1];
 	end
 	if (exceptionBit0_f && (|activeListCount))
 	begin
 		$display("TRAP Instruction is being committed");
 		exceptionFlag   <= 1'b1;
                 exceptionPC     <= dataAl0[`SIZE_PC+`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG:`SIZE_RMT_LOG+2*`SIZE_PHYSICAL_LOG+1]+8;
 	end
  end
 end
 
 
 
 `ifdef VERIFY
 always @(posedge clk)
 begin:CLEAR_CTRL_AL
  integer k,l;
  reg [`SIZE_ACTIVELIST_LOG-1:0] cnt;
 
  if(reset)
  begin
 	commitCount 		       <= 0;	
  end
  else
  begin
 	commitCount		       <= commitCount_f;
  end
 
  if(backEndReady_i)
  begin
 	ctrlActiveList.sram[tailAddr0] 	<= 0;	
  if(frontEndWidth_i > 3'd1) begin
 	  ctrlActiveList.sram[tailAddr1] 	<= 0;
  end
  if(frontEndWidth_i > 3'd2) begin
   	ctrlActiveList.sram[tailAddr2] 	<= 0;	
  end
  if(frontEndWidth_i > 3'd3) begin
 	  ctrlActiveList.sram[tailAddr3] 	<= 0;
	end

 	ldViolateVector.sram[tailAddr0] <= 0;
  if(frontEndWidth_i > 3'd1) begin
 	  ldViolateVector.sram[tailAddr1] <= 0;
  end
  if(frontEndWidth_i > 3'd2) begin
 	  ldViolateVector.sram[tailAddr2] <= 0;
  end
  if(frontEndWidth_i > 3'd3) begin
 	  ldViolateVector.sram[tailAddr3] <= 0;
  end
  end
 
  if(1'b1)
  begin
 	casex({commitVerify3,commitVerify2,commitVerify1,commitVerify0})
	4'bxx01: begin
 				ctrlActiveList.sram[headAddr0] <= 0;
	end

	4'bx011: begin
 				ctrlActiveList.sram[headAddr0] <= 0;
 				ctrlActiveList.sram[headAddr1] <= 0;
	end

	4'b0111: begin
 				ctrlActiveList.sram[headAddr0] <= 0;
 				ctrlActiveList.sram[headAddr1] <= 0;
 				ctrlActiveList.sram[headAddr2] <= 0;
	end

	4'b1111: begin
 				ctrlActiveList.sram[headAddr0] <= 0;
 				ctrlActiveList.sram[headAddr1] <= 0;
 				ctrlActiveList.sram[headAddr2] <= 0;
 				ctrlActiveList.sram[headAddr3] <= 0;
	end

 	endcase
  end
 end
 `endif
 
 endmodule
 
