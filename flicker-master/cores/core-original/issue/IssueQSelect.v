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
# Purpose: 32:1 select tree made out of 8:1 select blocks.
# Author:  FabGen
*******************************************************************************/

`timescale 1ns/100ps


module Select(input wire clk,
	input wire reset,
	input wire [`SIZE_ISSUEQ-1:0] requestVector_i,
	input wire grant_i,									/* Enable signal for the select tree */

	output wire grantedValid_o,
	output wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntry_o,	/* Encoded form of grantedVector_o */
	output wire [`SIZE_ISSUEQ-1:0] grantedVector_o	 	/* One-hot grant vector */
);

/* Wires and regs for the combinational logic */
/* Wires for outputs */
wire [`SIZE_ISSUEQ-1:0] grantedVector;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntry;

/* reqOut signals propagating forwards from the back of the select tree to the front */
wire reqOut_u0_0;
wire reqOut_u0_1;
wire reqOut_u0_2;
wire reqOut_u0_3;

wire reqOut_u1_0;

/* grantIn signals propagating backwards from the front of the select tree */
wire grantIn_u0_0;
wire grantIn_u0_1;
wire grantIn_u0_2;
wire grantIn_u0_3;

wire grantIn_u1_0;

/* Assign enable signal */
assign grantIn_u1_0 = grant_i | 1'b1; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< TEMPORARY FIX 

/* Assign outputs */
assign grantedValid_o = reqOut_u1_0;
assign grantedVector_o = grantedVector;
assign grantedEntry_o = grantedEntry;

integer i;

/* Instantiate the encoder */
Encoder #(`SIZE_ISSUEQ, `SIZE_ISSUEQ_LOG) grantEncoder(.vector_i(grantedVector),
	.encoded_o(grantedEntry)
);

/******************************************
* Stage 0 (deals with 32 -> 4 conversion) *
******************************************/

/* Stage 0, select block 0 */
selectBlock_8 U0_0(.req0_i(requestVector_i[0]),
	.req1_i(requestVector_i[1]),
	.req2_i(requestVector_i[2]),
	.req3_i(requestVector_i[3]),
	.req4_i(requestVector_i[4]),
	.req5_i(requestVector_i[5]),
	.req6_i(requestVector_i[6]),
	.req7_i(requestVector_i[7]),
	.grant_i(grantIn_u0_0),
	.grant0_o(grantedVector[0]),
	.grant1_o(grantedVector[1]),
	.grant2_o(grantedVector[2]),
	.grant3_o(grantedVector[3]),
	.grant4_o(grantedVector[4]),
	.grant5_o(grantedVector[5]),
	.grant6_o(grantedVector[6]),
	.grant7_o(grantedVector[7]),
	.req_o(reqOut_u0_0)
);

/* Stage 0, select block 1 */
selectBlock_8 U0_1(.req0_i(requestVector_i[8]),
	.req1_i(requestVector_i[9]),
	.req2_i(requestVector_i[10]),
	.req3_i(requestVector_i[11]),
	.req4_i(requestVector_i[12]),
	.req5_i(requestVector_i[13]),
	.req6_i(requestVector_i[14]),
	.req7_i(requestVector_i[15]),
	.grant_i(grantIn_u0_1),
	.grant0_o(grantedVector[8]),
	.grant1_o(grantedVector[9]),
	.grant2_o(grantedVector[10]),
	.grant3_o(grantedVector[11]),
	.grant4_o(grantedVector[12]),
	.grant5_o(grantedVector[13]),
	.grant6_o(grantedVector[14]),
	.grant7_o(grantedVector[15]),
	.req_o(reqOut_u0_1)
);

/* Stage 0, select block 2 */
selectBlock_8 U0_2(.req0_i(requestVector_i[16]),
	.req1_i(requestVector_i[17]),
	.req2_i(requestVector_i[18]),
	.req3_i(requestVector_i[19]),
	.req4_i(requestVector_i[20]),
	.req5_i(requestVector_i[21]),
	.req6_i(requestVector_i[22]),
	.req7_i(requestVector_i[23]),
	.grant_i(grantIn_u0_2),
	.grant0_o(grantedVector[16]),
	.grant1_o(grantedVector[17]),
	.grant2_o(grantedVector[18]),
	.grant3_o(grantedVector[19]),
	.grant4_o(grantedVector[20]),
	.grant5_o(grantedVector[21]),
	.grant6_o(grantedVector[22]),
	.grant7_o(grantedVector[23]),
	.req_o(reqOut_u0_2)
);

/* Stage 0, select block 3 */
selectBlock_8 U0_3(.req0_i(requestVector_i[24]),
	.req1_i(requestVector_i[25]),
	.req2_i(requestVector_i[26]),
	.req3_i(requestVector_i[27]),
	.req4_i(requestVector_i[28]),
	.req5_i(requestVector_i[29]),
	.req6_i(requestVector_i[30]),
	.req7_i(requestVector_i[31]),
	.grant_i(grantIn_u0_3),
	.grant0_o(grantedVector[24]),
	.grant1_o(grantedVector[25]),
	.grant2_o(grantedVector[26]),
	.grant3_o(grantedVector[27]),
	.grant4_o(grantedVector[28]),
	.grant5_o(grantedVector[29]),
	.grant6_o(grantedVector[30]),
	.grant7_o(grantedVector[31]),
	.req_o(reqOut_u0_3)
);


/******************************************
* Stage 1 (deals with 4 -> 1 conversion) *
******************************************/

/* Stage 1, select block 0 */
selectBlock_4 U1_0(.req0_i(reqOut_u0_0),
	.req1_i(reqOut_u0_1),
	.req2_i(reqOut_u0_2),
	.req3_i(reqOut_u0_3),
	.grant_i(grantIn_u1_0),
	.grant0_o(grantIn_u0_0),
	.grant1_o(grantIn_u0_1),
	.grant2_o(grantIn_u0_2),
	.grant3_o(grantIn_u0_3),
	.req_o(reqOut_u1_0)
);

endmodule


module selectBlock_8(
	input wire req0_i,
	input wire req1_i,
	input wire req2_i,
	input wire req3_i,
	input wire req4_i,
	input wire req5_i,
	input wire req6_i,
	input wire req7_i,

	/* The grant signal coming in from the next stage of the select tree */
	input wire grant_i,

	output wire grant0_o,
	output wire grant1_o,
	output wire grant2_o,
	output wire grant3_o,
	output wire grant4_o,
	output wire grant5_o,
	output wire grant6_o,
	output wire grant7_o,

	/* OR of the request signals, used as req_i for next stage of the select tree */
	output wire req_o
);

/* Wires and registers for combinatinal logic */
wire [7:0] req;
wire [7:0] grant;

/* Code to deal with vectors instead of individual wires */
assign req = {req7_i, req6_i, req5_i, req4_i, req3_i, req2_i, req1_i, req0_i};

/* Gate the current grant output with the grant_i from the next stage of the select tree */
assign grant0_o = grant[0] & grant_i;
assign grant1_o = grant[1] & grant_i;
assign grant2_o = grant[2] & grant_i;
assign grant3_o = grant[3] & grant_i;
assign grant4_o = grant[4] & grant_i;
assign grant5_o = grant[5] & grant_i;
assign grant6_o = grant[6] & grant_i;
assign grant7_o = grant[7] & grant_i;

/* Create the OR gate */
assign req_o = |req;

/* Create the priority logic */
PriorityEncoder #(8) selectBlockPEncoder(
	.vector_i(req),
	.vector_o(grant)
);

endmodule


module selectBlock_4(
	input wire req0_i,
	input wire req1_i,
	input wire req2_i,
	input wire req3_i,

	/* The grant signal coming in from the next stage of the select tree */
	input wire grant_i,

	output wire grant0_o,
	output wire grant1_o,
	output wire grant2_o,
	output wire grant3_o,

	/* OR of the request signals, used as req_i for next stage of the select tree */
	output wire req_o
);

/* Wires and registers for combinatinal logic */
wire [3:0] req;
wire [3:0] grant;

/* Code to deal with vectors instead of individual wires */
assign req = {req3_i, req2_i, req1_i, req0_i};

/* Gate the current grant output with the grant_i from the next stage of the select tree */
assign grant0_o = grant[0] & grant_i;
assign grant1_o = grant[1] & grant_i;
assign grant2_o = grant[2] & grant_i;
assign grant3_o = grant[3] & grant_i;

/* Create the OR gate */
assign req_o = |req;

/* Create the priority logic */
PriorityEncoder #(4) selectBlockPEncoder(
	.vector_i(req),
	.vector_o(grant)
);

endmodule


module Encoder(vector_i,
	encoded_o
);

parameter ENCODER_WIDTH = 32;
parameter ENCODER_WIDTH_LOG = 5;

/* I/O definitions */
input wire [ENCODER_WIDTH-1:0] vector_i;
output wire [ENCODER_WIDTH_LOG-1:0] encoded_o;

/* Temporary regs and wires */
reg [ENCODER_WIDTH_LOG-1:0] s [ENCODER_WIDTH-1:0]; // Stores number itself. 
reg [ENCODER_WIDTH_LOG-1:0] t [ENCODER_WIDTH-1:0]; // Stores (s[i] if vector[i]==1'b1 else stores 0)
reg [ENCODER_WIDTH-1:0] u [ENCODER_WIDTH_LOG-1:0]; // Stores transpose of t (to use the | operator)

/* Wires and regs for combinational logic */
reg [ENCODER_WIDTH-1:0] compareVector;

/* Wires for outputs */
reg [ENCODER_WIDTH_LOG-1:0] encoded;

/* Assign outputs */
assign encoded_o = encoded;

integer i;
integer j;

always @(*)
begin: ENCODER_CONSTRUCT
	for(i=0; i<ENCODER_WIDTH; i=i+1)
	begin
		s[i] = i;
	end

	for(i=0; i<ENCODER_WIDTH; i=i+1)
	begin
		if(vector_i[i] == 1'b1)
			t[i] = s[i];
		else
			t[i] = 0;
	end

	for(i=0; i<ENCODER_WIDTH; i=i+1)
	begin
		for(j=0; j<ENCODER_WIDTH_LOG; j=j+1)
		begin
			u[j][i] = t[i][j];
		end
	end

	for(j=0; j<ENCODER_WIDTH_LOG; j=j+1)
	begin
		encoded[j] = |u[j];
	end
end

endmodule


module PriorityEncoder(vector_i,
	vector_o
);

parameter ENCODER_WIDTH = 32;

/* I/O definitions */
input wire [ENCODER_WIDTH-1:0] vector_i;
output wire [ENCODER_WIDTH-1:0] vector_o;

/* Wires and regs for combinational logic */

/* Mask to reset all other bits except the first */
reg [ENCODER_WIDTH-1:0] mask;

/* Wires for outputs */
wire [ENCODER_WIDTH-1:0] vector;

/* Assign outputs */
assign vector_o = vector;

/* Mask the input vector so that only the first 1'b1 is seen */
assign vector = vector_i & mask;

integer j;

always @(*)
begin: ENCODER_CONSTRUCT
	mask[0] = 1'b1;

	for(j=1; j<ENCODER_WIDTH; j=j+1)
	begin
		if(vector_i[j-1] == 1'b1)
			mask[j] = 0;
		else
			mask[j] = mask[j-1];
	end
end

endmodule


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
# Purpose: This module implements CASCADED select tree made out of 8:3 select 
#	   blocks
# Author:  FabGen
*******************************************************************************/

`timescale 1ns/100ps


module Select3(input wire clk,
	input wire reset,
	input wire [`SIZE_ISSUEQ-1:0] requestVector_i,
	input wire grantA_i,
	input wire grantB_i,
	input wire grantC_i,

	output wire grantedValidA_o,
	output wire grantedValidB_o,
	output wire grantedValidC_o,
	output wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntryA_o,
	output wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntryB_o,
	output wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntryC_o,
	output wire [`SIZE_ISSUEQ-1:0] grantedVectorA_o,
	output wire [`SIZE_ISSUEQ-1:0] grantedVectorB_o,
	output wire [`SIZE_ISSUEQ-1:0] grantedVectorC_o
);

/* Wires and regs for the combinational logic */
/* Wires for outputs */
wire [`SIZE_ISSUEQ-1:0] grantedVectorA;
wire [`SIZE_ISSUEQ-1:0] grantedVectorB;
wire [`SIZE_ISSUEQ-1:0] grantedVectorC;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntryA;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntryB;
wire [`SIZE_ISSUEQ_LOG-1:0] grantedEntryC;

/* reqOut signals propagating forwards from the back of the select tree to the front */
wire reqOutA_u0_0;
wire reqOutA_u0_1;
wire reqOutA_u0_2;
wire reqOutA_u0_3;
wire reqOutB_u0_0;
wire reqOutB_u0_1;
wire reqOutB_u0_2;
wire reqOutB_u0_3;
wire reqOutC_u0_0;
wire reqOutC_u0_1;
wire reqOutC_u0_2;
wire reqOutC_u0_3;

wire reqOutA_u1_0;
wire reqOutB_u1_0;
wire reqOutC_u1_0;

/* grantIn signals propagating backwards from the front of the select tree */
wire grantInA_u0_0;
wire grantInA_u0_1;
wire grantInA_u0_2;
wire grantInA_u0_3;
wire grantInB_u0_0;
wire grantInB_u0_1;
wire grantInB_u0_2;
wire grantInB_u0_3;
wire grantInC_u0_0;
wire grantInC_u0_1;
wire grantInC_u0_2;
wire grantInC_u0_3;

wire grantInA_u1_0;
wire grantInB_u1_0;
wire grantInC_u1_0;

/* Assign enable signal */
//assign grantInA_u1_0 = grantA_i
assign grantInA_u1_0 = 1'b1; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< TEMPORARY FIX
//assign grantInB_u1_0 = grantB_i
assign grantInB_u1_0 = 1'b1; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< TEMPORARY FIX
//assign grantInC_u1_0 = grantC_i
assign grantInC_u1_0 = 1'b1; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< TEMPORARY FIX

/* Assign outputs */
assign grantedValidA_o = reqOutA_u1_0;
assign grantedValidB_o = reqOutB_u1_0;
assign grantedValidC_o = reqOutC_u1_0;
assign grantedVectorA_o = grantedVectorA;
assign grantedVectorB_o = grantedVectorB;
assign grantedVectorC_o = grantedVectorC;
assign grantedEntryA_o = grantedEntryA;
assign grantedEntryB_o = grantedEntryB;
assign grantedEntryC_o = grantedEntryC;

integer i;

/* Instantiate the encoder */
Encoder #(`SIZE_ISSUEQ, `SIZE_ISSUEQ_LOG) grantEncoderA(.vector_i(grantedVectorA),
	.encoded_o(grantedEntryA)
);

Encoder #(`SIZE_ISSUEQ, `SIZE_ISSUEQ_LOG) grantEncoderB(.vector_i(grantedVectorB),
	.encoded_o(grantedEntryB)
);

Encoder #(`SIZE_ISSUEQ, `SIZE_ISSUEQ_LOG) grantEncoderC(.vector_i(grantedVectorC),
	.encoded_o(grantedEntryC)
);

/******************************************
* Stage 0 (deals with 32 -> 12 conversion) *
******************************************/

/* Stage 0, select block 0 */
cascadedSelectBlock_c3_8 U0_0(
	.reqA0_i(requestVector_i[0]),
	.reqA1_i(requestVector_i[1]),
	.reqA2_i(requestVector_i[2]),
	.reqA3_i(requestVector_i[3]),
	.reqA4_i(requestVector_i[4]),
	.reqA5_i(requestVector_i[5]),
	.reqA6_i(requestVector_i[6]),
	.reqA7_i(requestVector_i[7]),
	.reqB0_i(1'b0),
	.reqB1_i(1'b0),
	.reqB2_i(1'b0),
	.reqB3_i(1'b0),
	.reqB4_i(1'b0),
	.reqB5_i(1'b0),
	.reqB6_i(1'b0),
	.reqB7_i(1'b0),
	.reqC0_i(1'b0),
	.reqC1_i(1'b0),
	.reqC2_i(1'b0),
	.reqC3_i(1'b0),
	.reqC4_i(1'b0),
	.reqC5_i(1'b0),
	.reqC6_i(1'b0),
	.reqC7_i(1'b0),

	.grantA_i(grantInA_u0_0),
	.grantB_i(grantInB_u0_0),
	.grantC_i(grantInC_u0_0),

	.grantA0_o(grantedVectorA[0]),
	.grantA1_o(grantedVectorA[1]),
	.grantA2_o(grantedVectorA[2]),
	.grantA3_o(grantedVectorA[3]),
	.grantA4_o(grantedVectorA[4]),
	.grantA5_o(grantedVectorA[5]),
	.grantA6_o(grantedVectorA[6]),
	.grantA7_o(grantedVectorA[7]),
	.grantB0_o(grantedVectorB[0]),
	.grantB1_o(grantedVectorB[1]),
	.grantB2_o(grantedVectorB[2]),
	.grantB3_o(grantedVectorB[3]),
	.grantB4_o(grantedVectorB[4]),
	.grantB5_o(grantedVectorB[5]),
	.grantB6_o(grantedVectorB[6]),
	.grantB7_o(grantedVectorB[7]),
	.grantC0_o(grantedVectorC[0]),
	.grantC1_o(grantedVectorC[1]),
	.grantC2_o(grantedVectorC[2]),
	.grantC3_o(grantedVectorC[3]),
	.grantC4_o(grantedVectorC[4]),
	.grantC5_o(grantedVectorC[5]),
	.grantC6_o(grantedVectorC[6]),
	.grantC7_o(grantedVectorC[7]),

	.reqA_o(reqOutA_u0_0),
	.reqB_o(reqOutB_u0_0),
	.reqC_o(reqOutC_u0_0)
);

/* Stage 0, select block 1 */
cascadedSelectBlock_c3_8 U0_1(
	.reqA0_i(requestVector_i[8]),
	.reqA1_i(requestVector_i[9]),
	.reqA2_i(requestVector_i[10]),
	.reqA3_i(requestVector_i[11]),
	.reqA4_i(requestVector_i[12]),
	.reqA5_i(requestVector_i[13]),
	.reqA6_i(requestVector_i[14]),
	.reqA7_i(requestVector_i[15]),
	.reqB0_i(1'b0),
	.reqB1_i(1'b0),
	.reqB2_i(1'b0),
	.reqB3_i(1'b0),
	.reqB4_i(1'b0),
	.reqB5_i(1'b0),
	.reqB6_i(1'b0),
	.reqB7_i(1'b0),
	.reqC0_i(1'b0),
	.reqC1_i(1'b0),
	.reqC2_i(1'b0),
	.reqC3_i(1'b0),
	.reqC4_i(1'b0),
	.reqC5_i(1'b0),
	.reqC6_i(1'b0),
	.reqC7_i(1'b0),

	.grantA_i(grantInA_u0_1),
	.grantB_i(grantInB_u0_1),
	.grantC_i(grantInC_u0_1),

	.grantA0_o(grantedVectorA[8]),
	.grantA1_o(grantedVectorA[9]),
	.grantA2_o(grantedVectorA[10]),
	.grantA3_o(grantedVectorA[11]),
	.grantA4_o(grantedVectorA[12]),
	.grantA5_o(grantedVectorA[13]),
	.grantA6_o(grantedVectorA[14]),
	.grantA7_o(grantedVectorA[15]),
	.grantB0_o(grantedVectorB[8]),
	.grantB1_o(grantedVectorB[9]),
	.grantB2_o(grantedVectorB[10]),
	.grantB3_o(grantedVectorB[11]),
	.grantB4_o(grantedVectorB[12]),
	.grantB5_o(grantedVectorB[13]),
	.grantB6_o(grantedVectorB[14]),
	.grantB7_o(grantedVectorB[15]),
	.grantC0_o(grantedVectorC[8]),
	.grantC1_o(grantedVectorC[9]),
	.grantC2_o(grantedVectorC[10]),
	.grantC3_o(grantedVectorC[11]),
	.grantC4_o(grantedVectorC[12]),
	.grantC5_o(grantedVectorC[13]),
	.grantC6_o(grantedVectorC[14]),
	.grantC7_o(grantedVectorC[15]),

	.reqA_o(reqOutA_u0_1),
	.reqB_o(reqOutB_u0_1),
	.reqC_o(reqOutC_u0_1)
);

/* Stage 0, select block 2 */
cascadedSelectBlock_c3_8 U0_2(
	.reqA0_i(requestVector_i[16]),
	.reqA1_i(requestVector_i[17]),
	.reqA2_i(requestVector_i[18]),
	.reqA3_i(requestVector_i[19]),
	.reqA4_i(requestVector_i[20]),
	.reqA5_i(requestVector_i[21]),
	.reqA6_i(requestVector_i[22]),
	.reqA7_i(requestVector_i[23]),
	.reqB0_i(1'b0),
	.reqB1_i(1'b0),
	.reqB2_i(1'b0),
	.reqB3_i(1'b0),
	.reqB4_i(1'b0),
	.reqB5_i(1'b0),
	.reqB6_i(1'b0),
	.reqB7_i(1'b0),
	.reqC0_i(1'b0),
	.reqC1_i(1'b0),
	.reqC2_i(1'b0),
	.reqC3_i(1'b0),
	.reqC4_i(1'b0),
	.reqC5_i(1'b0),
	.reqC6_i(1'b0),
	.reqC7_i(1'b0),

	.grantA_i(grantInA_u0_2),
	.grantB_i(grantInB_u0_2),
	.grantC_i(grantInC_u0_2),

	.grantA0_o(grantedVectorA[16]),
	.grantA1_o(grantedVectorA[17]),
	.grantA2_o(grantedVectorA[18]),
	.grantA3_o(grantedVectorA[19]),
	.grantA4_o(grantedVectorA[20]),
	.grantA5_o(grantedVectorA[21]),
	.grantA6_o(grantedVectorA[22]),
	.grantA7_o(grantedVectorA[23]),
	.grantB0_o(grantedVectorB[16]),
	.grantB1_o(grantedVectorB[17]),
	.grantB2_o(grantedVectorB[18]),
	.grantB3_o(grantedVectorB[19]),
	.grantB4_o(grantedVectorB[20]),
	.grantB5_o(grantedVectorB[21]),
	.grantB6_o(grantedVectorB[22]),
	.grantB7_o(grantedVectorB[23]),
	.grantC0_o(grantedVectorC[16]),
	.grantC1_o(grantedVectorC[17]),
	.grantC2_o(grantedVectorC[18]),
	.grantC3_o(grantedVectorC[19]),
	.grantC4_o(grantedVectorC[20]),
	.grantC5_o(grantedVectorC[21]),
	.grantC6_o(grantedVectorC[22]),
	.grantC7_o(grantedVectorC[23]),

	.reqA_o(reqOutA_u0_2),
	.reqB_o(reqOutB_u0_2),
	.reqC_o(reqOutC_u0_2)
);

/* Stage 0, select block 3 */
cascadedSelectBlock_c3_8 U0_3(
	.reqA0_i(requestVector_i[24]),
	.reqA1_i(requestVector_i[25]),
	.reqA2_i(requestVector_i[26]),
	.reqA3_i(requestVector_i[27]),
	.reqA4_i(requestVector_i[28]),
	.reqA5_i(requestVector_i[29]),
	.reqA6_i(requestVector_i[30]),
	.reqA7_i(requestVector_i[31]),
	.reqB0_i(1'b0),
	.reqB1_i(1'b0),
	.reqB2_i(1'b0),
	.reqB3_i(1'b0),
	.reqB4_i(1'b0),
	.reqB5_i(1'b0),
	.reqB6_i(1'b0),
	.reqB7_i(1'b0),
	.reqC0_i(1'b0),
	.reqC1_i(1'b0),
	.reqC2_i(1'b0),
	.reqC3_i(1'b0),
	.reqC4_i(1'b0),
	.reqC5_i(1'b0),
	.reqC6_i(1'b0),
	.reqC7_i(1'b0),

	.grantA_i(grantInA_u0_3),
	.grantB_i(grantInB_u0_3),
	.grantC_i(grantInC_u0_3),

	.grantA0_o(grantedVectorA[24]),
	.grantA1_o(grantedVectorA[25]),
	.grantA2_o(grantedVectorA[26]),
	.grantA3_o(grantedVectorA[27]),
	.grantA4_o(grantedVectorA[28]),
	.grantA5_o(grantedVectorA[29]),
	.grantA6_o(grantedVectorA[30]),
	.grantA7_o(grantedVectorA[31]),
	.grantB0_o(grantedVectorB[24]),
	.grantB1_o(grantedVectorB[25]),
	.grantB2_o(grantedVectorB[26]),
	.grantB3_o(grantedVectorB[27]),
	.grantB4_o(grantedVectorB[28]),
	.grantB5_o(grantedVectorB[29]),
	.grantB6_o(grantedVectorB[30]),
	.grantB7_o(grantedVectorB[31]),
	.grantC0_o(grantedVectorC[24]),
	.grantC1_o(grantedVectorC[25]),
	.grantC2_o(grantedVectorC[26]),
	.grantC3_o(grantedVectorC[27]),
	.grantC4_o(grantedVectorC[28]),
	.grantC5_o(grantedVectorC[29]),
	.grantC6_o(grantedVectorC[30]),
	.grantC7_o(grantedVectorC[31]),

	.reqA_o(reqOutA_u0_3),
	.reqB_o(reqOutB_u0_3),
	.reqC_o(reqOutC_u0_3)
);


/******************************************
* Stage 1 (deals with 12 -> 3 conversion) *
******************************************/

/* Stage 1, select block 0 */
cascadedSelectBlock_c3_4 U1_0(
	.reqA0_i(reqOutA_u0_0),
	.reqA1_i(reqOutA_u0_1),
	.reqA2_i(reqOutA_u0_2),
	.reqA3_i(reqOutA_u0_3),
	.reqB0_i(reqOutB_u0_0),
	.reqB1_i(reqOutB_u0_1),
	.reqB2_i(reqOutB_u0_2),
	.reqB3_i(reqOutB_u0_3),
	.reqC0_i(reqOutC_u0_0),
	.reqC1_i(reqOutC_u0_1),
	.reqC2_i(reqOutC_u0_2),
	.reqC3_i(reqOutC_u0_3),

	.grantA_i(grantInA_u1_0),
	.grantB_i(grantInB_u1_0),
	.grantC_i(grantInC_u1_0),

	.grantA0_o(grantInA_u0_0),
	.grantA1_o(grantInA_u0_1),
	.grantA2_o(grantInA_u0_2),
	.grantA3_o(grantInA_u0_3),
	.grantB0_o(grantInB_u0_0),
	.grantB1_o(grantInB_u0_1),
	.grantB2_o(grantInB_u0_2),
	.grantB3_o(grantInB_u0_3),
	.grantC0_o(grantInC_u0_0),
	.grantC1_o(grantInC_u0_1),
	.grantC2_o(grantInC_u0_2),
	.grantC3_o(grantInC_u0_3),

	.reqA_o(reqOutA_u1_0),
	.reqB_o(reqOutB_u1_0),
	.reqC_o(reqOutC_u1_0)
);

endmodule


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

module cascadedSelectBlock_c3_8(
	input wire reqA0_i,
	input wire reqA1_i,
	input wire reqA2_i,
	input wire reqA3_i,
	input wire reqA4_i,
	input wire reqA5_i,
	input wire reqA6_i,
	input wire reqA7_i,
	input wire reqB0_i,
	input wire reqB1_i,
	input wire reqB2_i,
	input wire reqB3_i,
	input wire reqB4_i,
	input wire reqB5_i,
	input wire reqB6_i,
	input wire reqB7_i,
	input wire reqC0_i,
	input wire reqC1_i,
	input wire reqC2_i,
	input wire reqC3_i,
	input wire reqC4_i,
	input wire reqC5_i,
	input wire reqC6_i,
	input wire reqC7_i,


	input wire grantA_i,
	input wire grantB_i,
	input wire grantC_i,

	output wire grantA0_o,
	output wire grantA1_o,
	output wire grantA2_o,
	output wire grantA3_o,
	output wire grantA4_o,
	output wire grantA5_o,
	output wire grantA6_o,
	output wire grantA7_o,
	output wire grantB0_o,
	output wire grantB1_o,
	output wire grantB2_o,
	output wire grantB3_o,
	output wire grantB4_o,
	output wire grantB5_o,
	output wire grantB6_o,
	output wire grantB7_o,
	output wire grantC0_o,
	output wire grantC1_o,
	output wire grantC2_o,
	output wire grantC3_o,
	output wire grantC4_o,
	output wire grantC5_o,
	output wire grantC6_o,
	output wire grantC7_o,


	output wire reqA_o,
	output wire reqB_o,
	output wire reqC_o
);

/* Wires and registers for combinatinal logic */
wire [7:0] reqA;
wire [7:0] reqB;
wire [7:0] reqC;

reg [7:0] grantA;
reg [7:0] grantB;
reg [7:0] grantC;

wire [7:0] t1;
wire [7:0] t2;
wire [7:0] t3;

wire [23:0] sFull1;
wire [23:0] sFull2;
wire [23:0] sFull3;

wire [23:0] tFull1;
wire [23:0] tFull2;
wire [23:0] tFull3;

/* Assign outputs */
assign {grantA7_o, grantA6_o, grantA5_o, grantA4_o, grantA3_o, grantA2_o, grantA1_o, grantA0_o} = grantA;
assign {grantB7_o, grantB6_o, grantB5_o, grantB4_o, grantB3_o, grantB2_o, grantB1_o, grantB0_o} = grantB;
assign {grantC7_o, grantC6_o, grantC5_o, grantC4_o, grantC3_o, grantC2_o, grantC1_o, grantC0_o} = grantC;

/* Code to deal with vectors instead of individual wires */
assign reqA = {reqA7_i, reqA6_i, reqA5_i, reqA4_i, reqA3_i, reqA2_i, reqA1_i, reqA0_i};
assign reqB = {reqB7_i, reqB6_i, reqB5_i, reqB4_i, reqB3_i, reqB2_i, reqB1_i, reqB0_i};
assign reqC = {reqC7_i, reqC6_i, reqC5_i, reqC4_i, reqC3_i, reqC2_i, reqC1_i, reqC0_i};

/* Generate temporary sFull vectors */
assign sFull1 = {reqC[7], reqB[7], reqA[7], reqC[6], reqB[6], reqA[6], reqC[5], reqB[5], reqA[5], reqC[4], reqB[4], reqA[4], reqC[3], reqB[3], reqA[3], reqC[2], reqB[2], reqA[2], reqC[1], reqB[1], reqA[1], reqC[0], reqB[0], reqA[0]};
assign sFull2 = sFull1 & (~tFull1);
assign sFull3 = sFull2 & (~tFull2);

/* Generate the t vectors */
assign t1 = {|tFull1[23:21], |tFull1[20:18], |tFull1[17:15], |tFull1[14:12], |tFull1[11:9], |tFull1[8:6], |tFull1[5:3], |tFull1[2:0]};
assign t2 = {|tFull2[23:21], |tFull2[20:18], |tFull2[17:15], |tFull2[14:12], |tFull2[11:9], |tFull2[8:6], |tFull2[5:3], |tFull2[2:0]};
assign t3 = {|tFull3[23:21], |tFull3[20:18], |tFull3[17:15], |tFull3[14:12], |tFull3[11:9], |tFull3[8:6], |tFull3[5:3], |tFull3[2:0]};

/* Priority encoders */
PriorityEncoder #(24) tFull1PEncoder(.vector_i(sFull1),
	.vector_o(tFull1)
);

PriorityEncoder #(24) tFull2PEncoder(.vector_i(sFull2),
	.vector_o(tFull2)
);

PriorityEncoder #(24) tFull3PEncoder(.vector_i(sFull3),
	.vector_o(tFull3)
);

/* Generate the OR gates for the req_o */
assign reqA_o = |sFull1;
assign reqB_o = |sFull2;
assign reqC_o = |sFull3;

/* Assign grant */
always @(*)
begin: GRANT_ASSIGNMENT_SELECT_BLOCK
	grantA = 0;
	grantB = 0;
	grantC = 0;

	case({grantA_i, grantB_i, grantC_i})
		3'b001:
		begin
			grantC = t1;
		end
		3'b010:
		begin
			grantB = t1;
		end
		3'b011:
		begin
			grantB = t1;
			grantC = t2;
		end
		3'b100:
		begin
			grantA = t1;
		end
		3'b101:
		begin
			grantA = t1;
			grantC = t2;
		end
		3'b110:
		begin
			grantA = t1;
			grantB = t2;
		end
		3'b111:
		begin
			grantA = t1;
			grantB = t2;
			grantC = t3;
		end
	endcase
end

endmodule


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

module cascadedSelectBlock_c3_4(
	input wire reqA0_i,
	input wire reqA1_i,
	input wire reqA2_i,
	input wire reqA3_i,
	input wire reqB0_i,
	input wire reqB1_i,
	input wire reqB2_i,
	input wire reqB3_i,
	input wire reqC0_i,
	input wire reqC1_i,
	input wire reqC2_i,
	input wire reqC3_i,


	input wire grantA_i,
	input wire grantB_i,
	input wire grantC_i,

	output wire grantA0_o,
	output wire grantA1_o,
	output wire grantA2_o,
	output wire grantA3_o,
	output wire grantB0_o,
	output wire grantB1_o,
	output wire grantB2_o,
	output wire grantB3_o,
	output wire grantC0_o,
	output wire grantC1_o,
	output wire grantC2_o,
	output wire grantC3_o,


	output wire reqA_o,
	output wire reqB_o,
	output wire reqC_o
);

/* Wires and registers for combinatinal logic */
wire [3:0] reqA;
wire [3:0] reqB;
wire [3:0] reqC;

reg [3:0] grantA;
reg [3:0] grantB;
reg [3:0] grantC;

wire [3:0] t1;
wire [3:0] t2;
wire [3:0] t3;

wire [11:0] sFull1;
wire [11:0] sFull2;
wire [11:0] sFull3;

wire [11:0] tFull1;
wire [11:0] tFull2;
wire [11:0] tFull3;

/* Assign outputs */
assign {grantA3_o, grantA2_o, grantA1_o, grantA0_o} = grantA;
assign {grantB3_o, grantB2_o, grantB1_o, grantB0_o} = grantB;
assign {grantC3_o, grantC2_o, grantC1_o, grantC0_o} = grantC;

/* Code to deal with vectors instead of individual wires */
assign reqA = {reqA3_i, reqA2_i, reqA1_i, reqA0_i};
assign reqB = {reqB3_i, reqB2_i, reqB1_i, reqB0_i};
assign reqC = {reqC3_i, reqC2_i, reqC1_i, reqC0_i};

/* Generate temporary sFull vectors */
assign sFull1 = {reqC[3], reqB[3], reqA[3], reqC[2], reqB[2], reqA[2], reqC[1], reqB[1], reqA[1], reqC[0], reqB[0], reqA[0]};
assign sFull2 = sFull1 & (~tFull1);
assign sFull3 = sFull2 & (~tFull2);

/* Generate the t vectors */
assign t1 = {|tFull1[11:9], |tFull1[8:6], |tFull1[5:3], |tFull1[2:0]};
assign t2 = {|tFull2[11:9], |tFull2[8:6], |tFull2[5:3], |tFull2[2:0]};
assign t3 = {|tFull3[11:9], |tFull3[8:6], |tFull3[5:3], |tFull3[2:0]};

/* Priority encoders */
PriorityEncoder #(12) tFull1PEncoder(.vector_i(sFull1),
	.vector_o(tFull1)
);

PriorityEncoder #(12) tFull2PEncoder(.vector_i(sFull2),
	.vector_o(tFull2)
);

PriorityEncoder #(12) tFull3PEncoder(.vector_i(sFull3),
	.vector_o(tFull3)
);

/* Generate the OR gates for the req_o */
assign reqA_o = |sFull1;
assign reqB_o = |sFull2;
assign reqC_o = |sFull3;

/* Assign grant */
always @(*)
begin: GRANT_ASSIGNMENT_SELECT_BLOCK
	grantA = 0;
	grantB = 0;
	grantC = 0;

	case({grantA_i, grantB_i, grantC_i})
		3'b001:
		begin
			grantC = t1;
		end
		3'b010:
		begin
			grantB = t1;
		end
		3'b011:
		begin
			grantB = t1;
			grantC = t2;
		end
		3'b100:
		begin
			grantA = t1;
		end
		3'b101:
		begin
			grantA = t1;
			grantC = t2;
		end
		3'b110:
		begin
			grantA = t1;
			grantB = t2;
		end
		3'b111:
		begin
			grantA = t1;
			grantB = t2;
			grantC = t3;
		end
	endcase
end

endmodule


//module PriorityEncoder(vector_i,
//	vector_o
//);

//parameter ENCODER_WIDTH = 32;

/* I/O definitions */
//input wire [ENCODER_WIDTH-1:0] vector_i;
//output wire [ENCODER_WIDTH-1:0] vector_o;

/* Wires and regs for combinational logic */

/* Mask to reset all other bits except the first */
//reg [ENCODER_WIDTH-1:0] mask;

/* Wires for outputs */
//wire [ENCODER_WIDTH-1:0] vector;

/* Assign outputs */
//assign vector_o = vector;

/* Mask the input vector so that only the first 1'b1 is seen */
/*assign vector = vector_i & mask;

integer j;

always @(*)
begin: ENCODER_CONSTRUCT
	mask[0] = 1'b1;

	for(j=1; j<ENCODER_WIDTH; j=j+1)
	begin
		if(vector_i[j-1] == 1'b1)
			mask[j] = 0;
		else
			mask[j] = mask[j-1];
	end
end

endmodule


module Encoder(vector_i,
	encoded_o
);
*/
//parameter ENCODER_WIDTH = 32;
//parameter ENCODER_WIDTH_LOG = 5;

/* I/O definitions */
//input wire [ENCODER_WIDTH-1:0] vector_i;
//output wire [ENCODER_WIDTH_LOG-1:0] encoded_o;

/* Temporary regs and wires */
//reg [ENCODER_WIDTH_LOG-1:0] s [ENCODER_WIDTH-1:0]; // Stores number itself. 
//reg [ENCODER_WIDTH_LOG-1:0] t [ENCODER_WIDTH-1:0]; // Stores (s[i] if vector[i]==1'b1 else stores 0)
//reg [ENCODER_WIDTH-1:0] u [ENCODER_WIDTH_LOG-1:0]; // Stores transpose of t (to use the | operator)

/* Wires and regs for combinational logic */
//reg [ENCODER_WIDTH-1:0] compareVector;

/* Wires for outputs */
//reg [ENCODER_WIDTH_LOG-1:0] encoded;

/* Assign outputs */
/*assign encoded_o = encoded;

integer i;
integer j;

always @(*)
begin: ENCODER_CONSTRUCT
	for(i=0; i<ENCODER_WIDTH; i=i+1)
	begin
		s[i] = i;
	end

	for(i=0; i<ENCODER_WIDTH; i=i+1)
	begin
		if(vector_i[i] == 1'b1)
			t[i] = s[i];
		else
			t[i] = 0;
	end

	for(i=0; i<ENCODER_WIDTH; i=i+1)
	begin
		for(j=0; j<ENCODER_WIDTH_LOG; j=j+1)
		begin
			u[j][i] = t[i][j];
		end
	end

	for(j=0; j<ENCODER_WIDTH_LOG; j=j+1)
	begin
		encoded[j] = |u[j];
	end
end

endmodule
*/
