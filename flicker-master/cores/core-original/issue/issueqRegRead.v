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
# Purpose: This is the pipeline latch between Issue Queue and Register Read.
# Author:  FabGen
*******************************************************************************/

`timescale 1ns/100ps

module IssueqRegRead(
	input clk,
	input reset,

	/* Payload and Destination of incoming instructions */
	input grantedValid0_i,
	input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket0_i,    
	input grantedValid1_i,
	input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket1_i,    
	input grantedValid2_i,
	input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket2_i,    
	input grantedValid3_i,
	input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket3_i,    
	input grantedValid4_i,
	input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket4_i,    
	input grantedValid5_i,
	input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket5_i,    

	/* Payload and Destination of outgoing instructions */
	output reg grantedValid0_o,
	output reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket0_o,
	output reg grantedValid1_o,
	output reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket1_o,
	output reg grantedValid2_o,
	output reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket2_o,
	output reg grantedValid3_o,
	output reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket3_o,
	output reg grantedValid4_o,
	output reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket4_o,
	output reg grantedValid5_o,
	output reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
		`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
		`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] grantedPacket5_o
);

always @(posedge clk)
begin
	if(reset)
	begin
		grantedValid0_o  <= 0;
		grantedValid1_o  <= 0;
		grantedValid2_o  <= 0;
		grantedValid3_o  <= 0;
		grantedValid4_o  <= 0;
		grantedValid5_o  <= 0;
		grantedPacket0_o <= 0;
		grantedPacket1_o <= 0;
		grantedPacket2_o <= 0;
		grantedPacket3_o <= 0;
		grantedPacket4_o <= 0;
		grantedPacket5_o <= 0;
	end
	else
	begin
		grantedValid0_o  <= grantedValid0_i;
		grantedValid1_o  <= grantedValid1_i;
		grantedValid2_o  <= grantedValid2_i;
		grantedValid3_o  <= grantedValid3_i;
		grantedValid4_o  <= grantedValid4_i;
		grantedValid5_o  <= grantedValid5_i;

		if(grantedValid0_i)
			grantedPacket0_o <= grantedPacket0_i;
		if(grantedValid1_i)
			grantedPacket1_o <= grantedPacket1_i;
		if(grantedValid2_i)
			grantedPacket2_o <= grantedPacket2_i;
		if(grantedValid3_i)
			grantedPacket3_o <= grantedPacket3_i;
		if(grantedValid4_i)
			grantedPacket4_o <= grantedPacket4_i;
		if(grantedValid5_i)
			grantedPacket5_o <= grantedPacket5_i;
	end
end

endmodule
