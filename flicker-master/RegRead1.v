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

  module RegRead ( 
                 input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                        `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                        `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket0_i,
                 input fuPacketValid0_i,
		 input [`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:0] bypassPacket0_i,
                 input bypassValid0_i,
                 input [`SIZE_PHYSICAL_LOG:0] unmapDest0_i,
                 input [`SIZE_PHYSICAL_LOG-1:0] rsr0Tag_i,
                 input                          rsr0TagValid_i,
                 input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                        `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                        `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket1_i,
                 input fuPacketValid1_i,
		 input [`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:0] bypassPacket1_i,
                 input bypassValid1_i,
                 input [`SIZE_PHYSICAL_LOG:0] unmapDest1_i,
                 input [`SIZE_PHYSICAL_LOG-1:0] rsr1Tag_i,
                 input                          rsr1TagValid_i,
                 input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                        `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                        `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket2_i,
                 input fuPacketValid2_i,
		 input [`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:0] bypassPacket2_i,
                 input bypassValid2_i,
                 input [`SIZE_PHYSICAL_LOG:0] unmapDest2_i,
                 input [`SIZE_PHYSICAL_LOG-1:0] rsr2Tag_i,
                 input                          rsr2TagValid_i,
                 input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                        `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                        `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket3_i,
                 input fuPacketValid3_i,
		 input [`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:0] bypassPacket3_i,
                 input bypassValid3_i,
                 input [`SIZE_PHYSICAL_LOG:0] unmapDest3_i,
                 input [`SIZE_PHYSICAL_LOG-1:0] rsr3Tag_i,
                 input                          rsr3TagValid_i,
                 input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                        `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                        `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket4_i,
                 input fuPacketValid4_i,
		 input [`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:0] bypassPacket4_i,
                 input bypassValid4_i,
                 input [`SIZE_PHYSICAL_LOG:0] unmapDest4_i,
                 input [`SIZE_PHYSICAL_LOG-1:0] rsr4Tag_i,
                 input                          rsr4TagValid_i,
                 input [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                        `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                        `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket5_i,
                 input fuPacketValid5_i,
		 input [`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:0] bypassPacket5_i,
                 input bypassValid5_i,
                 input [`SIZE_PHYSICAL_LOG:0] unmapDest5_i,
                 input [`SIZE_PHYSICAL_LOG-1:0] rsr5Tag_i,
                 input                          rsr5TagValid_i,
                 input ctrlVerified_i,                          // control execution flags from the bypass path
                 input ctrlMispredict_i,                        // if 1, there has been a mis-predict previous cycle
                 input [`CHECKPOINTS_LOG-1:0] ctrlSMTid_i,      // SMT id of the mispredicted branch

                 output [`SIZE_PHYSICAL_TABLE-1:0] phyRegRdy_o,

                 output [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                         `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                         `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket0_o,
                 output fuPacketValid0_o,
                 output [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                         `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                         `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket1_o,
                 output fuPacketValid1_o,
                 output [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                         `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                         `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket2_o,
                 output fuPacketValid2_o,
                 output [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                         `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                         `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket3_o,
                 output fuPacketValid3_o,
                 output [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                         `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                         `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket4_o,
                 output fuPacketValid4_o,
                 output [2*`SIZE_DATA+`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                         `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                         `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket5_o,
                 output fuPacketValid5_o,
 input clk,
                 input reset,
                 input recoverFlag_i,
                 input exceptionFlag_i
              );

 reg [`SIZE_PHYSICAL_TABLE-1:0] PHY_REG_VALID; 
`define SRAM_DATA_WIDTH 32

 reg [`SIZE_PHYSICAL_LOG-1:0]           inst0Source1; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst0Source2; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst1Source1; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst1Source2; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst2Source1; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst2Source2; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst3Source1; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst3Source2; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst4Source1; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst4Source2; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst5Source1; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           inst5Source2; 


 reg [`SIZE_DATA-1:0]           bypass0Data; 
 reg [`SIZE_DATA-1:0]           bypass1Data; 
 reg [`SIZE_DATA-1:0]           bypass2Data; 
 reg [`SIZE_DATA-1:0]           bypass3Data; 
 reg [`SIZE_DATA-1:0]           bypass4Data; 
 reg [`SIZE_DATA-1:0]           bypass5Data; 

 reg [`SIZE_PHYSICAL_LOG-1:0]           bypass0Dest; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           bypass1Dest; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           bypass2Dest; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           bypass3Dest; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           bypass4Dest; 
 reg [`SIZE_PHYSICAL_LOG-1:0]           bypass5Dest; 


 reg                                    mispredictEvent;
 reg [`CHECKPOINTS_LOG-1:0]             mispredictSMTid;

 reg [`CHECKPOINTS-1:0]                  inst0Mask_l1;
 reg [`CHECKPOINTS-1:0]                  inst1Mask_l1;
 reg [`CHECKPOINTS-1:0]                  inst2Mask_l1;
 reg [`CHECKPOINTS-1:0]                  inst3Mask_l1;
 reg [`CHECKPOINTS-1:0]                  inst4Mask_l1;
 reg [`CHECKPOINTS-1:0]                  inst5Mask_l1;
 reg [`SIZE_DATA-1:0]           inst0Data1; 
 reg [`SIZE_DATA-1:0]           inst0Data2; 
 reg [`SIZE_DATA-1:0]           inst1Data1; 
 reg [`SIZE_DATA-1:0]           inst1Data2; 
 reg [`SIZE_DATA-1:0]           inst2Data1; 
 reg [`SIZE_DATA-1:0]           inst2Data2; 
 reg [`SIZE_DATA-1:0]           inst3Data1; 
 reg [`SIZE_DATA-1:0]           inst3Data2; 
 reg [`SIZE_DATA-1:0]           inst4Data1; 
 reg [`SIZE_DATA-1:0]           inst4Data2; 
 reg [`SIZE_DATA-1:0]           inst5Data1; 
 reg [`SIZE_DATA-1:0]           inst5Data2; 

 reg [`SRAM_DATA_WIDTH-1:0]           inst0Data1_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst0Data2_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst1Data1_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst1Data2_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst2Data1_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst2Data2_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst3Data1_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst3Data2_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst4Data1_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst4Data2_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst5Data1_11; 
 reg [`SRAM_DATA_WIDTH-1:0]           inst5Data2_11; 



 reg                  		fuPacketValid0_l1; 
 reg                  		fuPacketValid1_l1; 
 reg                  		fuPacketValid2_l1; 
 reg                  		fuPacketValid3_l1; 
 reg                  		fuPacketValid4_l1; 
 reg                  		fuPacketValid5_l1; 


 reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
      `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
      `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket0_i_l1; 
 reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
      `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
      `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket1_i_l1; 
 reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
      `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
      `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket2_i_l1; 
 reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
      `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
      `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket3_i_l1; 
 reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
      `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
      `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket4_i_l1; 
 reg [`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
      `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
      `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:0] fuPacket5_i_l1; 


 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr0_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr1_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr2_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr3_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr4_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr5_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr6_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr7_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr8_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr9_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr10_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr11_stage1_o; 


 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr0wr_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr1wr_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr2wr_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr3wr_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr4wr_stage1_o; 
 wire [`SIZE_PHYSICAL_TABLE-1:0] decoded_addr5wr_stage1_o; 



 wire we0_stage1_o, we1_stage1_o, we2_stage1_o, we3_stage1_o, we4_stage1_o, we5_stage1_o; 

 wire [`SRAM_DATA_WIDTH-1:0]                     data0_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data2_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data3_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data4_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data5_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data6_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data7_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data8_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data9_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data10_stage1; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data11_stage1; 


 reg [`SRAM_DATA_WIDTH-1:0]                     bypass0Data_stage1i; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass1Data_stage1i; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass2Data_stage1i; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass3Data_stage1i; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass4Data_stage1i; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass5Data_stage1i; 


 reg [`SRAM_DATA_WIDTH-1:0]                     bypass0Data_1; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass1Data_1; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass2Data_1; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass3Data_1; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass4Data_1; 
 reg [`SRAM_DATA_WIDTH-1:0]                     bypass5Data_1; 

 wire   inst0Src1_mch0, inst0Src2_mch0; 
 wire   inst0Src1_mch1, inst0Src2_mch1; 
 wire   inst0Src1_mch2, inst0Src2_mch2; 
 wire   inst0Src1_mch3, inst0Src2_mch3; 
 wire   inst0Src1_mch4, inst0Src2_mch4; 
 wire   inst0Src1_mch5, inst0Src2_mch5; 
 wire   inst1Src1_mch0, inst1Src2_mch0; 
 wire   inst1Src1_mch1, inst1Src2_mch1; 
 wire   inst1Src1_mch2, inst1Src2_mch2; 
 wire   inst1Src1_mch3, inst1Src2_mch3; 
 wire   inst1Src1_mch4, inst1Src2_mch4; 
 wire   inst1Src1_mch5, inst1Src2_mch5; 
 wire   inst2Src1_mch0, inst2Src2_mch0; 
 wire   inst2Src1_mch1, inst2Src2_mch1; 
 wire   inst2Src1_mch2, inst2Src2_mch2; 
 wire   inst2Src1_mch3, inst2Src2_mch3; 
 wire   inst2Src1_mch4, inst2Src2_mch4; 
 wire   inst2Src1_mch5, inst2Src2_mch5; 
 wire   inst3Src1_mch0, inst3Src2_mch0; 
 wire   inst3Src1_mch1, inst3Src2_mch1; 
 wire   inst3Src1_mch2, inst3Src2_mch2; 
 wire   inst3Src1_mch3, inst3Src2_mch3; 
 wire   inst3Src1_mch4, inst3Src2_mch4; 
 wire   inst3Src1_mch5, inst3Src2_mch5; 
 wire   inst4Src1_mch0, inst4Src2_mch0; 
 wire   inst4Src1_mch1, inst4Src2_mch1; 
 wire   inst4Src1_mch2, inst4Src2_mch2; 
 wire   inst4Src1_mch3, inst4Src2_mch3; 
 wire   inst4Src1_mch4, inst4Src2_mch4; 
 wire   inst4Src1_mch5, inst4Src2_mch5; 
 wire   inst5Src1_mch0, inst5Src2_mch0; 
 wire   inst5Src1_mch1, inst5Src2_mch1; 
 wire   inst5Src1_mch2, inst5Src2_mch2; 
 wire   inst5Src1_mch3, inst5Src2_mch3; 
 wire   inst5Src1_mch4, inst5Src2_mch4; 
 wire   inst5Src1_mch5, inst5Src2_mch5; 
 wire [5:0] inst0Src1_11_mVector, inst0Src2_11_mVector; 
 wire [5:0] inst1Src1_11_mVector, inst1Src2_11_mVector; 
 wire [5:0] inst2Src1_11_mVector, inst2Src2_11_mVector; 
 wire [5:0] inst3Src1_11_mVector, inst3Src2_11_mVector; 
 wire [5:0] inst4Src1_11_mVector, inst4Src2_11_mVector; 
 wire [5:0] inst5Src1_11_mVector, inst5Src2_11_mVector; 
 
 
 wire we0_i;
 wire we1_i;
 wire we2_i;
 wire we3_i;
 wire we4_i;
 wire we5_i;
 
 
 wire we0_0_i;
 wire we0_1_i;
 wire we0_2_i;
 wire we0_3_i;
 wire we0_4_i;
 wire we0_5_i;
 
 wire we1_0_i;
 wire we1_1_i;
 wire we1_2_i;
 wire we1_3_i;
 wire we1_4_i;
 wire we1_5_i;
 
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_0; 
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_1;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_2;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_3;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_4;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_5;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_6;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_7;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_8;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_9;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_10;
 wire [`SRAM_DATA_WIDTH-1:0]                     data0_11;
 
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_0;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_1;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_2;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_3;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_4;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_5;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_6;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_7;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_8;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_9;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_10;
 wire [`SRAM_DATA_WIDTH-1:0]                     data1_11;
 
 
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_0;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_1;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_2;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_3;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_4;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_5;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_6;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_7;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_8;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_9;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_10;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr0_11;
 
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_0;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_1;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_2;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_3;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_4;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_5;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_6;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_7;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_8;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_9;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_10;
 wire [`SIZE_PHYSICAL_TABLE/2-1:0] decoded_addr1_11;
 
 
//***************************************ASSIGNMENT STATEMENTS*************************************
assign we0_i = bypassValid0_i & ~recoverFlag_i;
assign we1_i = bypassValid1_i & ~recoverFlag_i;
assign we2_i = bypassValid2_i & ~recoverFlag_i;
assign we3_i = bypassValid3_i & ~recoverFlag_i;
assign we4_i = bypassValid4_i & ~recoverFlag_i;
assign we5_i = bypassValid5_i & ~recoverFlag_i;

assign we0_0_i = (we0_i & ~bypass0Dest[`SIZE_PHYSICAL_LOG-1]);
assign we0_1_i = (we1_i & ~bypass1Dest[`SIZE_PHYSICAL_LOG-1]);
assign we0_2_i = (we2_i & ~bypass2Dest[`SIZE_PHYSICAL_LOG-1]);
assign we0_3_i = (we3_i & ~bypass3Dest[`SIZE_PHYSICAL_LOG-1]);
assign we0_4_i = (we4_i & ~bypass4Dest[`SIZE_PHYSICAL_LOG-1]);
assign we0_5_i = (we5_i & ~bypass5Dest[`SIZE_PHYSICAL_LOG-1]);

assign we1_0_i = (we0_i & bypass0Dest[`SIZE_PHYSICAL_LOG-1]);
assign we1_1_i = (we1_i & bypass1Dest[`SIZE_PHYSICAL_LOG-1]);
assign we1_2_i = (we2_i & bypass2Dest[`SIZE_PHYSICAL_LOG-1]);
assign we1_3_i = (we3_i & bypass3Dest[`SIZE_PHYSICAL_LOG-1]);
assign we1_4_i = (we4_i & bypass4Dest[`SIZE_PHYSICAL_LOG-1]);
assign we1_5_i = (we5_i & bypass5Dest[`SIZE_PHYSICAL_LOG-1]);


 always@(*) 
 begin 
	bypass0Data_stage1i 	= bypass0Data[`SRAM_DATA_WIDTH-1:0]; 
	bypass0Data_1 		= bypass0Data[1*`SRAM_DATA_WIDTH-1:0*`SRAM_DATA_WIDTH]; 

	bypass1Data_stage1i 	= bypass1Data[`SRAM_DATA_WIDTH-1:0]; 
	bypass1Data_1 		= bypass1Data[1*`SRAM_DATA_WIDTH-1:0*`SRAM_DATA_WIDTH]; 

	bypass2Data_stage1i 	= bypass2Data[`SRAM_DATA_WIDTH-1:0]; 
	bypass2Data_1 		= bypass2Data[1*`SRAM_DATA_WIDTH-1:0*`SRAM_DATA_WIDTH]; 

	bypass3Data_stage1i 	= bypass3Data[`SRAM_DATA_WIDTH-1:0]; 
	bypass3Data_1 		= bypass3Data[1*`SRAM_DATA_WIDTH-1:0*`SRAM_DATA_WIDTH]; 

	bypass4Data_stage1i 	= bypass4Data[`SRAM_DATA_WIDTH-1:0]; 
	bypass4Data_1 		= bypass4Data[1*`SRAM_DATA_WIDTH-1:0*`SRAM_DATA_WIDTH]; 

	bypass5Data_stage1i 	= bypass5Data[`SRAM_DATA_WIDTH-1:0]; 
	bypass5Data_1 		= bypass5Data[1*`SRAM_DATA_WIDTH-1:0*`SRAM_DATA_WIDTH]; 

 end 
 SRAM_12R6W_PIPE #(`SIZE_PHYSICAL_TABLE/2,`SIZE_PHYSICAL_LOG-1,`SRAM_DATA_WIDTH) 
		 PhyRegFile0( 
			 .addr0_i(inst0Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr1_i(inst0Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we0_i(we0_0_i), 
			 .addr0wr_i(bypass0Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data0wr_i(bypass0Data_stage1i), 
			 .decoded_addr0wr_o(decoded_addr0wr_stage1_o), 
			 .we0_o(we0_stage1_o), 
			 .addr2_i(inst1Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr3_i(inst1Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we1_i(we0_1_i), 
			 .addr1wr_i(bypass1Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data1wr_i(bypass1Data_stage1i), 
			 .decoded_addr1wr_o(decoded_addr1wr_stage1_o), 
			 .we1_o(we1_stage1_o), 
			 .addr4_i(inst2Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr5_i(inst2Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we2_i(we0_2_i), 
			 .addr2wr_i(bypass2Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data2wr_i(bypass2Data_stage1i), 
			 .decoded_addr2wr_o(decoded_addr2wr_stage1_o), 
			 .we2_o(we2_stage1_o), 
			 .addr6_i(inst3Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr7_i(inst3Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we3_i(we0_3_i), 
			 .addr3wr_i(bypass3Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data3wr_i(bypass3Data_stage1i), 
			 .decoded_addr3wr_o(decoded_addr3wr_stage1_o), 
			 .we3_o(we3_stage1_o), 
			 .addr8_i(inst4Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr9_i(inst4Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we4_i(we0_4_i), 
			 .addr4wr_i(bypass4Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data4wr_i(bypass4Data_stage1i), 
			 .decoded_addr4wr_o(decoded_addr4wr_stage1_o), 
			 .we4_o(we4_stage1_o), 
			 .addr10_i(inst5Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr11_i(inst5Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we5_i(we0_5_i), 
			 .addr5wr_i(bypass5Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data5wr_i(bypass5Data_stage1i), 
			 .decoded_addr5wr_o(decoded_addr5wr_stage1_o), 
			 .we5_o(we5_stage1_o), 
			 .data0_o(data0_0), 
			 .decoded_addr0_o(decoded_addr0_stage1_o), 
			 .data1_o(data0_1), 
			 .decoded_addr1_o(decoded_addr1_stage1_o), 
			 .data2_o(data0_2), 
			 .decoded_addr2_o(decoded_addr2_stage1_o), 
			 .data3_o(data0_3), 
			 .decoded_addr3_o(decoded_addr3_stage1_o), 
			 .data4_o(data0_4), 
			 .decoded_addr4_o(decoded_addr4_stage1_o), 
			 .data5_o(data0_5), 
			 .decoded_addr5_o(decoded_addr5_stage1_o), 
			 .data6_o(data0_6), 
			 .decoded_addr6_o(decoded_addr6_stage1_o), 
			 .data7_o(data0_7), 
			 .decoded_addr7_o(decoded_addr7_stage1_o), 
			 .data8_o(data0_8), 
			 .decoded_addr8_o(decoded_addr8_stage1_o), 
			 .data9_o(data0_9), 
			 .decoded_addr9_o(decoded_addr9_stage1_o), 
			 .data10_o(data0_10), 
			 .decoded_addr10_o(decoded_addr10_stage1_o), 
			 .data11_o(data0_11), 
			 .decoded_addr11_o(decoded_addr11_stage1_o), 
			 .clk(clk), 
			 .reset(reset) 
		);
		
		
SRAM_12R6W_PIPE #(`SIZE_PHYSICAL_TABLE/2,`SIZE_PHYSICAL_LOG-1,`SRAM_DATA_WIDTH) 
		 PhyRegFile1( 
			 .addr0_i(inst0Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr1_i(inst0Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we0_i(we1_0_i), 
			 .addr0wr_i(bypass0Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data0wr_i(bypass0Data_stage1i), 
			 .decoded_addr0wr_o(decoded_addr0wr_stage1_o), 
			 .we0_o(we0_stage1_o), 
			 .addr2_i(inst1Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr3_i(inst1Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we1_i(we1_1_i), 
			 .addr1wr_i(bypass1Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data1wr_i(bypass1Data_stage1i), 
			 .decoded_addr1wr_o(decoded_addr1wr_stage1_o), 
			 .we1_o(we1_stage1_o), 
			 .addr4_i(inst2Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr5_i(inst2Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we2_i(we1_2_i), 
			 .addr2wr_i(bypass2Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data2wr_i(bypass2Data_stage1i), 
			 .decoded_addr2wr_o(decoded_addr2wr_stage1_o), 
			 .we2_o(we2_stage1_o), 
			 .addr6_i(inst3Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr7_i(inst3Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we3_i(we1_3_i), 
			 .addr3wr_i(bypass3Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data3wr_i(bypass3Data_stage1i), 
			 .decoded_addr3wr_o(decoded_addr3wr_stage1_o), 
			 .we3_o(we3_stage1_o), 
			 .addr8_i(inst4Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr9_i(inst4Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we4_i(we1_4_i), 
			 .addr4wr_i(bypass4Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data4wr_i(bypass4Data_stage1i), 
			 .decoded_addr4wr_o(decoded_addr4wr_stage1_o), 
			 .we4_o(we4_stage1_o), 
			 .addr10_i(inst5Source1[`SIZE_PHYSICAL_LOG-2:0]), 
			 .addr11_i(inst5Source2[`SIZE_PHYSICAL_LOG-2:0]), 
			 .we5_i(we1_5_i), 
			 .addr5wr_i(bypass5Dest[`SIZE_PHYSICAL_LOG-2:0]), 
			 .data5wr_i(bypass5Data_stage1i), 
			 .decoded_addr5wr_o(decoded_addr5wr_stage1_o), 
			 .we5_o(we5_stage1_o), 
			 .data0_o(data1_0), 
			 .decoded_addr0_o(decoded_addr0_stage1_o), 
			 .data1_o(data1_1), 
			 .decoded_addr1_o(decoded_addr1_stage1_o), 
			 .data2_o(data1_2), 
			 .decoded_addr2_o(decoded_addr2_stage1_o), 
			 .data3_o(data1_3), 
			 .decoded_addr3_o(decoded_addr3_stage1_o), 
			 .data4_o(data1_4), 
			 .decoded_addr4_o(decoded_addr4_stage1_o), 
			 .data5_o(data1_5), 
			 .decoded_addr5_o(decoded_addr5_stage1_o), 
			 .data6_o(data1_6), 
			 .decoded_addr6_o(decoded_addr6_stage1_o), 
			 .data7_o(data1_7), 
			 .decoded_addr7_o(decoded_addr7_stage1_o), 
			 .data8_o(data1_8), 
			 .decoded_addr8_o(decoded_addr8_stage1_o), 
			 .data9_o(data1_9), 
			 .decoded_addr9_o(decoded_addr9_stage1_o), 
			 .data10_o(data1_10), 
			 .decoded_addr10_o(decoded_addr10_stage1_o), 
			 .data11_o(data1_11), 
			 .decoded_addr11_o(decoded_addr11_stage1_o), 
			 .clk(clk), 
			 .reset(reset) 
		);
		

		
//**************************MUXES FOR REGISTER OUTPUTS*****************************
assign data0_stage1 = inst0Source1[`SIZE_PHYSICAL_LOG-1] ? data1_0 : data0_0;
assign data1_stage1 = inst0Source2[`SIZE_PHYSICAL_LOG-1] ? data1_1 : data0_1;
assign data2_stage1 = inst1Source1[`SIZE_PHYSICAL_LOG-1] ? data1_2 : data0_2;
assign data3_stage1 = inst1Source2[`SIZE_PHYSICAL_LOG-1] ? data1_3 : data0_3;
assign data4_stage1 = inst2Source1[`SIZE_PHYSICAL_LOG-1] ? data1_4 : data0_4;
assign data5_stage1 = inst2Source2[`SIZE_PHYSICAL_LOG-1] ? data1_5 : data0_5;
assign data6_stage1 = inst3Source1[`SIZE_PHYSICAL_LOG-1] ? data1_6 : data0_6;
assign data7_stage1 = inst3Source2[`SIZE_PHYSICAL_LOG-1] ? data1_7 : data0_7;
assign data8_stage1 = inst4Source1[`SIZE_PHYSICAL_LOG-1] ? data1_8 : data0_8;
assign data9_stage1 = inst4Source2[`SIZE_PHYSICAL_LOG-1] ? data1_9 : data0_9;
assign data10_stage1 = inst5Source1[`SIZE_PHYSICAL_LOG-1] ? data1_10 : data0_10;
assign data11_stage1 = inst5Source2[`SIZE_PHYSICAL_LOG-1] ? data1_11 : data0_11;



//**********************WRITE ENABLE ASSIGNMENTS***********************************



//*********************MUXES FOR DECODED READ ADDRESSES****************************
assign decoded_addr0_stage1_o = inst0Source1[`SIZE_PHYSICAL_LOG-1] ? decoded_addr1_0 << `SIZE_PHYSICAL_TABLE/2

always @(*)
begin
 inst0Source1 = fuPacket0_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst0Source2 = fuPacket0_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                            `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                            `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst1Source1 = fuPacket1_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst1Source2 = fuPacket1_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                            `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                            `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst2Source1 = fuPacket2_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst2Source2 = fuPacket2_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                            `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                            `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst3Source1 = fuPacket3_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst3Source2 = fuPacket3_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                            `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                            `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst4Source1 = fuPacket4_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst4Source2 = fuPacket4_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                            `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                            `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst5Source1 = fuPacket5_i[`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst5Source2 = fuPacket5_i[2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+
                            `SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+
                            `SIZE_PC+`SIZE_CTI_LOG:`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+`SIZE_ACTIVELIST_LOG+
                            `CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+`LDST_TYPES_LOG+
                            `SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

end


always @(*)
begin
 mispredictEvent = ctrlVerified_i & ctrlMispredict_i; 
 mispredictSMTid = ctrlSMTid_i; 

 bypass0Data = bypassPacket0_i[`SIZE_DATA+`CHECKPOINTS_LOG:`CHECKPOINTS_LOG+1]; 
 bypass0Dest = bypassPacket0_i[`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:`SIZE_DATA+`CHECKPOINTS_LOG+1]; 

 bypass1Data = bypassPacket1_i[`SIZE_DATA+`CHECKPOINTS_LOG:`CHECKPOINTS_LOG+1]; 
 bypass1Dest = bypassPacket1_i[`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:`SIZE_DATA+`CHECKPOINTS_LOG+1]; 

 bypass2Data = bypassPacket2_i[`SIZE_DATA+`CHECKPOINTS_LOG:`CHECKPOINTS_LOG+1]; 
 bypass2Dest = bypassPacket2_i[`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:`SIZE_DATA+`CHECKPOINTS_LOG+1]; 

 bypass3Data = bypassPacket3_i[`SIZE_DATA+`CHECKPOINTS_LOG:`CHECKPOINTS_LOG+1]; 
 bypass3Dest = bypassPacket3_i[`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:`SIZE_DATA+`CHECKPOINTS_LOG+1]; 

 bypass4Data = bypassPacket4_i[`SIZE_DATA+`CHECKPOINTS_LOG:`CHECKPOINTS_LOG+1]; 
 bypass4Dest = bypassPacket4_i[`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:`SIZE_DATA+`CHECKPOINTS_LOG+1]; 

 bypass5Data = bypassPacket5_i[`SIZE_DATA+`CHECKPOINTS_LOG:`CHECKPOINTS_LOG+1]; 
 bypass5Dest = bypassPacket5_i[`SIZE_PHYSICAL_LOG+`SIZE_DATA+`CHECKPOINTS_LOG:`SIZE_DATA+`CHECKPOINTS_LOG+1]; 

 inst0Mask_l1 	= fuPacket0_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                            `SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst1Mask_l1 	= fuPacket1_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                            `SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst2Mask_l1 	= fuPacket2_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                            `SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst3Mask_l1 	= fuPacket3_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                            `SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst4Mask_l1 	= fuPacket4_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                            `SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

 inst5Mask_l1 	= fuPacket5_i[`CHECKPOINTS+`SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG:
                            `SIZE_ISSUEQ_LOG+2*`SIZE_PHYSICAL_LOG+`SIZE_LSQ_LOG+
                            `SIZE_ACTIVELIST_LOG+`CHECKPOINTS_LOG+`SIZE_PHYSICAL_LOG+`SIZE_IMMEDIATE+
                            `LDST_TYPES_LOG+`SIZE_OPCODE_I+`SIZE_PC+`SIZE_PC+`SIZE_CTI_LOG+1]; 

end

 assign inst0Src1_mch0 = ((inst0Source1 == bypass0Dest) && bypassValid0_i); 
 assign inst0Src2_mch0 = ((inst0Source2 == bypass0Dest) && bypassValid0_i); 
 assign inst0Src1_mch1 = ((inst0Source1 == bypass1Dest) && bypassValid1_i); 
 assign inst0Src2_mch1 = ((inst0Source2 == bypass1Dest) && bypassValid1_i); 
 assign inst0Src1_mch2 = ((inst0Source1 == bypass2Dest) && bypassValid2_i); 
 assign inst0Src2_mch2 = ((inst0Source2 == bypass2Dest) && bypassValid2_i); 
 assign inst0Src1_mch3 = ((inst0Source1 == bypass3Dest) && bypassValid3_i); 
 assign inst0Src2_mch3 = ((inst0Source2 == bypass3Dest) && bypassValid3_i); 
 assign inst0Src1_mch4 = ((inst0Source1 == bypass4Dest) && bypassValid4_i); 
 assign inst0Src2_mch4 = ((inst0Source2 == bypass4Dest) && bypassValid4_i); 
 assign inst0Src1_mch5 = ((inst0Source1 == bypass5Dest) && bypassValid5_i); 
 assign inst0Src2_mch5 = ((inst0Source2 == bypass5Dest) && bypassValid5_i); 


 assign inst1Src1_mch0 = ((inst1Source1 == bypass0Dest) && bypassValid0_i); 
 assign inst1Src2_mch0 = ((inst1Source2 == bypass0Dest) && bypassValid0_i); 
 assign inst1Src1_mch1 = ((inst1Source1 == bypass1Dest) && bypassValid1_i); 
 assign inst1Src2_mch1 = ((inst1Source2 == bypass1Dest) && bypassValid1_i); 
 assign inst1Src1_mch2 = ((inst1Source1 == bypass2Dest) && bypassValid2_i); 
 assign inst1Src2_mch2 = ((inst1Source2 == bypass2Dest) && bypassValid2_i); 
 assign inst1Src1_mch3 = ((inst1Source1 == bypass3Dest) && bypassValid3_i); 
 assign inst1Src2_mch3 = ((inst1Source2 == bypass3Dest) && bypassValid3_i); 
 assign inst1Src1_mch4 = ((inst1Source1 == bypass4Dest) && bypassValid4_i); 
 assign inst1Src2_mch4 = ((inst1Source2 == bypass4Dest) && bypassValid4_i); 
 assign inst1Src1_mch5 = ((inst1Source1 == bypass5Dest) && bypassValid5_i); 
 assign inst1Src2_mch5 = ((inst1Source2 == bypass5Dest) && bypassValid5_i); 


 assign inst2Src1_mch0 = ((inst2Source1 == bypass0Dest) && bypassValid0_i); 
 assign inst2Src2_mch0 = ((inst2Source2 == bypass0Dest) && bypassValid0_i); 
 assign inst2Src1_mch1 = ((inst2Source1 == bypass1Dest) && bypassValid1_i); 
 assign inst2Src2_mch1 = ((inst2Source2 == bypass1Dest) && bypassValid1_i); 
 assign inst2Src1_mch2 = ((inst2Source1 == bypass2Dest) && bypassValid2_i); 
 assign inst2Src2_mch2 = ((inst2Source2 == bypass2Dest) && bypassValid2_i); 
 assign inst2Src1_mch3 = ((inst2Source1 == bypass3Dest) && bypassValid3_i); 
 assign inst2Src2_mch3 = ((inst2Source2 == bypass3Dest) && bypassValid3_i); 
 assign inst2Src1_mch4 = ((inst2Source1 == bypass4Dest) && bypassValid4_i); 
 assign inst2Src2_mch4 = ((inst2Source2 == bypass4Dest) && bypassValid4_i); 
 assign inst2Src1_mch5 = ((inst2Source1 == bypass5Dest) && bypassValid5_i); 
 assign inst2Src2_mch5 = ((inst2Source2 == bypass5Dest) && bypassValid5_i); 


 assign inst3Src1_mch0 = ((inst3Source1 == bypass0Dest) && bypassValid0_i); 
 assign inst3Src2_mch0 = ((inst3Source2 == bypass0Dest) && bypassValid0_i); 
 assign inst3Src1_mch1 = ((inst3Source1 == bypass1Dest) && bypassValid1_i); 
 assign inst3Src2_mch1 = ((inst3Source2 == bypass1Dest) && bypassValid1_i); 
 assign inst3Src1_mch2 = ((inst3Source1 == bypass2Dest) && bypassValid2_i); 
 assign inst3Src2_mch2 = ((inst3Source2 == bypass2Dest) && bypassValid2_i); 
 assign inst3Src1_mch3 = ((inst3Source1 == bypass3Dest) && bypassValid3_i); 
 assign inst3Src2_mch3 = ((inst3Source2 == bypass3Dest) && bypassValid3_i); 
 assign inst3Src1_mch4 = ((inst3Source1 == bypass4Dest) && bypassValid4_i); 
 assign inst3Src2_mch4 = ((inst3Source2 == bypass4Dest) && bypassValid4_i); 
 assign inst3Src1_mch5 = ((inst3Source1 == bypass5Dest) && bypassValid5_i); 
 assign inst3Src2_mch5 = ((inst3Source2 == bypass5Dest) && bypassValid5_i); 


 assign inst4Src1_mch0 = ((inst4Source1 == bypass0Dest) && bypassValid0_i); 
 assign inst4Src2_mch0 = ((inst4Source2 == bypass0Dest) && bypassValid0_i); 
 assign inst4Src1_mch1 = ((inst4Source1 == bypass1Dest) && bypassValid1_i); 
 assign inst4Src2_mch1 = ((inst4Source2 == bypass1Dest) && bypassValid1_i); 
 assign inst4Src1_mch2 = ((inst4Source1 == bypass2Dest) && bypassValid2_i); 
 assign inst4Src2_mch2 = ((inst4Source2 == bypass2Dest) && bypassValid2_i); 
 assign inst4Src1_mch3 = ((inst4Source1 == bypass3Dest) && bypassValid3_i); 
 assign inst4Src2_mch3 = ((inst4Source2 == bypass3Dest) && bypassValid3_i); 
 assign inst4Src1_mch4 = ((inst4Source1 == bypass4Dest) && bypassValid4_i); 
 assign inst4Src2_mch4 = ((inst4Source2 == bypass4Dest) && bypassValid4_i); 
 assign inst4Src1_mch5 = ((inst4Source1 == bypass5Dest) && bypassValid5_i); 
 assign inst4Src2_mch5 = ((inst4Source2 == bypass5Dest) && bypassValid5_i); 


 assign inst5Src1_mch0 = ((inst5Source1 == bypass0Dest) && bypassValid0_i); 
 assign inst5Src2_mch0 = ((inst5Source2 == bypass0Dest) && bypassValid0_i); 
 assign inst5Src1_mch1 = ((inst5Source1 == bypass1Dest) && bypassValid1_i); 
 assign inst5Src2_mch1 = ((inst5Source2 == bypass1Dest) && bypassValid1_i); 
 assign inst5Src1_mch2 = ((inst5Source1 == bypass2Dest) && bypassValid2_i); 
 assign inst5Src2_mch2 = ((inst5Source2 == bypass2Dest) && bypassValid2_i); 
 assign inst5Src1_mch3 = ((inst5Source1 == bypass3Dest) && bypassValid3_i); 
 assign inst5Src2_mch3 = ((inst5Source2 == bypass3Dest) && bypassValid3_i); 
 assign inst5Src1_mch4 = ((inst5Source1 == bypass4Dest) && bypassValid4_i); 
 assign inst5Src2_mch4 = ((inst5Source2 == bypass4Dest) && bypassValid4_i); 
 assign inst5Src1_mch5 = ((inst5Source1 == bypass5Dest) && bypassValid5_i); 
 assign inst5Src2_mch5 = ((inst5Source2 == bypass5Dest) && bypassValid5_i); 




 assign inst0Src1_11_mVector = { inst0Src1_mch5, inst0Src1_mch4, inst0Src1_mch3, inst0Src1_mch2, inst0Src1_mch1, inst0Src1_mch0} ;

 assign inst0Src2_11_mVector = { inst0Src2_mch5, inst0Src2_mch4, inst0Src2_mch3, inst0Src2_mch2, inst0Src2_mch1, inst0Src2_mch0} ;
 assign inst1Src1_11_mVector = { inst1Src1_mch5, inst1Src1_mch4, inst1Src1_mch3, inst1Src1_mch2, inst1Src1_mch1, inst1Src1_mch0} ;

 assign inst1Src2_11_mVector = { inst1Src2_mch5, inst1Src2_mch4, inst1Src2_mch3, inst1Src2_mch2, inst1Src2_mch1, inst1Src2_mch0} ;
 assign inst2Src1_11_mVector = { inst2Src1_mch5, inst2Src1_mch4, inst2Src1_mch3, inst2Src1_mch2, inst2Src1_mch1, inst2Src1_mch0} ;

 assign inst2Src2_11_mVector = { inst2Src2_mch5, inst2Src2_mch4, inst2Src2_mch3, inst2Src2_mch2, inst2Src2_mch1, inst2Src2_mch0} ;
 assign inst3Src1_11_mVector = { inst3Src1_mch5, inst3Src1_mch4, inst3Src1_mch3, inst3Src1_mch2, inst3Src1_mch1, inst3Src1_mch0} ;

 assign inst3Src2_11_mVector = { inst3Src2_mch5, inst3Src2_mch4, inst3Src2_mch3, inst3Src2_mch2, inst3Src2_mch1, inst3Src2_mch0} ;
 assign inst4Src1_11_mVector = { inst4Src1_mch5, inst4Src1_mch4, inst4Src1_mch3, inst4Src1_mch2, inst4Src1_mch1, inst4Src1_mch0} ;

 assign inst4Src2_11_mVector = { inst4Src2_mch5, inst4Src2_mch4, inst4Src2_mch3, inst4Src2_mch2, inst4Src2_mch1, inst4Src2_mch0} ;
 assign inst5Src1_11_mVector = { inst5Src1_mch5, inst5Src1_mch4, inst5Src1_mch3, inst5Src1_mch2, inst5Src1_mch1, inst5Src1_mch0} ;

 assign inst5Src2_11_mVector = { inst5Src2_mch5, inst5Src2_mch4, inst5Src2_mch3, inst5Src2_mch2, inst5Src2_mch1, inst5Src2_mch0} ;




 always @(*)
	begin
		case (inst0Src1_11_mVector)
		6'd1	:	inst0Data1_11 = bypass0Data_1; 
		6'd2	:	inst0Data1_11 = bypass1Data_1; 
		6'd4	:	inst0Data1_11 = bypass2Data_1; 
		6'd8	:	inst0Data1_11 = bypass3Data_1; 
		6'd16	:	inst0Data1_11 = bypass4Data_1; 
		6'd32	:	inst0Data1_11 = bypass5Data_1; 
		default	:	inst0Data1_11 = data0_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst0Src2_11_mVector)
		6'd1	:	inst0Data2_11 = bypass0Data_1; 
		6'd2	:	inst0Data2_11 = bypass1Data_1; 
		6'd4	:	inst0Data2_11 = bypass2Data_1; 
		6'd8	:	inst0Data2_11 = bypass3Data_1; 
		6'd16	:	inst0Data2_11 = bypass4Data_1; 
		6'd32	:	inst0Data2_11 = bypass5Data_1; 
		default	:	inst0Data2_11 = data1_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst1Src1_11_mVector)
		6'd1	:	inst1Data1_11 = bypass0Data_1; 
		6'd2	:	inst1Data1_11 = bypass1Data_1; 
		6'd4	:	inst1Data1_11 = bypass2Data_1; 
		6'd8	:	inst1Data1_11 = bypass3Data_1; 
		6'd16	:	inst1Data1_11 = bypass4Data_1; 
		6'd32	:	inst1Data1_11 = bypass5Data_1; 
		default	:	inst1Data1_11 = data2_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst1Src2_11_mVector)
		6'd1	:	inst1Data2_11 = bypass0Data_1; 
		6'd2	:	inst1Data2_11 = bypass1Data_1; 
		6'd4	:	inst1Data2_11 = bypass2Data_1; 
		6'd8	:	inst1Data2_11 = bypass3Data_1; 
		6'd16	:	inst1Data2_11 = bypass4Data_1; 
		6'd32	:	inst1Data2_11 = bypass5Data_1; 
		default	:	inst1Data2_11 = data3_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst2Src1_11_mVector)
		6'd1	:	inst2Data1_11 = bypass0Data_1; 
		6'd2	:	inst2Data1_11 = bypass1Data_1; 
		6'd4	:	inst2Data1_11 = bypass2Data_1; 
		6'd8	:	inst2Data1_11 = bypass3Data_1; 
		6'd16	:	inst2Data1_11 = bypass4Data_1; 
		6'd32	:	inst2Data1_11 = bypass5Data_1; 
		default	:	inst2Data1_11 = data4_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst2Src2_11_mVector)
		6'd1	:	inst2Data2_11 = bypass0Data_1; 
		6'd2	:	inst2Data2_11 = bypass1Data_1; 
		6'd4	:	inst2Data2_11 = bypass2Data_1; 
		6'd8	:	inst2Data2_11 = bypass3Data_1; 
		6'd16	:	inst2Data2_11 = bypass4Data_1; 
		6'd32	:	inst2Data2_11 = bypass5Data_1; 
		default	:	inst2Data2_11 = data5_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst3Src1_11_mVector)
		6'd1	:	inst3Data1_11 = bypass0Data_1; 
		6'd2	:	inst3Data1_11 = bypass1Data_1; 
		6'd4	:	inst3Data1_11 = bypass2Data_1; 
		6'd8	:	inst3Data1_11 = bypass3Data_1; 
		6'd16	:	inst3Data1_11 = bypass4Data_1; 
		6'd32	:	inst3Data1_11 = bypass5Data_1; 
		default	:	inst3Data1_11 = data6_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst3Src2_11_mVector)
		6'd1	:	inst3Data2_11 = bypass0Data_1; 
		6'd2	:	inst3Data2_11 = bypass1Data_1; 
		6'd4	:	inst3Data2_11 = bypass2Data_1; 
		6'd8	:	inst3Data2_11 = bypass3Data_1; 
		6'd16	:	inst3Data2_11 = bypass4Data_1; 
		6'd32	:	inst3Data2_11 = bypass5Data_1; 
		default	:	inst3Data2_11 = data7_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst4Src1_11_mVector)
		6'd1	:	inst4Data1_11 = bypass0Data_1; 
		6'd2	:	inst4Data1_11 = bypass1Data_1; 
		6'd4	:	inst4Data1_11 = bypass2Data_1; 
		6'd8	:	inst4Data1_11 = bypass3Data_1; 
		6'd16	:	inst4Data1_11 = bypass4Data_1; 
		6'd32	:	inst4Data1_11 = bypass5Data_1; 
		default	:	inst4Data1_11 = data8_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst4Src2_11_mVector)
		6'd1	:	inst4Data2_11 = bypass0Data_1; 
		6'd2	:	inst4Data2_11 = bypass1Data_1; 
		6'd4	:	inst4Data2_11 = bypass2Data_1; 
		6'd8	:	inst4Data2_11 = bypass3Data_1; 
		6'd16	:	inst4Data2_11 = bypass4Data_1; 
		6'd32	:	inst4Data2_11 = bypass5Data_1; 
		default	:	inst4Data2_11 = data9_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst5Src1_11_mVector)
		6'd1	:	inst5Data1_11 = bypass0Data_1; 
		6'd2	:	inst5Data1_11 = bypass1Data_1; 
		6'd4	:	inst5Data1_11 = bypass2Data_1; 
		6'd8	:	inst5Data1_11 = bypass3Data_1; 
		6'd16	:	inst5Data1_11 = bypass4Data_1; 
		6'd32	:	inst5Data1_11 = bypass5Data_1; 
		default	:	inst5Data1_11 = data10_stage1; 
		endcase
	end

 always @(*)
	begin
		case (inst5Src2_11_mVector)
		6'd1	:	inst5Data2_11 = bypass0Data_1; 
		6'd2	:	inst5Data2_11 = bypass1Data_1; 
		6'd4	:	inst5Data2_11 = bypass2Data_1; 
		6'd8	:	inst5Data2_11 = bypass3Data_1; 
		6'd16	:	inst5Data2_11 = bypass4Data_1; 
		6'd32	:	inst5Data2_11 = bypass5Data_1; 
		default	:	inst5Data2_11 = data11_stage1; 
		endcase
	end




 always@(*)
 begin 
	inst0Data1 = { inst0Data1_11}; 
	inst0Data2 = { inst0Data2_11}; 
	inst1Data1 = { inst1Data1_11}; 
	inst1Data2 = { inst1Data2_11}; 
	inst2Data1 = { inst2Data1_11}; 
	inst2Data2 = { inst2Data2_11}; 
	inst3Data1 = { inst3Data1_11}; 
	inst3Data2 = { inst3Data2_11}; 
	inst4Data1 = { inst4Data1_11}; 
	inst4Data2 = { inst4Data2_11}; 
	inst5Data1 = { inst5Data1_11}; 
	inst5Data2 = { inst5Data2_11}; 
end

 always@(*)
 begin 
	if(mispredictEvent && inst0Mask_l1[mispredictSMTid])
		fuPacketValid0_l1 = 1'b0; 
	else
		fuPacketValid0_l1 = fuPacketValid0_i;
	if(mispredictEvent && inst1Mask_l1[mispredictSMTid])
		fuPacketValid1_l1 = 1'b0; 
	else
		fuPacketValid1_l1 = fuPacketValid1_i;
	if(mispredictEvent && inst2Mask_l1[mispredictSMTid])
		fuPacketValid2_l1 = 1'b0; 
	else
		fuPacketValid2_l1 = fuPacketValid2_i;
	if(mispredictEvent && inst3Mask_l1[mispredictSMTid])
		fuPacketValid3_l1 = 1'b0; 
	else
		fuPacketValid3_l1 = fuPacketValid3_i;
	if(mispredictEvent && inst4Mask_l1[mispredictSMTid])
		fuPacketValid4_l1 = 1'b0; 
	else
		fuPacketValid4_l1 = fuPacketValid4_i;
	if(mispredictEvent && inst5Mask_l1[mispredictSMTid])
		fuPacketValid5_l1 = 1'b0; 
	else
		fuPacketValid5_l1 = fuPacketValid5_i;
end

 assign phyRegRdy_o      = PHY_REG_VALID;
 assign fuPacketValid0_o = fuPacketValid0_l1;
 assign fuPacket0_o = {inst0Data2, inst0Data1, fuPacket0_i};
 assign fuPacketValid1_o = fuPacketValid1_l1;
 assign fuPacket1_o = {inst1Data2, inst1Data1, fuPacket1_i};
 assign fuPacketValid2_o = fuPacketValid2_l1;
 assign fuPacket2_o = {inst2Data2, inst2Data1, fuPacket2_i};
 assign fuPacketValid3_o = fuPacketValid3_l1;
 assign fuPacket3_o = {inst3Data2, inst3Data1, fuPacket3_i};
 assign fuPacketValid4_o = fuPacketValid4_l1;
 assign fuPacket4_o = {inst4Data2, inst4Data1, fuPacket4_i};
 assign fuPacketValid5_o = fuPacketValid5_l1;
 assign fuPacket5_o = {inst5Data2, inst5Data1, fuPacket5_i};


 always @(posedge clk)
 begin:UPDATE_PHY_REG
   integer i, j, k;

   if(reset | exceptionFlag_i)
   begin
        for(i=0;i<`SIZE_RMT;i=i+1)
        begin
                PHY_REG_VALID[i] <= 1'b1;
        end

        for(j=`SIZE_RMT;j<`SIZE_PHYSICAL_TABLE;j=j+1)
        begin
                PHY_REG_VALID[j] <= 1'b0;
        end
   end
   else
   begin

	if(unmapDest0_i[0]) PHY_REG_VALID[unmapDest0_i[`SIZE_PHYSICAL_LOG:1]] <= 1'b0;
	if(unmapDest1_i[0]) PHY_REG_VALID[unmapDest1_i[`SIZE_PHYSICAL_LOG:1]] <= 1'b0;
	if(unmapDest2_i[0]) PHY_REG_VALID[unmapDest2_i[`SIZE_PHYSICAL_LOG:1]] <= 1'b0;
	if(unmapDest3_i[0]) PHY_REG_VALID[unmapDest3_i[`SIZE_PHYSICAL_LOG:1]] <= 1'b0;
	if(unmapDest4_i[0]) PHY_REG_VALID[unmapDest4_i[`SIZE_PHYSICAL_LOG:1]] <= 1'b0;
	if(unmapDest5_i[0]) PHY_REG_VALID[unmapDest5_i[`SIZE_PHYSICAL_LOG:1]] <= 1'b0;

	if(rsr0TagValid_i) PHY_REG_VALID[rsr0Tag_i]    <= 1'b1;
	if(rsr1TagValid_i) PHY_REG_VALID[rsr1Tag_i]    <= 1'b1;
	if(rsr2TagValid_i) PHY_REG_VALID[rsr2Tag_i]    <= 1'b1;
	if(rsr3TagValid_i) PHY_REG_VALID[rsr3Tag_i]    <= 1'b1;
	if(rsr4TagValid_i) PHY_REG_VALID[rsr4Tag_i]    <= 1'b1;
	if(bypassValid5_i) PHY_REG_VALID[bypass5Dest]  <= 1'b1;
	end
 end

endmodule
