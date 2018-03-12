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

module IssueQueue(
	input clk,
	input reset,

	input backEndReady_i,	

	input [9+`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
		`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0] dispatchPacket0_i,
	input [9+`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
		`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0] dispatchPacket1_i,
	input [9+`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
		`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0] dispatchPacket2_i,
	input [9+`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
		`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0] dispatchPacket3_i,

	/*  Active List IDs */
	input [`SIZE_ACTIVELIST_LOG-1:0] inst0ALid_i,
	input [`SIZE_ACTIVELIST_LOG-1:0] inst1ALid_i,
	input [`SIZE_ACTIVELIST_LOG-1:0] inst2ALid_i,
	input [`SIZE_ACTIVELIST_LOG-1:0] inst3ALid_i,

	/*  LSQ entry numbers  */
	input [`SIZE_LSQ_LOG-1:0] lsqId0_i,
	input [`SIZE_LSQ_LOG-1:0] lsqId1_i,
	input [`SIZE_LSQ_LOG-1:0] lsqId2_i,
	input [`SIZE_LSQ_LOG-1:0] lsqId3_i,

	/* Register File Valid bits */
	input [`SIZE_PHYSICAL_TABLE-1:0] phyRegRdy_i,

	/* Bypass tags + valid bit for LD/ST */
	input [`SIZE_PHYSICAL_LOG:0]  rsr5Tag_i,

	/* Control execution flags from the bypass path */
	input ctrlVerified_i,
	/*  if 1, there has been a mis-predict previous cycle */
	input ctrlMispredict_i,

	/* SMT id of the mispredicted branch */
	input [`CHECKPOINTS_LOG-1:0] ctrlSMTid_i,

	/* Count of Valid Issue Q Entries goes to Dispatch */
	output [`SIZE_ISSUEQ_LOG:0] cntInstIssueQ_o,

	/* Note: These have to be sent directly to the PRF (RSR
	 * broadcast to ensure ready bits are set for the PRF
	 * entries)
	 */
	output [`SIZE_PHYSICAL_LOG-1:0] rsr0Tag_o,
	output rsr0TagValid_o,
	output [`SIZE_PHYSICAL_LOG-1:0] rsr1Tag_o,
	output rsr1TagValid_o,
	output [`SIZE_PHYSICAL_LOG-1:0] rsr2Tag_o,
	output rsr2TagValid_o,
	output [`SIZE_PHYSICAL_LOG-1:0] rsr3Tag_o,
	output rsr3TagValid_o,
	output [`SIZE_PHYSICAL_LOG-1:0] rsr4Tag_o,
	output rsr4TagValid_o,

	/* Payload and Destination of instructions */
	output grantedValid0_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket0_o,
	output grantedValid1_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket1_o,
	output grantedValid2_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket2_o,
	output grantedValid3_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket3_o,
	output grantedValid4_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket4_o,
	output grantedValid5_o,
	output [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket5_o,

  input [2:0] frontEndWidth_i,
  input [2:0] issueQSize_i,
  input [1:0] simpleALUWidth_i
);

//Flicker
reg [1:0] size;
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

/************************************************************************************ 
*   Instantiating issue queue and payload ram for all the functional units. 
*   This is a unified structure.
*   
*   ISSUE_QUEUE Width: Src1 Reg Ready(1), Src2 Reg Ready(1)
************************************************************************************/
reg [`SIZE_ISSUEQ-1:0] SRC0_REG_VALID;
reg [`SIZE_ISSUEQ-1:0] SRC1_REG_VALID;

/************************************************************************************
*  ISSUEQ_FU: FU type of the instructions in the Issue Queue. This information is 
*	      used for selecting ready instructions for scheduling per functional
*             unit.	 	
************************************************************************************/
reg [`INST_TYPES_LOG-1:0] ISSUEQ_FU [`SIZE_ISSUEQ-1:0];

/************************************************************************************
*  BRANCH_MASK: Branch tag of the instructions in the Issue Queue, assigned during 
*	       renaming.	
*              Branch tag is used during the branch mis-prediction recovery process.
************************************************************************************/
reg [`CHECKPOINTS-1:0]   BRANCH_MASK [`SIZE_ISSUEQ-1:0];

/************************************************************************************
*  ISSUEQ_SCHEDULED: 1-bit indicating whether the issue queue entry has been issued 
*		     for execution.
************************************************************************************/
reg [`SIZE_ISSUEQ-1:0]   ISSUEQ_SCHEDULED;

/************************************************************************************
*  ISSUEQ_VALID: 1-bit indicating validity of each entry in the Issue Queue.
************************************************************************************/
reg [`SIZE_ISSUEQ-1:0]    ISSUEQ_VALID;

/***********************************************************************************/

/* Wire & Regs definition for the combinational logic. */
wire freedValid0;
wire freedValid1;
wire freedValid2;
wire freedValid3;
wire freedValid4;
wire freedValid5;

wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry0;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry1;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry2;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry3;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry4;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry5;

/* Issue queue entries popped from the freeList */
wire [`SIZE_ISSUEQ_LOG-1:0] freeEntry0;
wire [`SIZE_ISSUEQ_LOG-1:0] freeEntry1;
wire [`SIZE_ISSUEQ_LOG-1:0] freeEntry2;
wire [`SIZE_ISSUEQ_LOG-1:0] freeEntry3;

reg [`SIZE_ISSUEQ-1:0] issueqValid_normal;
reg [`SIZE_ISSUEQ-1:0] issueqValid_mispre;
reg [`SIZE_ISSUEQ-1:0] freedValid_mispre;

reg [`SIZE_ISSUEQ-1:0] issueqSchedule_normal;

/* instSource is used to extract source registers from the dispatched instruction. */
reg [`SIZE_PHYSICAL_LOG:0] inst0Source1;
reg [`SIZE_PHYSICAL_LOG:0] inst0Source2;
reg [`SIZE_PHYSICAL_LOG:0] inst1Source1;
reg [`SIZE_PHYSICAL_LOG:0] inst1Source2;
reg [`SIZE_PHYSICAL_LOG:0] inst2Source1;
reg [`SIZE_PHYSICAL_LOG:0] inst2Source2;
reg [`SIZE_PHYSICAL_LOG:0] inst3Source1;
reg [`SIZE_PHYSICAL_LOG:0] inst3Source2;

reg [`CHECKPOINTS-1:0] branch0mask;
reg [`CHECKPOINTS-1:0] branch1mask;
reg [`CHECKPOINTS-1:0] branch2mask;
reg [`CHECKPOINTS-1:0] branch3mask;
reg [`CHECKPOINTS-1:0] update_mask;

/* newInsReady is used to store ready bit computed on the dispatched instruction. */
reg newInsReady01;
reg newInsReady02;
reg newInsReady11;
reg newInsReady12;
reg newInsReady21;
reg newInsReady22;
reg newInsReady31;
reg newInsReady32;

/* Wires to handle next SRC0_REG_VALID and SRC1_REG_VALID bits */
wire [`SIZE_ISSUEQ-1:0] src0RegValid_t0;
wire [`SIZE_ISSUEQ-1:0] src1RegValid_t0;
reg [`SIZE_ISSUEQ-1:0] src0RegValid_t1;
reg [`SIZE_ISSUEQ-1:0] src1RegValid_t1;

reg [`SIZE_ISSUEQ-1:0] requestVector0;
reg [`SIZE_ISSUEQ-1:0] requestVector1;
reg [`SIZE_ISSUEQ-1:0] requestVector2;
reg [`SIZE_ISSUEQ-1:0] requestVector3;

wire grantedValid0;
wire grantedValid1;
wire grantedValid2;
wire grantedValid3;
wire grantedValid4;
wire grantedValid5;

wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntry0;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntry1;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntry2;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntry3;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntry4;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntry5;

wire grantedValid0_t;
wire grantedValid1_t;
wire grantedValid2_t;
wire grantedValid3_t;
wire grantedValid4_t;
wire grantedValid5_t;

	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket0_t;
	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket1_t;
	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket2_t;
	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket3_t;
	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket4_t;
	wire [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket5_t;

`ifdef VERIFY
wire [`SIZE_PC-1:0] grantedPC0;
wire [`SIZE_PC-1:0] grantedPC1;
wire [`SIZE_PC-1:0] grantedPC2;
wire [`SIZE_PC-1:0] grantedPC3;
wire [`SIZE_PC-1:0] grantedPC4;
wire [`SIZE_PC-1:0] grantedPC5;
`endif

wire freedValid02;
wire freedValid12;
wire freedValid22;
wire freedValid32;
wire freedValid42;

wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry02;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry12;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry22;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry32;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry42;

wire [`SIZE_PHYSICAL_LOG-1:0] rsr0Tag;
wire rsr0TagValid;
wire [`SIZE_PHYSICAL_LOG-1:0] rsr1Tag;
wire rsr1TagValid;
wire [`SIZE_PHYSICAL_LOG-1:0] rsr2Tag;
wire rsr2TagValid;
wire [`SIZE_PHYSICAL_LOG-1:0] rsr3Tag;
wire rsr3TagValid;
wire [`SIZE_PHYSICAL_LOG-1:0] rsr4Tag;
wire rsr4TagValid;

wire [`SIZE_PHYSICAL_LOG-1:0] granted0Dest;
wire [`SIZE_PHYSICAL_LOG-1:0] granted1Dest;
wire [`SIZE_PHYSICAL_LOG-1:0] granted2Dest;
wire [`SIZE_PHYSICAL_LOG-1:0] granted3Dest;
wire [`SIZE_PHYSICAL_LOG-1:0] granted4Dest;

wire [`SIZE_ISSUEQ_LOG-1:0] granted0Entry;
wire [`SIZE_ISSUEQ_LOG-1:0] granted1Entry;
wire [`SIZE_ISSUEQ_LOG-1:0] granted2Entry;
wire [`SIZE_ISSUEQ_LOG-1:0] granted3Entry;
wire [`SIZE_ISSUEQ_LOG-1:0] granted4Entry;

/* Wires to "alias" the RSR + valid bit*/
wire [`SIZE_PHYSICAL_LOG:0]  rsr0Tag_t;
wire [`SIZE_PHYSICAL_LOG:0]  rsr1Tag_t;
wire [`SIZE_PHYSICAL_LOG:0]  rsr2Tag_t;
wire [`SIZE_PHYSICAL_LOG:0]  rsr3Tag_t;
wire [`SIZE_PHYSICAL_LOG:0]  rsr4Tag_t;

/* Wires for Issue Queue Payload RAM */
`define SIZE_PAYLOAD_WIDTH (2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1)

wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData0;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData1;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData2;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData3;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData4;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMData5;

wire payloadRAMwe0;
wire payloadRAMwe1;
wire payloadRAMwe2;
wire payloadRAMwe3;

wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMDataWr0;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMDataWr1;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMDataWr2;
wire [`SIZE_PAYLOAD_WIDTH-1:0] payloadRAMDataWr3;

/* Wires for wakeup CAM */
wire [`SIZE_ISSUEQ-1:0] src0_matchLines0;
wire [`SIZE_ISSUEQ-1:0] src0_matchLines1;
wire [`SIZE_ISSUEQ-1:0] src0_matchLines2;
wire [`SIZE_ISSUEQ-1:0] src0_matchLines3;
wire [`SIZE_ISSUEQ-1:0] src0_matchLines4;
wire [`SIZE_ISSUEQ-1:0] src0_matchLines5;

wire [`SIZE_ISSUEQ-1:0] src1_matchLines0;
wire [`SIZE_ISSUEQ-1:0] src1_matchLines1;
wire [`SIZE_ISSUEQ-1:0] src1_matchLines2;
wire [`SIZE_ISSUEQ-1:0] src1_matchLines3;
wire [`SIZE_ISSUEQ-1:0] src1_matchLines4;
wire [`SIZE_ISSUEQ-1:0] src1_matchLines5;

wire CAM0we0;
wire CAM0we1;
wire CAM0we2;
wire CAM0we3;

wire CAM1we0;
wire CAM1we1;
wire CAM1we2;
wire CAM1we3;

/* Correctly "alias" rsr0Tag_t */
assign rsr0Tag_t = {rsr0Tag, rsr0TagValid};
assign rsr1Tag_t = {rsr1Tag, rsr1TagValid};
assign rsr2Tag_t = {rsr2Tag, rsr2TagValid};
assign rsr3Tag_t = {rsr3Tag, rsr3TagValid};
assign rsr4Tag_t = {rsr4Tag, rsr4TagValid};

/* Assign to output the rsrTags */
assign rsr0TagValid_o = rsr0TagValid;
assign rsr1TagValid_o = rsr1TagValid;
assign rsr2TagValid_o = rsr2TagValid;
assign rsr3TagValid_o = rsr3TagValid;
assign rsr4TagValid_o = rsr4TagValid;

assign rsr0Tag_o = rsr0Tag;
assign rsr1Tag_o = rsr1Tag;
assign rsr2Tag_o = rsr2Tag;
assign rsr3Tag_o = rsr3Tag;
assign rsr4Tag_o = rsr4Tag;

/************************************************************************************
* ISSUEQ_PAYLOAD: Has all the necessary information required by function unit to 
		  execute the instruction. Implemented as payloadRAM
	       (Source registers, LD/ST queue ID, Active List ID, Shadow Map ID, Destination register, 
		   Immediate data, LD/ST data size, Opcode, Program counter, Predicted
		   Target Address, Ctiq Tag, Predicted Branch direction)	  
************************************************************************************/
assign payloadRAMwe0 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign payloadRAMwe1 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[2];
assign payloadRAMwe2 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[1];
assign payloadRAMwe3 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[0];

assign payloadRAMDataWr0 = {inst0Source2[`SIZE_PHYSICAL_LOG:1],inst0Source1[`SIZE_PHYSICAL_LOG:1],
	lsqId0_i,inst0ALid_i,
	dispatchPacket0_i[`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
	`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+
	2*`SIZE_PC+`SIZE_CTI_LOG:4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket0_i[3*`SIZE_PHYSICAL_LOG+3+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:1+2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
	`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket0_i[`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket0_i[`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket0_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0]};

assign payloadRAMDataWr1 = {inst1Source2[`SIZE_PHYSICAL_LOG:1],inst1Source1[`SIZE_PHYSICAL_LOG:1],
	lsqId1_i,inst1ALid_i,
	dispatchPacket1_i[`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
	`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+
	2*`SIZE_PC+`SIZE_CTI_LOG:4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket1_i[3*`SIZE_PHYSICAL_LOG+3+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:1+2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
	`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket1_i[`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket1_i[`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket1_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0]};

assign payloadRAMDataWr2 = {inst2Source2[`SIZE_PHYSICAL_LOG:1],inst2Source1[`SIZE_PHYSICAL_LOG:1],
	lsqId2_i,inst2ALid_i,
	dispatchPacket2_i[`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
	`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+
	2*`SIZE_PC+`SIZE_CTI_LOG:4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket2_i[3*`SIZE_PHYSICAL_LOG+3+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:1+2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
	`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket2_i[`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket2_i[`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket2_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0]};

assign payloadRAMDataWr3 = {inst3Source2[`SIZE_PHYSICAL_LOG:1],inst3Source1[`SIZE_PHYSICAL_LOG:1],
	lsqId3_i,inst3ALid_i,
	dispatchPacket3_i[`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+
	`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+
	2*`SIZE_PC+`SIZE_CTI_LOG:4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket3_i[3*`SIZE_PHYSICAL_LOG+3+`SIZE_IMMEDIATE+1+
	`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:1+2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
	`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket3_i[`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:1+`LDST_TYPES_LOG+`INST_TYPES_LOG+
	`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket3_i[`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
	`SIZE_CTI_LOG:`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1],
	dispatchPacket3_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:0]};


SRAM_6R6W_PAYLOAD #(`SIZE_ISSUEQ,`SIZE_ISSUEQ_LOG,`SIZE_PAYLOAD_WIDTH) payloadRAM(.clk(clk),
	.reset(reset),
	.addr0_i(grantedEntry0),
	.addr1_i(grantedEntry1),
	.addr2_i(grantedEntry2),
	.addr3_i(grantedEntry3),
	.addr4_i(grantedEntry4),
	.addr5_i(grantedEntry5),
	.addr0wr_i(freeEntry0),
	.addr1wr_i(freeEntry1),
	.addr2wr_i(freeEntry2),
	.addr3wr_i(freeEntry3),
	.we0_i(payloadRAMwe0),
	.we1_i(payloadRAMwe1),
	.we2_i(payloadRAMwe2),
	.we3_i(payloadRAMwe3),
	.data0wr_i(payloadRAMDataWr0),
	.data1wr_i(payloadRAMDataWr1),
	.data2wr_i(payloadRAMDataWr2),
	.data3wr_i(payloadRAMDataWr3),
	.data0_o(payloadRAMData0),
	.data1_o(payloadRAMData1),
	.data2_o(payloadRAMData2),
	.data3_o(payloadRAMData3),
	.data4_o(payloadRAMData4),
	.data5_o(payloadRAMData5)
);

/************************************************************************************
* WAKEUP CAM: Has the source physical registers that try to match tags broadcasted by the RSR
************************************************************************************/
assign src0RegValid_t0 = ISSUEQ_VALID & (~ISSUEQ_SCHEDULED) & (SRC0_REG_VALID | src0_matchLines0 | src0_matchLines1 | src0_matchLines2 | src0_matchLines3 | src0_matchLines4 | src0_matchLines5);
assign src1RegValid_t0 = ISSUEQ_VALID & (~ISSUEQ_SCHEDULED) & (SRC1_REG_VALID | src1_matchLines0 | src1_matchLines1 | src1_matchLines2 | src1_matchLines3 | src1_matchLines4 | src1_matchLines5);

assign CAM0we0 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign CAM0we1 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[2];
assign CAM0we2 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[1];
assign CAM0we3 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[0];

assign CAM1we0 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i);
assign CAM1we1 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[2];
assign CAM1we2 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[1];
assign CAM1we3 = backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i) && frontEndMask[0];

/* Instantiate the CAM for the 2nd source operand */
CAM_4R4W #(`SIZE_ISSUEQ,`SIZE_ISSUEQ_LOG, `SIZE_PHYSICAL_LOG) src1cam (.clk(clk),
	.reset(reset),
	.tag0_i(rsr0Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag1_i(rsr1Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag2_i(rsr2Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag3_i(rsr3Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag4_i(rsr4Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag5_i(rsr5Tag_i[`SIZE_PHYSICAL_LOG:1]),
	.addr0wr_i(freeEntry0),
	.addr1wr_i(freeEntry1),
	.addr2wr_i(freeEntry2),
	.addr3wr_i(freeEntry3),
	.we0_i(CAM1we0),
	.we1_i(CAM1we1),
	.we2_i(CAM1we2),
	.we3_i(CAM1we3),
	.tag0wr_i(inst0Source2[`SIZE_PHYSICAL_LOG:1]),
	.tag1wr_i(inst1Source2[`SIZE_PHYSICAL_LOG:1]),
	.tag2wr_i(inst2Source2[`SIZE_PHYSICAL_LOG:1]),
	.tag3wr_i(inst3Source2[`SIZE_PHYSICAL_LOG:1]),
	.match0_o(src1_matchLines0),
	.match1_o(src1_matchLines1),
	.match2_o(src1_matchLines2),
	.match3_o(src1_matchLines3),
	.match4_o(src1_matchLines4),
	.match5_o(src1_matchLines5)
);

/* Instantiate the CAM for the 1st source operand */
CAM_4R4W #(`SIZE_ISSUEQ,`SIZE_ISSUEQ_LOG, `SIZE_PHYSICAL_LOG) src0cam (.clk(clk),
	.reset(reset),
	.tag0_i(rsr0Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag1_i(rsr1Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag2_i(rsr2Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag3_i(rsr3Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag4_i(rsr4Tag_t[`SIZE_PHYSICAL_LOG:1]),
	.tag5_i(rsr5Tag_i[`SIZE_PHYSICAL_LOG:1]),
	.addr0wr_i(freeEntry0),
	.addr1wr_i(freeEntry1),
	.addr2wr_i(freeEntry2),
	.addr3wr_i(freeEntry3),
	.we0_i(CAM0we0),
	.we1_i(CAM0we1),
	.we2_i(CAM0we2),
	.we3_i(CAM0we3),
	.tag0wr_i(inst0Source1[`SIZE_PHYSICAL_LOG:1]),
	.tag1wr_i(inst1Source1[`SIZE_PHYSICAL_LOG:1]),
	.tag2wr_i(inst2Source1[`SIZE_PHYSICAL_LOG:1]),
	.tag3wr_i(inst3Source1[`SIZE_PHYSICAL_LOG:1]),
	.match0_o(src0_matchLines0),
	.match1_o(src0_matchLines1),
	.match2_o(src0_matchLines2),
	.match3_o(src0_matchLines3),
	.match4_o(src0_matchLines4),
	.match5_o(src0_matchLines5)
);

/************************************************************************************ 
* Instantiate the Issue Queue Free List. 
* Issue queue free list is a circular buffer and keeps tracks of free entries.  
************************************************************************************/
IssueQFreeList issueQfreelist(.clk(clk),
	.reset(reset),
	.ctrlVerified_i(ctrlVerified_i),
	.ctrlMispredict_i(ctrlMispredict_i),
	.mispredictVector_i(freedValid_mispre),
	.backEndReady_i(backEndReady_i),
	/* 4 entries being freed once they have been executed. */
	.grantedEntry0_i(grantedEntry0),
	.grantedEntry1_i(grantedEntry1),
	.grantedEntry2_i(grantedEntry2),
	.grantedEntry3_i(grantedEntry3),
	.grantedEntry4_i(grantedEntry4),
	.grantedEntry5_i(grantedEntry5),
	.grantedValid0_i(grantedValid0_t),
	.grantedValid1_i(grantedValid1_t),
	.grantedValid2_i(grantedValid2_t),
	.grantedValid3_i(grantedValid3_t),
	.grantedValid4_i(grantedValid4_t),
	.grantedValid5_i(grantedValid5_t),
	.freedEntry0_o(freedEntry0),
	.freedEntry1_o(freedEntry1),
	.freedEntry2_o(freedEntry2),
	.freedEntry3_o(freedEntry3),
	.freedEntry4_o(freedEntry4),
	.freedEntry5_o(freedEntry5),
	.freedValid0_o(freedValid0),
	.freedValid1_o(freedValid1),
	.freedValid2_o(freedValid2),
	.freedValid3_o(freedValid3),
	.freedValid4_o(freedValid4),
	.freedValid5_o(freedValid5),
	/* 4 free Issue Queue entries for the new coming instructions. */
	.freeEntry0_o(freeEntry0),
	.freeEntry1_o(freeEntry1),
	.freeEntry2_o(freeEntry2),
	.freeEntry3_o(freeEntry3),
	/* Count of Valid Issue Q Entries goes to Dispatch */
	.cntInstIssueQ_o(cntInstIssueQ_o),

		  .frontEndWidth_i(frontEndWidth_i),
                .issueQSize_i(issueQSize_i)
);

/************************************************************************************ 
*   If the Issue Queue enrtry has been granted execution then the Instruction
*   Payload and Destination Tags should be pushed down the pipeline with proper
*   valid bit set.
*   
*   Granted Valid is also checked for any branch misprediction this cycles. So
*   that instruction from the wrong path is not issued for execution.
************************************************************************************/
assign grantedValid0_t  = grantedValid0 && ~(ctrlMispredict_i && BRANCH_MASK[grantedEntry0][ctrlSMTid_i]);
assign grantedValid1_t  = grantedValid1 && ~(ctrlMispredict_i && BRANCH_MASK[grantedEntry1][ctrlSMTid_i]) && (frontEndWidth_i >= 3'd2);
assign grantedValid2_t  = grantedValid2 && ~(ctrlMispredict_i && BRANCH_MASK[grantedEntry2][ctrlSMTid_i]) && (frontEndWidth_i == 3'd4);
assign grantedValid3_t  = grantedValid3 && ~(ctrlMispredict_i && BRANCH_MASK[grantedEntry3][ctrlSMTid_i]);
assign grantedValid4_t  = grantedValid4 && ~(ctrlMispredict_i && BRANCH_MASK[grantedEntry4][ctrlSMTid_i]);
assign grantedValid5_t  = grantedValid5 && ~(ctrlMispredict_i && BRANCH_MASK[grantedEntry5][ctrlSMTid_i]);

assign grantedPacket0_t = {BRANCH_MASK[grantedEntry0], grantedEntry0, payloadRAMData0};
assign grantedPacket1_t = {BRANCH_MASK[grantedEntry1], grantedEntry1, payloadRAMData1};
assign grantedPacket2_t = {BRANCH_MASK[grantedEntry2], grantedEntry2, payloadRAMData2};
assign grantedPacket3_t = {BRANCH_MASK[grantedEntry3], grantedEntry3, payloadRAMData3};
assign grantedPacket4_t = {BRANCH_MASK[grantedEntry4], grantedEntry4, payloadRAMData4};
assign grantedPacket5_t = {BRANCH_MASK[grantedEntry5], grantedEntry5, payloadRAMData5};

assign grantedValid0_o  = grantedValid0_t;
assign grantedValid1_o  = grantedValid1_t;
assign grantedValid2_o  = grantedValid2_t;
assign grantedValid3_o  = grantedValid3_t;
assign grantedValid4_o  = grantedValid4_t;
assign grantedValid5_o  = grantedValid5_t;

assign grantedPacket0_o  = grantedPacket0_t;
assign grantedPacket1_o  = grantedPacket1_t;
assign grantedPacket2_o  = grantedPacket2_t;
assign grantedPacket3_o  = grantedPacket3_t;
assign grantedPacket4_o  = grantedPacket4_t;
assign grantedPacket5_o  = grantedPacket5_t;

`ifdef VERIFY
assign grantedPC0 = grantedPacket0_t[`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
assign grantedPC1 = grantedPacket1_t[`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
assign grantedPC2 = grantedPacket2_t[`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
assign grantedPC3 = grantedPacket3_t[`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
assign grantedPC4 = grantedPacket4_t[`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
assign grantedPC5 = grantedPacket5_t[`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
`endif

/************************************************************************************ 
*  Logic to check new instructions source operand Ready for dispached 
*  instruction from rename stage. 
************************************************************************************/
always @(*)
begin:CHECK_NEW_INSTS_SOURCE_OPERAND

	/* Extracting source registers and branch mask from the dispatched packet */
	inst0Source1 = dispatchPacket0_i[`SIZE_PHYSICAL_LOG+1+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst0Source2 = dispatchPacket0_i[2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+1+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
		`SIZE_CTI_LOG+1];

	inst1Source1 = dispatchPacket1_i[`SIZE_PHYSICAL_LOG+1+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst1Source2 = dispatchPacket1_i[2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+1+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
		`SIZE_CTI_LOG+1];

	inst2Source1 = dispatchPacket2_i[`SIZE_PHYSICAL_LOG+1+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst2Source2 = dispatchPacket2_i[2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+1+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
		`SIZE_CTI_LOG+1];

	inst3Source1 = dispatchPacket3_i[`SIZE_PHYSICAL_LOG+1+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	inst3Source2 = dispatchPacket3_i[2*`SIZE_PHYSICAL_LOG+2+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+1+
		`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
		`SIZE_CTI_LOG+1];

	branch0mask = dispatchPacket0_i[`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:
		`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	branch1mask = dispatchPacket1_i[`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:
		`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	branch2mask = dispatchPacket2_i[`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:
		`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	branch3mask = dispatchPacket3_i[`CHECKPOINTS+`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+
		`LDST_TYPES_LOG+`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:
		`CHECKPOINTS_LOG+4*`SIZE_PHYSICAL_LOG+4+`SIZE_IMMEDIATE+1+`LDST_TYPES_LOG+
		`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];

	/************************************************************************************ 
	 * Index into the Physical Register File valid bit vector to check if the source operand 
	 * is ready, or check the broadcasted RSR tags if there is any match to set the ready bit.
	 * This is the common "If reading a location being written into this cycle, bypass the 
	 * 'being written into' value instead of reading the currently stored value" logic.
	************************************************************************************/
	newInsReady01 = (phyRegRdy_i[inst0Source1[`SIZE_PHYSICAL_LOG:1]] ||
		(inst0Source1 == rsr0Tag_t) || (inst0Source1 == rsr1Tag_t) || (inst0Source1 == rsr2Tag_t) || (inst0Source1 == rsr3Tag_t) || (inst0Source1 == rsr4Tag_t) || (inst0Source1 == rsr5Tag_i)
		 || ~inst0Source1[0]) ? 1'b1:0;

	newInsReady02 = (phyRegRdy_i[inst0Source2[`SIZE_PHYSICAL_LOG:1]] ||
		(inst0Source2 == rsr0Tag_t) || (inst0Source2 == rsr1Tag_t) || (inst0Source2 == rsr2Tag_t) || (inst0Source2 == rsr3Tag_t) || (inst0Source2 == rsr4Tag_t) || (inst0Source2 == rsr5Tag_i)
		 || ~inst0Source2[0]) ? 1'b1:0;

	newInsReady11 = (phyRegRdy_i[inst1Source1[`SIZE_PHYSICAL_LOG:1]] ||
		(inst1Source1 == rsr0Tag_t) || (inst1Source1 == rsr1Tag_t) || (inst1Source1 == rsr2Tag_t) || (inst1Source1 == rsr3Tag_t) || (inst1Source1 == rsr4Tag_t) || (inst1Source1 == rsr5Tag_i)
		 || ~inst1Source1[0]) ? 1'b1:0;

	newInsReady12 = (phyRegRdy_i[inst1Source2[`SIZE_PHYSICAL_LOG:1]] ||
		(inst1Source2 == rsr0Tag_t) || (inst1Source2 == rsr1Tag_t) || (inst1Source2 == rsr2Tag_t) || (inst1Source2 == rsr3Tag_t) || (inst1Source2 == rsr4Tag_t) || (inst1Source2 == rsr5Tag_i)
		 || ~inst1Source2[0]) ? 1'b1:0;

	newInsReady21 = (phyRegRdy_i[inst2Source1[`SIZE_PHYSICAL_LOG:1]] ||
		(inst2Source1 == rsr0Tag_t) || (inst2Source1 == rsr1Tag_t) || (inst2Source1 == rsr2Tag_t) || (inst2Source1 == rsr3Tag_t) || (inst2Source1 == rsr4Tag_t) || (inst2Source1 == rsr5Tag_i)
		 || ~inst2Source1[0]) ? 1'b1:0;

	newInsReady22 = (phyRegRdy_i[inst2Source2[`SIZE_PHYSICAL_LOG:1]] ||
		(inst2Source2 == rsr0Tag_t) || (inst2Source2 == rsr1Tag_t) || (inst2Source2 == rsr2Tag_t) || (inst2Source2 == rsr3Tag_t) || (inst2Source2 == rsr4Tag_t) || (inst2Source2 == rsr5Tag_i)
		 || ~inst2Source2[0]) ? 1'b1:0;

	newInsReady31 = (phyRegRdy_i[inst3Source1[`SIZE_PHYSICAL_LOG:1]] ||
		(inst3Source1 == rsr0Tag_t) || (inst3Source1 == rsr1Tag_t) || (inst3Source1 == rsr2Tag_t) || (inst3Source1 == rsr3Tag_t) || (inst3Source1 == rsr4Tag_t) || (inst3Source1 == rsr5Tag_i)
		 || ~inst3Source1[0]) ? 1'b1:0;

	newInsReady32 = (phyRegRdy_i[inst3Source2[`SIZE_PHYSICAL_LOG:1]] ||
		(inst3Source2 == rsr0Tag_t) || (inst3Source2 == rsr1Tag_t) || (inst3Source2 == rsr2Tag_t) || (inst3Source2 == rsr3Tag_t) || (inst3Source2 == rsr4Tag_t) || (inst3Source2 == rsr5Tag_i)
		 || ~inst3Source2[0]) ? 1'b1:0;

end

/************************************************************************************ 
 * Generate the update_mask vector to unset the SMT id bit in the BRANCH MASK table.
************************************************************************************/
always @(*)
begin: UPDATE_BRANCH_MASK
	integer k;
 
	for(k=0; k<`CHECKPOINTS; k=k+1)
	begin
		if(ctrlVerified_i && (k==ctrlSMTid_i))
			update_mask[k] = 1'b0;
		else
			update_mask[k] = 1'b1;
	end
end


/************************************************************************************ 
* Following updates the Ready bit in the Issue Queue after matching bypassed Tags 
* from RSR.
* Each source's physical tag compares with the 4 bypassed tags to set its Ready bit
*
* On a mispredict, SRC0_REG_VALID and SRC1_REG_VALID arrays must not be affected by the
* dispatch instructions. When not a mispredict, next_src0Ready_normal is the same as
* next_src0Rea_mispre, except that bits of the dispatched instructions are updated
************************************************************************************/
always @(*)
begin: UPDATE_SRC_READY_BIT
	integer i;
	integer j;

	src0RegValid_t1 = 0; 
	src1RegValid_t1 = 0;

	for(j=0;j<`SIZE_ISSUEQ;j=j+1)
	begin
		if(backEndReady_i && (j == freeEntry0))
		begin
			src0RegValid_t1[j]  =  newInsReady01;
			src1RegValid_t1[j]  =  newInsReady02;
		end
		else if(backEndReady_i && (j == freeEntry1) && frontEndWidth_i > 3'd1)
		begin
			src0RegValid_t1[j]  =  newInsReady11;
			src1RegValid_t1[j]  =  newInsReady12;
		end
		else if(backEndReady_i && (j == freeEntry2) && frontEndWidth_i > 3'd2)
		begin
			src0RegValid_t1[j]  =  newInsReady21;
			src1RegValid_t1[j]  =  newInsReady22;
		end
		else if(backEndReady_i && (j == freeEntry3) && frontEndWidth_i > 3'd3)
		begin
			src0RegValid_t1[j]  =  newInsReady31;
			src1RegValid_t1[j]  =  newInsReady32;
		end
		else 
		begin
			src0RegValid_t1[j]  =  src0RegValid_t0[j];
			src1RegValid_t1[j]  =  src1RegValid_t0[j];
		end
	end
end

/************************************************************************************
* Logic to prepare Issue Queue valid array for next cycle during the normal 
* operation, i.e. there is no branch mis-prediction or exception this cycle.
* [i] New Entry position should be set to 1
* [ii] Freed Entry should be set to 0
************************************************************************************/
always @(*)
begin: PREPARE_VALID_ARRAY_NORMAL
	integer i;
	integer k;
	
	reg [`SIZE_ISSUEQ-1:0] issueqValid_tmp;

	issueqValid_tmp     = 0;
	issueqValid_normal  = 0;

	for(i=0; i<`SIZE_ISSUEQ; i=i+1)
	begin
		if(backEndReady_i && ((i == freeEntry0) || ((i == freeEntry1) && frontEndMask[2]) || ((i == freeEntry2) && frontEndMask[1]) || ((i == freeEntry3) && frontEndMask[0])))
			issueqValid_tmp[i] = 1'b1;
		else
			issueqValid_tmp[i] = ISSUEQ_VALID[i];
	end

	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		if((freedValid0 && k == freedEntry0) || (freedValid1 && k == freedEntry1) || (freedValid2 && k == freedEntry2) || (freedValid3 && k == freedEntry3) || (freedValid4 && k == freedEntry4) || (freedValid5 && k == freedEntry5))
			issueqValid_normal[k] = 1'b0;
		else
			issueqValid_normal[k] = issueqValid_tmp[k];
	end
end

/************************************************************************************
* Logic to prepare Issue Queue valid array for next cycle during mis-prediction
* operation.
************************************************************************************/
always @(*)
begin: PREPARE_VALID_ARRAY_MISPRED
	integer i;
	integer k;
	reg [`SIZE_ISSUEQ-1:0] issueqValid_t;

	issueqValid_mispre = 0;
	freedValid_mispre  = 0;

	/* Unset the valid bit of the entries being freed this cycle. */
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		if((freedValid0 && k == freedEntry0) || (freedValid1 && k == freedEntry1) || (freedValid2 && k == freedEntry2) || (freedValid3 && k == freedEntry3) || (freedValid4 && k == freedEntry4) || (freedValid5 && k == freedEntry5))
			issueqValid_t[k] = 1'b0;
		else
			issueqValid_t[k] = ISSUEQ_VALID[k];
	end

	for(i=0; i<`SIZE_ISSUEQ; i=i+1)
	begin
		if(ctrlVerified_i && ctrlMispredict_i)    /* Unnecessary logic? */
		begin
			if(BRANCH_MASK[i][ctrlSMTid_i])
			begin
				issueqValid_mispre[i] = 1'b0;
				if(ISSUEQ_VALID[i]) 
					freedValid_mispre[i]  = 1'b1;
			end
			else
				issueqValid_mispre[i] = issueqValid_t[i];
		end
	end
end

/************************************************************************************
* Logic to prepare Issue Queue scheduled array for next cycle during the normal
* operation, i.e. there is no branch mis-prediction or exception this cycle.
*	[i]  New Entry position should be set to 0
*	[ii] Granted Entry position should be set 1 
************************************************************************************/
always @(*)
begin: PREPARE_SCHEDULE_ARRAY
	integer i;
	reg [`SIZE_ISSUEQ-1:0] issueqSchedule_tmp;	

	issueqSchedule_tmp     = 0;
	issueqSchedule_normal  = 0;

	for(i=0; i<`SIZE_ISSUEQ; i=i+1)
	begin
		if(backEndReady_i && ((i == freeEntry0) || ((i == freeEntry1) && frontEndWidth_i > 3'd1) || ((i == freeEntry2) && frontEndWidth_i > 3'd2) || ((i == freeEntry3) && frontEndWidth_i > 3'd3)))
			issueqSchedule_tmp[i] = 1'b0;
		else
			issueqSchedule_tmp[i] = ISSUEQ_SCHEDULED[i];
	end

	for(i=0; i<`SIZE_ISSUEQ; i=i+1)
	begin
		if((grantedValid0_t && i == grantedEntry0) || (grantedValid1_t && i == grantedEntry1) || (grantedValid2_t && i == grantedEntry2) || (grantedValid3_t && i == grantedEntry3) || (grantedValid4_t && i == grantedEntry4) || (grantedValid5_t && i == grantedEntry5))
			issueqSchedule_normal[i] = 1'b1;
		else
			issueqSchedule_normal[i] = issueqSchedule_tmp[i];
	end
end

/************************************************************************************
*  Update ISSUEQ_VALID and ISSUEQ_SCHEDULED array every cycle. Update is based on
*  the either normal execution or branch mis-prediction.
************************************************************************************/
always @(posedge clk)
begin
	if(reset)
	begin
		ISSUEQ_VALID <= 0;
		ISSUEQ_SCHEDULED <= 0;
	end 
	else
	begin
		if(ctrlVerified_i && ctrlMispredict_i)
		begin
			ISSUEQ_VALID <= issueqValid_mispre;
		end
		else
		begin
			ISSUEQ_VALID <= issueqValid_normal;
		end
	
		ISSUEQ_SCHEDULED <= issueqSchedule_normal;
	end
end

/************************************************************************************
* Writing new instruction into Issue Queue (payload already taken care of by the RAM)
* Write to Issue Queue is made only if backEndReady (from the dispatch) is high 
* and there is no control mis-predict. 
************************************************************************************/
always @(posedge clk)
begin: newInstructions
	integer i;

	if(reset)
	begin
		for(i=0;i<`SIZE_ISSUEQ;i=i+1)
		begin
			ISSUEQ_FU[i] <= 0;
		end
	end
	else
	begin
		if(backEndReady_i && ~(ctrlVerified_i && ctrlMispredict_i))
		begin
			ISSUEQ_FU[freeEntry0] <= dispatchPacket0_i[`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
				`SIZE_CTI_LOG:`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];
      if (frontEndWidth_i > 3'd1) begin 
				ISSUEQ_FU[freeEntry1] <= dispatchPacket1_i[`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
				`SIZE_CTI_LOG:`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];
      end
      if (frontEndWidth_i > 3'd2) begin
			  ISSUEQ_FU[freeEntry2] <= dispatchPacket2_i[`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
				`SIZE_CTI_LOG:`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];
      end
      if (frontEndWidth_i > 3'd3) begin
			  ISSUEQ_FU[freeEntry3] <= dispatchPacket3_i[`INST_TYPES_LOG+`SIZE_OPCODE_I+2*`SIZE_PC+
				`SIZE_CTI_LOG:`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG+1];
      end
		end

		`ifdef VERIFY
		if(freedValid0)
		begin
			ISSUEQ_FU[freedEntry0] <= 0;
		end

		if(freedValid1)
		begin
			ISSUEQ_FU[freedEntry1] <= 0;
		end

		if(freedValid2)
		begin
			ISSUEQ_FU[freedEntry2] <= 0;
		end

		if(freedValid3)
		begin
			ISSUEQ_FU[freedEntry3] <= 0;
		end

		if(freedValid4)
		begin
			ISSUEQ_FU[freedEntry4] <= 0;
		end

		if(freedValid5)
		begin
			ISSUEQ_FU[freedEntry5] <= 0;
		end
		`endif
	end
end

/************************************************************************************ 
* Update the branch mask table every cycle with the new incominig instruction and
* also update it if a branch resolves correctly.
************************************************************************************/ 
always @(posedge clk)
begin:UPDATE_BRANCH_MASK_POSEDGE_CLK
	integer l;

	if(reset)
	begin
		for(l=0; l<`SIZE_ISSUEQ; l=l+1)
		begin
			BRANCH_MASK[l] <= 0;
		end
	end
	else
	begin
		for(l=0;l<`SIZE_ISSUEQ;l=l+1)
		begin
			if(backEndReady_i && (l == freeEntry0))
			begin
				BRANCH_MASK[l] <= branch0mask;
			end
			else if(backEndReady_i && (l == freeEntry1) && frontEndWidth_i > 3'd1)
			begin
				BRANCH_MASK[l] <= branch1mask;
			end
			else if(backEndReady_i && (l == freeEntry2) && frontEndWidth_i > 3'd2)
			begin
				BRANCH_MASK[l] <= branch2mask;
			end
			else if(backEndReady_i && (l == freeEntry3) && frontEndWidth_i > 3'd3)
			begin
				BRANCH_MASK[l] <= branch3mask;
			end
			`ifdef VERIFY
			 else if((freedValid0 && (l == freedEntry0)) || (freedValid1 && (l == freedEntry1)) || (freedValid2 && (l == freedEntry2)) || (freedValid3 && (l == freedEntry3)) || (freedValid4 && (l == freedEntry4)) || (freedValid5 && (l == freedEntry5)))
				BRANCH_MASK[l] <= 0;
			`endif
			else
				BRANCH_MASK[l] <= BRANCH_MASK[l] & update_mask;
		end
	end
end

/************************************************************************************
*  Update SRC0_REG_VALID and SRC1_REG_VALID based on rsrTag match. 
*  Update is based on the either normal execution or branch mis-prediction.
************************************************************************************/
always @(posedge clk)
begin
	if(reset)
	begin
		SRC0_REG_VALID  <= 0;
		SRC1_REG_VALID  <= 0;
	end
	else if(ctrlVerified_i && ctrlMispredict_i)
	begin
		SRC0_REG_VALID  <= src0RegValid_t0;
		SRC1_REG_VALID  <= src1RegValid_t0;
	end
	else
	begin	
		SRC0_REG_VALID  <= src0RegValid_t1;
		SRC1_REG_VALID  <= src1RegValid_t1;	
	end
end

/************************************************************************************ 
*  Logic to select 6 Ready instructions and issue them for execution. For
*  each FU one instruction will be selected. 
************************************************************************************/
/*always @(*) begin: change_param_size
	if (frontEndWidth_i == 3'd2) begin
	    size = 2'd1;
	end
	else size = 2'b0;
end	
*/

/* Following selects 3 instruction(s) of type0 */
always @(*)
begin: preparing_request_vector_for_FU0
	integer k;
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		requestVector0[k] = (ISSUEQ_VALID[k] & ~ISSUEQ_SCHEDULED[k] & SRC0_REG_VALID[k] & SRC1_REG_VALID[k] & (ISSUEQ_FU[k] == 2'b00)) ? 1'b1:1'b0;
	end

end




Select3 select0(.clk(clk),
	.reset(reset),
	.requestVector_i(requestVector0),
	.grantedEntryA_o(grantedEntry0),
	.grantedValidA_o(grantedValid0),
	.grantedEntryB_o(grantedEntry1),
	.grantedValidB_o(grantedValid1),
	.grantedEntryC_o(grantedEntry2),
	.grantedValidC_o(grantedValid2)
);

/* Following selects 1 instruction(s) of type1 */
always @(*)
begin: preparing_request_vector_for_FU1
	integer k;


	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		requestVector1[k] = (ISSUEQ_VALID[k] & ~ISSUEQ_SCHEDULED[k] & SRC0_REG_VALID[k] & SRC1_REG_VALID[k] & (ISSUEQ_FU[k] == 2'b01)) ? 1'b1:1'b0;
	end

end

Select select1(.clk(clk),
	.reset(reset),
	.requestVector_i(requestVector1),
	.grantedEntry_o(grantedEntry3),
	.grantedValid_o(grantedValid3)
);

/* Following selects 1 instruction(s) of type2 */
always @(*)
begin: preparing_request_vector_for_FU2
	integer k;
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		requestVector2[k] = (ISSUEQ_VALID[k] & ~ISSUEQ_SCHEDULED[k] & SRC0_REG_VALID[k] & SRC1_REG_VALID[k] & (ISSUEQ_FU[k] == 2'b10)) ? 1'b1:1'b0;
	end
end

Select select2(.clk(clk),
	.reset(reset),
	.requestVector_i(requestVector2),
	.grantedEntry_o(grantedEntry4),
	.grantedValid_o(grantedValid4)
);

/* Following selects 1 instruction(s) of type3 */
always @(*)
begin: preparing_request_vector_for_FU3
	integer k;
	for(k=0; k<`SIZE_ISSUEQ; k=k+1)
	begin
		requestVector3[k] = (ISSUEQ_VALID[k] & ~ISSUEQ_SCHEDULED[k] & SRC0_REG_VALID[k] & SRC1_REG_VALID[k] & (ISSUEQ_FU[k] == 2'b11)) ? 1'b1:1'b0;
	end


end

Select select3(.clk(clk),
	.reset(reset),
	.requestVector_i(requestVector3),
	.grantedEntry_o(grantedEntry5),
	.grantedValid_o(grantedValid5)
);

/****************************
 * RSR INSIDE ISSUEQ MODULE *
 * *************************/

	assign granted0Dest  = grantedPacket0_t[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
		`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted1Dest  = grantedPacket1_t[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
		`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted2Dest  = grantedPacket2_t[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
		`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted3Dest  = grantedPacket3_t[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
		`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted4Dest  = grantedPacket4_t[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
		`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

	assign granted0Entry = grantedPacket0_t[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted1Entry = grantedPacket1_t[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted2Entry = grantedPacket2_t[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted3Entry = grantedPacket3_t[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
	assign granted4Entry = grantedPacket4_t[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

RSR2 rsr(
	.clk(clk),
	.reset(reset),
	.ctrlVerified_i(ctrlVerified_i),
	.ctrlMispredict_i(ctrlMispredict_i),
	.ctrlSMTid_i(ctrlSMTid_i),
	.validPacket0_i(grantedValid0_t),
	.validPacket1_i(grantedValid1_t),
	.validPacket2_i(grantedValid2_t),
	.validPacket3_i(grantedValid3_t),
	.validPacket4_i(grantedValid4_t),

	.granted0Dest_i(granted0Dest),
	.granted1Dest_i(granted1Dest),
	.granted2Dest_i(granted2Dest),
	.granted3Dest_i(granted3Dest),
	.granted4Dest_i(granted4Dest),

	.branchMask0_i(BRANCH_MASK[grantedEntry0]),
	.branchMask1_i(BRANCH_MASK[grantedEntry1]),
	.branchMask2_i(BRANCH_MASK[grantedEntry2]),
	.branchMask3_i(BRANCH_MASK[grantedEntry3]),
	.branchMask4_i(BRANCH_MASK[grantedEntry4]),

	.rsr0Tag_o(rsr0Tag),   
	.rsr0TagValid_o(rsr0TagValid),
	.rsr1Tag_o(rsr1Tag),   
	.rsr1TagValid_o(rsr1TagValid),
	.rsr2Tag_o(rsr2Tag),   
	.rsr2TagValid_o(rsr2TagValid),
	.rsr3Tag_o(rsr3Tag),   
	.rsr3TagValid_o(rsr3TagValid),
	.rsr4Tag_o(rsr4Tag),   
	.rsr4TagValid_o(rsr4TagValid)

);

endmodule
