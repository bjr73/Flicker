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

/***************************************************************************

  Assumption:  6-instructions can be issued and 
  4(?)-instructions will retire in one cycle from Active List.
	
There are 6 ways and upto 6 issue queue entries
can be freed in a clock cycle.

***************************************************************************/

module IssueQFreeList(
	input clk,
	input reset,

	/* control execution flags from the Writeback Stage. If 
	* ctrlMispredict_i is 1, there has been a mis-predict. */
	input ctrlVerified_i,                    
	input ctrlMispredict_i,
	input [`SIZE_ISSUEQ-1:0] mispredictVector_i,

	input backEndReady_i,

	/* 6 entries being freed once they have been issued. */
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry0_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry1_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry2_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry3_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry4_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry5_i,

	input grantedValid0_i,
	input grantedValid1_i,
	input grantedValid2_i,
	input grantedValid3_i,
	input grantedValid4_i,
	input grantedValid5_i,

	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry0_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry1_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry2_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry3_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry4_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry5_o,

	output freedValid0_o,
	output freedValid1_o,
	output freedValid2_o,
	output freedValid3_o,
	output freedValid4_o,
	output freedValid5_o,

	/* 4 free Issue Queue entries for the new coming 
	* instructions. */
	output [`SIZE_ISSUEQ_LOG-1:0] freeEntry0_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeEntry1_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeEntry2_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeEntry3_o,

/* Count of Valid Issue Q Entries goes to Dispatch */
	output [`SIZE_ISSUEQ_LOG:0] cntInstIssueQ_o
);

/***************************************************************************/
/* Instantiating SPEC FREE LIST Table & head/tail pointers */
reg [`SIZE_ISSUEQ_LOG-1:0] ISSUEQ_FREELIST [`SIZE_ISSUEQ-1:0];
reg [`SIZE_ISSUEQ_LOG-1:0] headPtr;
reg [`SIZE_ISSUEQ_LOG-1:0] tailPtr;

reg [`SIZE_ISSUEQ_LOG:0] issueQCount;	

/* Declaring wires and regs for Combinational Logic */
reg [`SIZE_ISSUEQ_LOG:0] issueQCount_f;
reg [`SIZE_ISSUEQ_LOG-1:0] headptr_f;
reg [`SIZE_ISSUEQ_LOG-1:0] tailptr_f;

integer i;

wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry0;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry1;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry2;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry3;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry4;
wire [`SIZE_ISSUEQ_LOG-1:0] freedEntry5;

wire freedValid0;
wire freedValid1;
wire freedValid2;
wire freedValid3;
wire freedValid4;
wire freedValid5;

wire [`SIZE_ISSUEQ_LOG-1:0] wr_index0;
wire [`SIZE_ISSUEQ_LOG-1:0] wr_index1;
wire [`SIZE_ISSUEQ_LOG-1:0] wr_index2;
wire [`SIZE_ISSUEQ_LOG-1:0] wr_index3;
wire [`SIZE_ISSUEQ_LOG-1:0] wr_index4;
wire [`SIZE_ISSUEQ_LOG-1:0] wr_index5;

reg [`SIZE_ISSUEQ_LOG-1:0] rd_index0;
reg [`SIZE_ISSUEQ_LOG-1:0] rd_index1;
reg [`SIZE_ISSUEQ_LOG-1:0] rd_index2;
reg [`SIZE_ISSUEQ_LOG-1:0] rd_index3;


assign freedValid0_o = freedValid0;
assign freedValid1_o = freedValid1;
assign freedValid2_o = freedValid2;
assign freedValid3_o = freedValid3;
assign freedValid4_o = freedValid4;
assign freedValid5_o = freedValid5;

assign freedEntry0_o = freedEntry0;
assign freedEntry1_o = freedEntry1;
assign freedEntry2_o = freedEntry2;
assign freedEntry3_o = freedEntry3;
assign freedEntry4_o = freedEntry4;
assign freedEntry5_o = freedEntry5;

/* Sending Issue Queue occupied entries to Dispatch. */
assign cntInstIssueQ_o 	= issueQCount;

/* Pops 4 free Issue Queue entries from the FREE LIST for the new coming
* instructions. */
assign freeEntry0_o = ISSUEQ_FREELIST[rd_index0];
assign freeEntry1_o = ISSUEQ_FREELIST[rd_index1];
assign freeEntry2_o = ISSUEQ_FREELIST[rd_index2];
assign freeEntry3_o = ISSUEQ_FREELIST[rd_index3];

/* Generates read addresses for the FREELIST FIFO, using head pointer. */
always @(*)
begin
	rd_index0 = headPtr + 0;
	rd_index1 = headPtr + 1;
	rd_index2 = headPtr + 2;
	rd_index3 = headPtr + 3;
end
always @(*)
begin: ISSUEQ_COUNT
	reg isWrap1;
	reg [`SIZE_ISSUEQ_LOG:0] diff1;
	reg [`SIZE_ISSUEQ_LOG:0] diff2;
	reg [`ISSUE_WIDTH-1:0] totalFreed;

	headptr_f = (backEndReady_i) ? (headPtr+`DISPATCH_WIDTH) : headPtr;
	tailptr_f = (tailPtr + (freedValid5 + freedValid4 + freedValid3 + freedValid2 + freedValid1 + freedValid0));
	totalFreed = (freedValid5 + freedValid4 + freedValid3 + freedValid2 + freedValid1 + freedValid0);
	issueQCount_f = (issueQCount+ ((backEndReady_i) ? `DISPATCH_WIDTH:0)) - totalFreed;
end

/* Following updates the Free List Head Pointer, only if there is no control
* mispredict. */
always @(posedge clk)
begin
	if(reset)
	begin
		headPtr <= 0;
	end
	else
	begin
		if(~ctrlMispredict_i)
			headPtr <= headptr_f;
	end
end


/* Follwoing maintains the issue queue occupancy count each cycle. */
always @(posedge clk)
begin
	if(reset)
	begin
		issueQCount <= 0;
	end
	else
	begin
		issueQCount <= issueQCount_f;
	end
end

/* Following updates the FREE LIST counter and pushes the freed Issue 
*  Queue entry into the FREE LIST. */
assign wr_index0 = tailPtr + 0;
assign wr_index1 = tailPtr + 1;
assign wr_index2 = tailPtr + 2;
assign wr_index3 = tailPtr + 3;
assign wr_index4 = tailPtr + 4;
assign wr_index5 = tailPtr + 5;

always @(posedge clk)
begin: WRITE_FREELIST
	if(reset)
	begin
		for (i=0;i<`SIZE_ISSUEQ;i=i+1)
			ISSUEQ_FREELIST[i] <= i;

		tailPtr <= 0;
	end
	else
	begin
		tailPtr	<= tailptr_f;		

		case({freedValid5, freedValid4, freedValid3, freedValid2, freedValid1, freedValid0})
			6'b000001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
			end
			6'b000010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
			end
			6'b000011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
			end
			6'b000100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
			end
			6'b000101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
			end
			6'b000110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
			end
			6'b000111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
			end
			6'b001000:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry3;
			end
			6'b001001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
			end
			6'b001010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
			end
			6'b001011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
			end
			6'b001100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
			end
			6'b001101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
			end
			6'b001110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
			end
			6'b001111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry3;
			end
			6'b010000:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry4;
			end
			6'b010001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry4;
			end
			6'b010010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry4;
			end
			6'b010011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
			end
			6'b010100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry4;
			end
			6'b010101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
			end
			6'b010110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
			end
			6'b010111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry4;
			end
			6'b011000:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry4;
			end
			6'b011001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
			end
			6'b011010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
			end
			6'b011011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry4;
			end
			6'b011100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
			end
			6'b011101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry4;
			end
			6'b011110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry4;
			end
			6'b011111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index4] <= freedEntry4;
			end
			6'b100000:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry5;
			end
			6'b100001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry5;
			end
			6'b100010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry5;
			end
			6'b100011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b100100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry5;
			end
			6'b100101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b100110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b100111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b101000:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry5;
			end
			6'b101001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b101010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b101011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b101100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b101101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b101110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b101111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index4] <= freedEntry5;
			end
			6'b110000:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry5;
			end
			6'b110001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b110010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b110011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b110100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b110101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b110110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b110111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index4] <= freedEntry5;
			end
			6'b111000:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry5;
			end
			6'b111001:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b111010:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b111011:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index4] <= freedEntry5;
			end
			6'b111100:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry5;
			end
			6'b111101:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index4] <= freedEntry5;
			end
			6'b111110:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index4] <= freedEntry5;
			end
			6'b111111:
			begin
				ISSUEQ_FREELIST[wr_index0] <= freedEntry0;
				ISSUEQ_FREELIST[wr_index1] <= freedEntry1;
				ISSUEQ_FREELIST[wr_index2] <= freedEntry2;
				ISSUEQ_FREELIST[wr_index3] <= freedEntry3;
				ISSUEQ_FREELIST[wr_index4] <= freedEntry4;
				ISSUEQ_FREELIST[wr_index5] <= freedEntry5;
			end
		endcase
	end
end

FreeIssueq freeIq (.clk(clk),
	.reset(reset),
	.ctrlVerified_i(ctrlVerified_i),
	.ctrlMispredict_i(ctrlMispredict_i),
	.mispredictVector_i(mispredictVector_i),
	.grantedEntry0_i(grantedEntry0_i),
	.grantedEntry1_i(grantedEntry1_i),
	.grantedEntry2_i(grantedEntry2_i),
	.grantedEntry3_i(grantedEntry3_i),
	.grantedEntry4_i(grantedEntry4_i),
	.grantedEntry5_i(grantedEntry5_i),

	.grantedValid0_i(grantedValid0_i),
	.grantedValid1_i(grantedValid1_i),
	.grantedValid2_i(grantedValid2_i),
	.grantedValid3_i(grantedValid3_i),
	.grantedValid4_i(grantedValid4_i),
	.grantedValid5_i(grantedValid5_i),

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
	.freedValid5_o(freedValid5)
);

endmodule

module FreeIssueq (
	input clk,
	input reset,
		    
	/* control execution flags from the Writeback Stage. if
	* ctrlMispredict_i is 1, there has been a mis-predict. */
	input ctrlVerified_i,
	input ctrlMispredict_i,
	
	/* mispredicted vector is set of issue queue entries 
	* invalidated due to branch misprediction. These entries
	* should be inserted into issue queue free list. */
	input [`SIZE_ISSUEQ-1:0] mispredictVector_i,

	/* 6 entries being freed once they have been issued. */
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry0_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry1_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry2_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry3_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry4_i,
	input [`SIZE_ISSUEQ_LOG-1:0] grantedEntry5_i,

	input grantedValid0_i,
	input grantedValid1_i,
	input grantedValid2_i,
	input grantedValid3_i,
	input grantedValid4_i,
	input grantedValid5_i,

	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry0_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry1_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry2_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry3_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry4_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freedEntry5_o,

	output freedValid0_o,
	output freedValid1_o,
	output freedValid2_o,
	output freedValid3_o,
	output freedValid4_o,
	output freedValid5_o
);

reg [`SIZE_ISSUEQ-1:0] freedVector;

/* wires and regs declaration for combinational logic. */
reg [`SIZE_ISSUEQ-1:0] freedVector_t;

wire freeingScalar00;
wire freeingScalar01;
wire freeingScalar02;
wire freeingScalar03;
wire freeingScalar04;
wire freeingScalar05;

wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate00;
wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate01;
wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate02;
wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate03;
wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate04;
wire [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate05;

reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry0;
reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry1;
reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry2;
reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry3;
reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry4;
reg [`SIZE_ISSUEQ_LOG-1:0] freedEntry5;

reg freedValid0;
reg freedValid1;
reg freedValid2;
reg freedValid3;
reg freedValid4;
reg freedValid5;

reg [`SIZE_ISSUEQ-1:0] freedVector_t1;

assign freedValid0_o = freedValid0;
assign freedValid1_o = freedValid1;
assign freedValid2_o = freedValid2;
assign freedValid3_o = freedValid3;
assign freedValid4_o = freedValid4;
assign freedValid5_o = freedValid5;

assign freedEntry0_o = freedEntry0;
assign freedEntry1_o = freedEntry1;
assign freedEntry2_o = freedEntry2;
assign freedEntry3_o = freedEntry3;
assign freedEntry4_o = freedEntry4;
assign freedEntry5_o = freedEntry5;

/* Following combinational logic updates the freedValid vector based on:
 *	1. if there are instructions issued this cycle from issue queue 
 *	  (they need to be freed)
 *      2. if there is a branch mispredict this cycle, freedVector need to
 *	   be updated with mispredictVector.
 *	3. if a issue queue entry has been freed this cycle, its corresponding
 *	   bit in the freedVector should be set to 0. */

always @(*)
begin: UPDATE_FREED_VECTOR
	integer i;

	freedValid0 = freeingScalar00;
	freedValid1 = freeingScalar01;
	freedValid2 = freeingScalar02;
	freedValid3 = freeingScalar03;
	freedValid4 = freeingScalar04;
	freedValid5 = freeingScalar05;

	if(freeingScalar00)
		freedEntry0 = 5'd0 + freeingCandidate00;
	else
		freedEntry0 = 5'd0;

	if(freeingScalar01)
		freedEntry1 = 5'd6 + freeingCandidate01;
	else
		freedEntry1 = 5'd0;

	if(freeingScalar02)
		freedEntry2 = 5'd12 + freeingCandidate02;
	else
		freedEntry2 = 5'd0;

	if(freeingScalar03)
		freedEntry3 = 5'd17 + freeingCandidate03;
	else
		freedEntry3 = 5'd0;

	if(freeingScalar04)
		freedEntry4 = 5'd22 + freeingCandidate04;
	else
		freedEntry4 = 5'd0;

	if(freeingScalar05)
		freedEntry5 = 5'd27 + freeingCandidate05;
	else
		freedEntry5 = 5'd0;

	if(ctrlMispredict_i)
		freedVector_t1 = freedVector | mispredictVector_i;
	else
		freedVector_t1 = freedVector;
		
	for(i=0;i<`SIZE_ISSUEQ;i=i+1)	
	begin
		if((grantedValid0_i && (i == grantedEntry0_i)) ||
		(grantedValid1_i && (i == grantedEntry1_i)) ||
		(grantedValid2_i && (i == grantedEntry2_i)) ||
		(grantedValid3_i && (i == grantedEntry3_i)) ||
		(grantedValid4_i && (i == grantedEntry4_i)) ||
		(grantedValid5_i && (i == grantedEntry5_i)))
			freedVector_t[i] = 1'b1;
		else if((freedValid0 && (i == freedEntry0)) ||
		(freedValid1 && (i == freedEntry1)) ||
		(freedValid2 && (i == freedEntry2)) ||
		(freedValid3 && (i == freedEntry3)) ||
		(freedValid4 && (i == freedEntry4)) ||
		(freedValid5 && (i == freedEntry5)))
			freedVector_t[i] = 1'b0;
		else
			freedVector_t[i] = freedVector_t1[i];
	end
end

/* Following writes newly computed freed vector to freedVector register every cycle. */
always @(posedge clk)
begin
	if(reset)
	begin
		freedVector <= 0;
	end
	else
	begin
		freedVector <= freedVector_t;
	end	 	
end

/* Following instantiate "selectFromBlock" module to get upto 6 freed issue queue
 * entries this cycle. */
selectFromBlock_1 selectFromBlock00_l1(.blockVector_i(freedVector[5:0]),
	.freeingScalar_o(freeingScalar00),
	.freeingCandidate_o(freeingCandidate00)
);

selectFromBlock_1 selectFromBlock01_l1(.blockVector_i(freedVector[11:6]),
	.freeingScalar_o(freeingScalar01),
	.freeingCandidate_o(freeingCandidate01)
);

selectFromBlock_0 selectFromBlock02_l1(.blockVector_i(freedVector[16:12]),
	.freeingScalar_o(freeingScalar02),
	.freeingCandidate_o(freeingCandidate02)
);

selectFromBlock_0 selectFromBlock03_l1(.blockVector_i(freedVector[21:17]),
	.freeingScalar_o(freeingScalar03),
	.freeingCandidate_o(freeingCandidate03)
);

selectFromBlock_0 selectFromBlock04_l1(.blockVector_i(freedVector[26:22]),
	.freeingScalar_o(freeingScalar04),
	.freeingCandidate_o(freeingCandidate04)
);

selectFromBlock_0 selectFromBlock05_l1(.blockVector_i(freedVector[31:27]),
	.freeingScalar_o(freeingScalar05),
	.freeingCandidate_o(freeingCandidate05)
);

endmodule


module selectFromBlock_1(input [5:0] blockVector_i,
	output freeingScalar_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate_o   			
);

reg freeingScalar;
reg [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate;

assign freeingCandidate_o = freeingCandidate;
assign freeingScalar_o = freeingScalar;

always @(*)
begin:FIND_FREEING_CANDIDATE_0
	casex({blockVector_i[5], blockVector_i[4], blockVector_i[3], blockVector_i[2], blockVector_i[1], blockVector_i[0]})
		6'bxxxxx1:
		begin
			freeingCandidate = 5'b00000;
			freeingScalar = 1'b1;
		end
		6'bxxxx10:
		begin
			freeingCandidate = 5'b00001;
			freeingScalar = 1'b1;
		end
		6'bxxx100:
		begin
			freeingCandidate = 5'b00010;
			freeingScalar = 1'b1;
		end
		6'bxx1000:
		begin
			freeingCandidate = 5'b00011;
			freeingScalar = 1'b1;
		end
		6'bx10000:
		begin
			freeingCandidate = 5'b00100;
			freeingScalar = 1'b1;
		end
		6'b100000:
		begin
			freeingCandidate = 5'b00101;
			freeingScalar = 1'b1;
		end
 		default:
 		begin
  			freeingCandidate = 0;
  			freeingScalar = 0;
  		end
	endcase
end

endmodule


module selectFromBlock_0(input [4:0] blockVector_i,
	output freeingScalar_o,
	output [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate_o   			
);

reg freeingScalar;
reg [`SIZE_ISSUEQ_LOG-1:0] freeingCandidate;

assign freeingCandidate_o = freeingCandidate;
assign freeingScalar_o = freeingScalar;

always @(*)
begin:FIND_FREEING_CANDIDATE_1
	casex({blockVector_i[4], blockVector_i[3], blockVector_i[2], blockVector_i[1], blockVector_i[0]})
		5'bxxxx1:
		begin
			freeingCandidate = 5'b00000;
			freeingScalar = 1'b1;
		end
		5'bxxx10:
		begin
			freeingCandidate = 5'b00001;
			freeingScalar = 1'b1;
		end
		5'bxx100:
		begin
			freeingCandidate = 5'b00010;
			freeingScalar = 1'b1;
		end
		5'bx1000:
		begin
			freeingCandidate = 5'b00011;
			freeingScalar = 1'b1;
		end
		5'b10000:
		begin
			freeingCandidate = 5'b00100;
			freeingScalar = 1'b1;
		end
 		default:
 		begin
  			freeingCandidate = 0;
  			freeingScalar = 0;
  		end
	endcase
end

endmodule

