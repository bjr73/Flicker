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
# Purpose: This module implements pipeline stage between register read and 
#	   execute stage.
# Author:  FabGen
*******************************************************************************/

`timescale 1ns/100ps


module RegReadExecute (
	input clk,
	input reset,
	input [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket0_i,
	input fuPacketValid0_i,
	input [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket1_i,
	input fuPacketValid1_i,
	input [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket2_i,
	input fuPacketValid2_i,
	input [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket3_i,
	input fuPacketValid3_i,
	input [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket4_i,
	input fuPacketValid4_i,
	input [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket5_i,
	input fuPacketValid5_i,

	output reg [`SIZE_IMMEDIATE+`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+
		`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:0] fuPacket0_o,
	output reg fuPacketValid0_o,
	output reg [`SIZE_IMMEDIATE+`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+
		`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:0] fuPacket1_o,
	output reg fuPacketValid1_o,
	output reg [`SIZE_IMMEDIATE+`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+
		`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:0] fuPacket2_o,
	output reg fuPacketValid2_o,
	output reg [`SIZE_IMMEDIATE+`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+
		`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:0] fuPacket3_o,
	output reg fuPacketValid3_o,
	output reg [`SIZE_PC+`SIZE_IMMEDIATE+`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+
		`SIZE_PHYSICAL_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS+
		`CHECKPOINTS_LOG+`SIZE_CTI_LOG+`SIZE_PC:0] fuPacket4_o,
	output reg fuPacketValid4_o,
	output reg [`SIZE_IMMEDIATE+`SIZE_OPCODE_I+2*(`SIZE_DATA+`SIZE_PHYSICAL_LOG)+`SIZE_PHYSICAL_LOG+
		`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`SIZE_ISSUEQ_LOG+`CHECKPOINTS-1:0] fuPacket5_o,
	output reg fuPacketValid5_o
);

reg gr_inst0BrDir, gr_inst1BrDir, gr_inst2BrDir, gr_inst3BrDir, gr_inst4BrDir, gr_inst5BrDir;
reg [`SIZE_CTI_LOG-1:0] gr_inst0CtiqTag, gr_inst1CtiqTag, gr_inst2CtiqTag, gr_inst3CtiqTag, gr_inst4CtiqTag, gr_inst5CtiqTag;
reg [`SIZE_PC-1:0] gr_inst0TarAddr, gr_inst1TarAddr, gr_inst2TarAddr, gr_inst3TarAddr, gr_inst4TarAddr, gr_inst5TarAddr;
reg [`SIZE_PC-1:0] gr_inst0PC, gr_inst1PC, gr_inst2PC, gr_inst3PC, gr_inst4PC, gr_inst5PC;
reg [`SIZE_OPCODE_I-1:0] gr_inst0Opcode, gr_inst1Opcode, gr_inst2Opcode, gr_inst3Opcode, gr_inst4Opcode, gr_inst5Opcode;
reg [`LDST_TYPES_LOG-1:0] gr_inst0LdStType, gr_inst1LdStType, gr_inst2LdStType, gr_inst3LdStType, gr_inst4LdStType, gr_inst5LdStType;
reg [`SIZE_IMMEDIATE-1:0] gr_inst0Immd, gr_inst1Immd, gr_inst2Immd, gr_inst3Immd, gr_inst4Immd, gr_inst5Immd;
reg [`SIZE_PHYSICAL_LOG-1:0] gr_inst0srcReg1, gr_inst1srcReg1, gr_inst2srcReg1, gr_inst3srcReg1, gr_inst4srcReg1, gr_inst5srcReg1;
reg [`SIZE_PHYSICAL_LOG-1:0] gr_inst0srcReg2, gr_inst1srcReg2, gr_inst2srcReg2, gr_inst3srcReg2, gr_inst4srcReg2, gr_inst5srcReg2;
reg [`SIZE_PHYSICAL_LOG-1:0] gr_inst0DestReg, gr_inst1DestReg, gr_inst2DestReg, gr_inst3DestReg, gr_inst4DestReg, gr_inst5DestReg;
reg [`CHECKPOINTS_LOG-1:0] gr_inst0SMTid, gr_inst1SMTid, gr_inst2SMTid, gr_inst3SMTid, gr_inst4SMTid, gr_inst5SMTid;
reg [`CHECKPOINTS-1:0] gr_inst0BranchMask, gr_inst1BranchMask, gr_inst2BranchMask, gr_inst3BranchMask, gr_inst4BranchMask, gr_inst5BranchMask;
reg [`SIZE_ISSUEQ_LOG-1:0] gr_inst0IQentry, gr_inst1IQentry, gr_inst2IQentry, gr_inst3IQentry, gr_inst4IQentry, gr_inst5IQentry;
reg [`SIZE_ACTIVELIST_LOG-1:0] gr_inst0ALid, gr_inst1ALid, gr_inst2ALid, gr_inst3ALid, gr_inst4ALid, gr_inst5ALid;
reg [`SIZE_LSQ_LOG-1:0] gr_inst0LSQid, gr_inst1LSQid, gr_inst2LSQid, gr_inst3LSQid, gr_inst4LSQid, gr_inst5LSQid;
reg [`SIZE_DATA-1:0] gr_inst0Data1, gr_inst1Data1, gr_inst2Data1, gr_inst3Data1, gr_inst4Data1, gr_inst5Data1;
reg [`SIZE_DATA-1:0] gr_inst0Data2, gr_inst1Data2, gr_inst2Data2, gr_inst3Data2, gr_inst4Data2, gr_inst5Data2;

/* Following extracts indivisual information from each granted FU packet. The information is
 * repacked on the need basis for each FU.
 */ 
always @(*)
begin
gr_inst0BrDir        = fuPacket0_i[0];
gr_inst0CtiqTag      = fuPacket0_i[`SIZE_CTI_LOG:1];
gr_inst0TarAddr      = fuPacket0_i[`SIZE_PC+`SIZE_CTI_LOG:`SIZE_CTI_LOG+1];
gr_inst0PC           = fuPacket0_i[2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0Opcode       = fuPacket0_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0LdStType     = fuPacket0_i[`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0Immd         = fuPacket0_i[`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0DestReg      = fuPacket0_i[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0SMTid        = fuPacket0_i[`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0ALid         = fuPacket0_i[`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst0LSQid        = fuPacket0_i[`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0srcReg1      = fuPacket0_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0srcReg2      = fuPacket0_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0IQentry      = fuPacket0_i[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0BranchMask   = fuPacket0_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG:`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst0Data1        = fuPacket0_i[`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst0Data2        = fuPacket0_i[2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

gr_inst1BrDir        = fuPacket1_i[0];
gr_inst1CtiqTag      = fuPacket1_i[`SIZE_CTI_LOG:1];
gr_inst1TarAddr      = fuPacket1_i[`SIZE_PC+`SIZE_CTI_LOG:`SIZE_CTI_LOG+1];
gr_inst1PC           = fuPacket1_i[2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1Opcode       = fuPacket1_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1LdStType     = fuPacket1_i[`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1Immd         = fuPacket1_i[`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1DestReg      = fuPacket1_i[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1SMTid        = fuPacket1_i[`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1ALid         = fuPacket1_i[`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst1LSQid        = fuPacket1_i[`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1srcReg1      = fuPacket1_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1srcReg2      = fuPacket1_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1IQentry      = fuPacket1_i[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1BranchMask   = fuPacket1_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG:`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst1Data1        = fuPacket1_i[`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst1Data2        = fuPacket1_i[2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

gr_inst2BrDir        = fuPacket2_i[0];
gr_inst2CtiqTag      = fuPacket2_i[`SIZE_CTI_LOG:1];
gr_inst2TarAddr      = fuPacket2_i[`SIZE_PC+`SIZE_CTI_LOG:`SIZE_CTI_LOG+1];
gr_inst2PC           = fuPacket2_i[2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2Opcode       = fuPacket2_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2LdStType     = fuPacket2_i[`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2Immd         = fuPacket2_i[`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2DestReg      = fuPacket2_i[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2SMTid        = fuPacket2_i[`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2ALid         = fuPacket2_i[`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst2LSQid        = fuPacket2_i[`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2srcReg1      = fuPacket2_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2srcReg2      = fuPacket2_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2IQentry      = fuPacket2_i[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2BranchMask   = fuPacket2_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG:`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst2Data1        = fuPacket2_i[`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst2Data2        = fuPacket2_i[2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

gr_inst3BrDir        = fuPacket3_i[0];
gr_inst3CtiqTag      = fuPacket3_i[`SIZE_CTI_LOG:1];
gr_inst3TarAddr      = fuPacket3_i[`SIZE_PC+`SIZE_CTI_LOG:`SIZE_CTI_LOG+1];
gr_inst3PC           = fuPacket3_i[2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3Opcode       = fuPacket3_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3LdStType     = fuPacket3_i[`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3Immd         = fuPacket3_i[`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3DestReg      = fuPacket3_i[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3SMTid        = fuPacket3_i[`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3ALid         = fuPacket3_i[`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst3LSQid        = fuPacket3_i[`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3srcReg1      = fuPacket3_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3srcReg2      = fuPacket3_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3IQentry      = fuPacket3_i[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3BranchMask   = fuPacket3_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG:`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst3Data1        = fuPacket3_i[`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst3Data2        = fuPacket3_i[2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

gr_inst4BrDir        = fuPacket4_i[0];
gr_inst4CtiqTag      = fuPacket4_i[`SIZE_CTI_LOG:1];
gr_inst4TarAddr      = fuPacket4_i[`SIZE_PC+`SIZE_CTI_LOG:`SIZE_CTI_LOG+1];
gr_inst4PC           = fuPacket4_i[2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4Opcode       = fuPacket4_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4LdStType     = fuPacket4_i[`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4Immd         = fuPacket4_i[`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4DestReg      = fuPacket4_i[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4SMTid        = fuPacket4_i[`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4ALid         = fuPacket4_i[`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst4LSQid        = fuPacket4_i[`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4srcReg1      = fuPacket4_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4srcReg2      = fuPacket4_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4IQentry      = fuPacket4_i[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4BranchMask   = fuPacket4_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG:`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst4Data1        = fuPacket4_i[`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst4Data2        = fuPacket4_i[2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];

gr_inst5BrDir        = fuPacket5_i[0];
gr_inst5CtiqTag      = fuPacket5_i[`SIZE_CTI_LOG:1];
gr_inst5TarAddr      = fuPacket5_i[`SIZE_PC+`SIZE_CTI_LOG:`SIZE_CTI_LOG+1];
gr_inst5PC           = fuPacket5_i[2*`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5Opcode       = fuPacket5_i[`SIZE_OPCODE_I+2*`SIZE_PC+`SIZE_CTI_LOG:2*`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5LdStType     = fuPacket5_i[`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5Immd         = fuPacket5_i[`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5DestReg      = fuPacket5_i[`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5SMTid        = fuPacket5_i[`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5ALid         = fuPacket5_i[`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst5LSQid        = fuPacket5_i[`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                                   `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5srcReg1      = fuPacket5_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                                   `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5srcReg2      = fuPacket5_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                                   `SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+
                                   `SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5IQentry      = fuPacket5_i[`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                                   `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5BranchMask   = fuPacket5_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG:`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                                   `SIZE_PC+`SIZE_CTI_LOG+1];
gr_inst5Data1        = fuPacket5_i[`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG+1];
gr_inst5Data2        = fuPacket5_i[2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                                   `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+
                                   `SIZE_CTI_LOG:`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                                   `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+
                                   `SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1];
end

/*  Pipeline registers between RegRead and Execute stage.
 */
always @(posedge clk)
begin
	if(reset)
	begin
		fuPacketValid0_o <= 0;
		fuPacket0_o <= 0;
		fuPacketValid1_o <= 0;
		fuPacket1_o <= 0;
		fuPacketValid2_o <= 0;
		fuPacket2_o <= 0;
		fuPacketValid3_o <= 0;
		fuPacket3_o <= 0;
		fuPacketValid4_o <= 0;
		fuPacket4_o <= 0;
		fuPacketValid5_o <= 0;
		fuPacket5_o <= 0;
		end
		else
		begin
		fuPacketValid0_o <= fuPacketValid0_i;
		fuPacketValid1_o <= fuPacketValid1_i;
		fuPacketValid2_o <= fuPacketValid2_i;
		fuPacketValid3_o <= fuPacketValid3_i;
		fuPacketValid4_o <= fuPacketValid4_i;
		fuPacketValid5_o <= fuPacketValid5_i;

		if(fuPacketValid0_i == 1'b1)
		begin
			fuPacket0_o <= {gr_inst0Immd,gr_inst0Opcode,gr_inst0Data2,gr_inst0srcReg2,
				gr_inst0Data1,gr_inst0srcReg1,gr_inst0DestReg,gr_inst0ALid,
				gr_inst0IQentry,gr_inst0BranchMask};
		end

		if(fuPacketValid1_i == 1'b1)
		begin
			fuPacket1_o <= {gr_inst1Immd,gr_inst1Opcode,gr_inst1Data2,gr_inst1srcReg2,
				gr_inst1Data1,gr_inst1srcReg1,gr_inst1DestReg,gr_inst1ALid,
				gr_inst1IQentry,gr_inst1BranchMask};
		end

		if(fuPacketValid2_i == 1'b1)
		begin
			fuPacket2_o <= {gr_inst2Immd,gr_inst2Opcode,gr_inst2Data2,gr_inst2srcReg2,
				gr_inst2Data1,gr_inst2srcReg1,gr_inst2DestReg,gr_inst2ALid,
				gr_inst2IQentry,gr_inst2BranchMask};
		end

		if(fuPacketValid3_i == 1'b1)
		begin
			fuPacket3_o <= {gr_inst3Immd,gr_inst3Opcode,gr_inst3Data2,gr_inst3srcReg2,
				gr_inst3Data1,gr_inst3srcReg1,gr_inst3DestReg,gr_inst3ALid,
				gr_inst3IQentry,gr_inst3BranchMask};
		end

		if(fuPacketValid4_i == 1'b1)
		begin
			fuPacket4_o <= {gr_inst4PC,gr_inst4Immd,gr_inst4Opcode,gr_inst4Data2 ,gr_inst4srcReg2,
				gr_inst4Data1,gr_inst4srcReg1,gr_inst4DestReg,gr_inst4ALid,gr_inst4IQentry,
				gr_inst4BranchMask,gr_inst4SMTid,gr_inst4CtiqTag,gr_inst4TarAddr,gr_inst4BrDir};
		end

		if(fuPacketValid5_i == 1'b1)
		begin
			fuPacket5_o <= {gr_inst5Immd,gr_inst5Opcode,gr_inst5Data2,gr_inst5srcReg2,gr_inst5Data1,
				gr_inst5srcReg1,gr_inst5DestReg,gr_inst5LSQid,gr_inst5ALid,gr_inst5IQentry,gr_inst5BranchMask};
		end

	end
end

endmodule
