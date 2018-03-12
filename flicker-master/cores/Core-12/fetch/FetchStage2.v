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


module FetchStage2( 
                     input btbHit0_i,
                     input [`SIZE_PC-1:0] targetAddr0_i,
                     input prediction0_i,
		     output instruction0Valid_o,
                     output [`SIZE_INSTRUCTION+2*`SIZE_PC+`SIZE_CTI_LOG:0] inst0Packet_o,
                     input btbHit1_i,
                     input [`SIZE_PC-1:0] targetAddr1_i,
                     input prediction1_i,
		     output instruction1Valid_o,
                     output [`SIZE_INSTRUCTION+2*`SIZE_PC+`SIZE_CTI_LOG:0] inst1Packet_o,
                     input btbHit2_i,
                     input [`SIZE_PC-1:0] targetAddr2_i,
                     input prediction2_i,
		     output instruction2Valid_o,
                     output [`SIZE_INSTRUCTION+2*`SIZE_PC+`SIZE_CTI_LOG:0] inst2Packet_o,
                     input btbHit3_i,
                     input [`SIZE_PC-1:0] targetAddr3_i,
                     input prediction3_i,
		     output instruction3Valid_o,
                     output [`SIZE_INSTRUCTION+2*`SIZE_PC+`SIZE_CTI_LOG:0] inst3Packet_o,
		     input clk,
                     input reset,
                     input recoverFlag_i,
                     input stall_i,
                     input flush_i,
					 
					 input [`SIZE_CNT_TBL_LOG-1:0]bhr_upd_i,
					 input [`SIZE_CNT_TBL_LOG-1:0]bhr_CP_i,

                     input fs1Ready_i,
                     input [`SIZE_PC-1:0] pc_i,
                     input [`INSTRUCTION_BUNDLE-1:0] instructionBundle_i,
                     input [`SIZE_PC-1:0] addrRAS_CP_i,

                     `ifdef ICACHE
                     input startBlock_i,
                     input [1:0] firstInst_i,
                     `endif

                     input  [`SIZE_CTI_LOG-1:0] ctiQueueIndex_i,
                     input  [`SIZE_PC-1:0] targetAddr_i,
                     input  branchOutcome_i,
                     input  flagRecoverEX_i,
                     input  ctrlVerified_i,
                     input [`RETIRE_WIDTH-1:0] commitCti_i,

                     output flagRecoverID_o,
                     output [`SIZE_PC-1:0] targetAddrID_o,
                     output flagRtrID_o,
                     output flagCallID_o,
                     output [`SIZE_PC-1:0] callPCID_o,
	
			output reg update_bhr_CP_o,
			output reg dir_bhr_CP_o,
			output [`RETIRE_WIDTH-1:0]update_bhr_ret_o,
			output [`RETIRE_WIDTH-1:0]dir_bhr_ret_o,
			output update_bhr_upd_o,
			output dir_bhr_upd_o,

                     output [`SIZE_PC-1:0] updatePC_o,
                     output [`SIZE_PC-1:0] updateTargetAddr_o,
                     output [`BRANCH_TYPE-1:0] updateCtrlType_o,
                     output updateDir_o,
                     output updateEn_o,
					 output [`SIZE_CNT_TBL_LOG-1:0]bhr_upd_o,
                     output fs2Ready_o,
                     output ctiQueueFull_o,    // If CTI Queue is full, further Inst fetching should be stalled

			input [2:0] frontEndWidth_i
                   );


reg [`FETCH_BANDWIDTH-1:0]              filterVector;
reg [`FETCH_BANDWIDTH-1:0]              ctrlVector;


reg										flagRecover;
reg                                     flagRtr;
reg                                     flagCall;
reg [`SIZE_PC-1:0]                      targetAddr;
reg [`SIZE_PC-1:0]                      callPC;
wire                                    ctiQueueFull;

wire [`SIZE_PC-1:0]                     pc0;
reg [`SIZE_INSTRUCTION-1:0]             instruction0;
wire [`SIZE_OPCODE_P-1:0]               opcode0;
wire [`BRANCH_TYPE-1:0]                 ctrlType0;
wire [`SIZE_PC-1:0]                     targetAddr0;
wire                                    isInst0Ctrl;
wire                                    isInst0Rtr;
reg [`SIZE_PC-1:0]                      targetAddr0_f;
wire [`SIZE_CTI_LOG-1:0]                ctiqTag0;
	
wire [`SIZE_PC-1:0]                     pc1;
reg [`SIZE_INSTRUCTION-1:0]             instruction1;
wire [`SIZE_OPCODE_P-1:0]               opcode1;
wire [`BRANCH_TYPE-1:0]                 ctrlType1;
wire [`SIZE_PC-1:0]                     targetAddr1;
wire                                    isInst1Ctrl;
wire                                    isInst1Rtr;
reg [`SIZE_PC-1:0]                      targetAddr1_f;
wire [`SIZE_CTI_LOG-1:0]                ctiqTag1;
	
wire [`SIZE_PC-1:0]                     pc2;
reg [`SIZE_INSTRUCTION-1:0]             instruction2;
wire [`SIZE_OPCODE_P-1:0]               opcode2;
wire [`BRANCH_TYPE-1:0]                 ctrlType2;
wire [`SIZE_PC-1:0]                     targetAddr2;
wire                                    isInst2Ctrl;
wire                                    isInst2Rtr;
reg [`SIZE_PC-1:0]                      targetAddr2_f;
wire [`SIZE_CTI_LOG-1:0]                ctiqTag2;
	
wire [`SIZE_PC-1:0]                     pc3;
reg [`SIZE_INSTRUCTION-1:0]             instruction3;
wire [`SIZE_OPCODE_P-1:0]               opcode3;
wire [`BRANCH_TYPE-1:0]                 ctrlType3;
wire [`SIZE_PC-1:0]                     targetAddr3;
wire                                    isInst3Ctrl;
wire                                    isInst3Rtr;
reg [`SIZE_PC-1:0]                      targetAddr3_f;
wire [`SIZE_CTI_LOG-1:0]                ctiqTag3;
	
CtrlQueue ctiQueue( .clk(clk),
                    .inst0CtrlType_i(ctrlType0),
                    .pc0_i(pc0),
                    .ctiqTag0_o(ctiqTag0),

                    .inst1CtrlType_i(ctrlType1),
                    .pc1_i(pc1),
                    .ctiqTag1_o(ctiqTag1),

                    .inst2CtrlType_i(ctrlType2),
                    .pc2_i(pc2),
                    .ctiqTag2_o(ctiqTag2),

                    .inst3CtrlType_i(ctrlType3),
                    .pc3_i(pc3),
                    .ctiqTag3_o(ctiqTag3),

					.update_ret_o(update_bhr_ret_o),
					.dir_ret_o(dir_bhr_ret_o),
					.update_upd_o(update_bhr_upd_o),
					.dir_upd_o(dir_bhr_upd_o),
					.ghr_ctiq(bhr_CP_i),

                    .reset(reset),
                    .stall_i(stall_i),
                    .recoverFlag_i(recoverFlag_i),
                    .fs1Ready_i(fs1Ready_i),
                    .ctrlVector_i(ctrlVector),
                    .ctiQueueIndex_i(ctiQueueIndex_i),
                    .targetAddr_i(targetAddr_i),
                    .branchOutcome_i(branchOutcome_i),
                    .flagRecoverEX_i(flagRecoverEX_i),
                    .ctrlVerified_i(ctrlVerified_i),
                    .commitCti_i(commitCti_i),
                    .updatePC_o(updatePC_o),
                    .updateTarAddr_o(updateTargetAddr_o),
                    .updateCtrlType_o(updateCtrlType_o),
                    .updateDir_o(updateDir_o),
                    .updateEn_o(updateEn_o),
                    .ctiQueueFull_o(ctiQueueFull)
                  );

assign pc0     = pc_i + 0;
assign pc1     = pc_i + 8;
assign pc2     = pc_i + 16;
assign pc3     = pc_i + 24;

assign bhr_upd_o = bhr_upd_i;

always @(*)
begin
	instruction0 = instructionBundle_i[1*`SIZE_INSTRUCTION-1:0*`SIZE_INSTRUCTION];
	instruction1 = instructionBundle_i[2*`SIZE_INSTRUCTION-1:1*`SIZE_INSTRUCTION];
	instruction2 = instructionBundle_i[3*`SIZE_INSTRUCTION-1:2*`SIZE_INSTRUCTION];
	instruction3 = instructionBundle_i[4*`SIZE_INSTRUCTION-1:3*`SIZE_INSTRUCTION];
end

PreDecode_PISA preDecode0( .pc_i(pc0),
                           .instruction_i(instruction0),
                           .prediction_i(prediction0_i),
                           .targetAddr_i(targetAddr0_i),
                           .isInstCtrl_o(isInst0Ctrl),
                           .isInstRtr_o(isInst0Rtr),
                           .targetAddr_o(targetAddr0),
                           .ctrlType_o(ctrlType0)
                         );

PreDecode_PISA preDecode1( .pc_i(pc1),
                           .instruction_i(instruction1),
                           .prediction_i(prediction1_i),
                           .targetAddr_i(targetAddr1_i),
                           .isInstCtrl_o(isInst1Ctrl),
                           .isInstRtr_o(isInst1Rtr),
                           .targetAddr_o(targetAddr1),
                           .ctrlType_o(ctrlType1)
                         );

PreDecode_PISA preDecode2( .pc_i(pc2),
                           .instruction_i(instruction2),
                           .prediction_i(prediction2_i),
                           .targetAddr_i(targetAddr2_i),
                           .isInstCtrl_o(isInst2Ctrl),
                           .isInstRtr_o(isInst2Rtr),
                           .targetAddr_o(targetAddr2),
                           .ctrlType_o(ctrlType2)
                         );

PreDecode_PISA preDecode3( .pc_i(pc3),
                           .instruction_i(instruction3),
                           .prediction_i(prediction3_i),
                           .targetAddr_i(targetAddr3_i),
                           .isInstCtrl_o(isInst3Ctrl),
                           .isInstRtr_o(isInst3Rtr),
                           .targetAddr_o(targetAddr3),
                           .ctrlType_o(ctrlType3)
                         );

/* Following checks for any BTB miss in the previous cycle. If a misprediction
 * is detected then it raises the recovery flag and fix the next PC logic.   
 */
/* Following logic validates the BTB and RAS job. Following scenarios can occur:
 * case1: 
 */
always @(*)
begin:VALIDATE_BTB
// reg check0Branch;
// reg check1Branch;
// reg check2Branch;
// reg check3Branch;
// reg inst0Ctrl;
// reg inst1Ctrl;
// reg inst2Ctrl;
// reg inst3Ctrl;
// reg [`FETCH_BANDWIDTH-1:0] branchNT;

// check0Branch =  ~(ctrlType0[0] & ctrlType0[1]);
// check1Branch =  ~(ctrlType1[0] & ctrlType1[1]);
// check2Branch =  ~(ctrlType2[0] & ctrlType2[1]);
// check3Branch =  ~(ctrlType3[0] & ctrlType3[1]);

// inst0Ctrl    = isInst0Ctrl & (prediction0_i | check0Branch);
// inst1Ctrl    = isInst1Ctrl & (prediction1_i | check1Branch);
// inst2Ctrl    = isInst2Ctrl & (prediction2_i | check2Branch);
// inst3Ctrl    = isInst3Ctrl & (prediction3_i | check3Branch);

// branchNT[0]  = isInst0Ctrl & ctrlType0[0] & ctrlType0[1] & ~prediction0_i;
// branchNT[1]  = isInst1Ctrl & ctrlType1[0] & ctrlType1[1] & ~prediction1_i;
// branchNT[2]  = isInst2Ctrl & ctrlType2[0] & ctrlType2[1] & ~prediction2_i;
// branchNT[3]  = isInst3Ctrl & ctrlType3[0] & ctrlType3[1] & ~prediction3_i;

 flagRecover  = 1'b0;		
 flagRtr      = 1'b0;
 flagCall     = 1'b0;

 filterVector = 4'b1111;
 ctrlVector   = 4'b0000;
 targetAddr0_f = targetAddr0;
 targetAddr1_f = targetAddr1;
 targetAddr2_f = targetAddr2;
 targetAddr3_f = targetAddr3;
 
	update_bhr_CP_o = 0;
	dir_bhr_CP_o = 0; 


 casex({isInst0Ctrl,isInst1Ctrl,isInst2Ctrl,isInst3Ctrl})
       4'b1xxx:
       begin
	   update_bhr_CP_o = (ctrlType0 == 2'b11);
	   dir_bhr_CP_o = prediction0_i;
	 targetAddr   = targetAddr0;
	 callPC       = pc0;	
         filterVector = 4'b1000;
	 ctrlVector   = 4'b0001; 	
	 if(~btbHit0_i)
	 begin  
              flagRecover = 1'b1;		
		if(ctrlType0 == 2'b00)
		begin
			targetAddr0_f = addrRAS_CP_i;
			flagRtr  = 1'b1;
		end
              if(ctrlType0 == 2'b01)
                 	flagCall = 1'b1;
	 end
       end

       4'b01xx:
       begin
	 targetAddr   = targetAddr1;
	   update_bhr_CP_o = (ctrlType1 == 2'b11);
	   dir_bhr_CP_o = prediction1_i;	 
	 callPC       = pc1;	
         filterVector = 4'b1100;
	 ctrlVector   = 4'b0010;	
	 if(~btbHit1_i)
	 begin  
              flagRecover = 1'b1;		
		if(ctrlType1 == 2'b00)
		begin
			targetAddr1_f = addrRAS_CP_i;
			flagRtr  = 1'b1;
		end
              if(ctrlType1 == 2'b01)
                 	flagCall = 1'b1;
	 end
       end

       4'b001x:
       begin
	 targetAddr   = targetAddr2;
	   update_bhr_CP_o = (ctrlType2 == 2'b11);
	   dir_bhr_CP_o = prediction2_i;	 
	 callPC       = pc2;	
         filterVector = 4'b1110;
	 ctrlVector   = 4'b0100;
	 if(~btbHit2_i)
	 begin  
              flagRecover = 1'b1;		
		if(ctrlType2 == 2'b00)
		begin
			targetAddr2_f = addrRAS_CP_i;
			flagRtr  = 1'b1;
		end
              if(ctrlType2 == 2'b01)
                 	flagCall = 1'b1;
	 end
       end

       4'b0001:
       begin
	 targetAddr   = targetAddr3;
	   update_bhr_CP_o = (ctrlType3 == 2'b11);
	   dir_bhr_CP_o = prediction3_i;	 
	 callPC       = pc3;	
         filterVector = 4'b1111;
	 ctrlVector   = 4'b1000;
	 if(~btbHit3_i)
	 begin  
              flagRecover = 1'b1;		
		if(ctrlType3 == 2'b00)
		begin
			targetAddr3_f = addrRAS_CP_i;
			flagRtr  = 1'b1;
		end
              if(ctrlType3 == 2'b01)
                 	flagCall = 1'b1;
	 end
       end	
 endcase
end

//Flicker
reg [3:0] frontEndMask;
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

assign flagRecoverID_o = flagRecover & ~stall_i & ~ctiQueueFull;
assign flagRtrID_o     = flagRtr;
assign flagCallID_o    = flagCall;
assign targetAddrID_o  = targetAddr;
assign callPCID_o      = callPC;

assign inst0Packet_o         = {instruction0,pc0,targetAddr0_f,ctiqTag0,prediction0_i};
assign instruction0Valid_o   = filterVector[3] & frontEndMask[3];
assign inst1Packet_o         = {instruction1,pc1,targetAddr1_f,ctiqTag1,prediction1_i};
assign instruction1Valid_o   = filterVector[2] & frontEndMask[2];
assign inst2Packet_o         = {instruction2,pc2,targetAddr2_f,ctiqTag2,prediction2_i};
assign instruction2Valid_o   = filterVector[1] & frontEndMask[1];
assign inst3Packet_o         = {instruction3,pc3,targetAddr3_f,ctiqTag3,prediction3_i};
assign instruction3Valid_o   = filterVector[0] & frontEndMask[0];

assign ctiQueueFull_o = ctiQueueFull;
assign fs2Ready_o     = fs1Ready_i & ~ctiQueueFull;


endmodule

