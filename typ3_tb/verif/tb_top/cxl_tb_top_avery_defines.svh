//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022 - Present.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_tb_top_avery_defines.svh 
// Date Created    : Mon 13 February 2023
//--------------------------------------------------------------------------------
// Description  :
//     
//    Defines for cxl_tb_top AVERY BFM supports. 
//
//--------------------------------------------------------------------------------
// Version Map     :
//
//   -----------------------------
//    Version             : 1.0
//    Version Information : 
//       1. Initial Version.
//
//--------------------------------------------------------------------------------

`ifndef _CXL_TB_TOP_AVERY_DEFINES_SVH_
`define _CXL_TB_TOP_AVERY_DEFINES_SVH_

    `ifndef APCI_NUM_LANES
        `define APCI_NUM_LANES 16
    `endif
    `ifndef APCI_COMMON_CLOCK
        `define APCI_COMMON_CLOCK 0
    `endif
    `ifndef APCI_PCLK_AS_PHY_INPUT
        `ifdef CXL_PIPE_MODE
           `define APCI_PCLK_AS_PHY_INPUT 1
        `else
           `define APCI_PCLK_AS_PHY_INPUT 0
        `endif
    `endif
    `ifndef APCI_DYNAMIC_PRESET_COEF_UPDATES
        `define APCI_DYNAMIC_PRESET_COEF_UPDATES 0
    `endif
    `ifndef APCI_SERDES_MODE
        `ifdef CXL_PIPE_MODE
           `define APCI_SERDES_MODE 1
        `else
           `define APCI_SERDES_MODE 0
        `endif
    `endif
    `ifndef APCI_COMMON_MODE_V
        `define APCI_COMMON_MODE_V 'hz
    `endif
    `ifndef APCI_GEN1_DW
        `define APCI_GEN1_DW APCI_Width_8bit
    `endif
    `ifndef APCI_GEN2_DW
        `define APCI_GEN2_DW APCI_Width_16bit
    `endif
    `ifndef APCI_GEN3_DW
        `define APCI_GEN3_DW APCI_Width_32bit
    `endif
    `ifndef APCI_GEN4_DW
        `define APCI_GEN4_DW APCI_Width_32bit
    `endif
    `ifndef APCI_GEN5_DW
        `define APCI_GEN5_DW APCI_Width_32bit
    `endif
    `ifndef APCI_GEN6_DW
        `define APCI_GEN6_DW APCI_Width_32bit
    `endif
    `ifndef APCI_CCIX_20G_DW
        `define APCI_CCIX_20G_DW APCI_Width_8bit
    `endif
    `ifndef APCI_CCIX_25G_DW
        `define APCI_CCIX_25G_DW APCI_Width_8bit
    `endif
    `ifndef APCI_GEN1_CLK
        `define APCI_GEN1_CLK APCI_Pclk_250Mhz
    `endif
    `ifndef APCI_GEN2_CLK
        `define APCI_GEN2_CLK APCI_Pclk_250Mhz
    `endif
    `ifndef APCI_GEN3_CLK
        `define APCI_GEN3_CLK APCI_Pclk_250Mhz
    `endif
    `ifndef APCI_GEN4_CLK
        `define APCI_GEN4_CLK APCI_Pclk_500Mhz
    `endif
    `ifndef APCI_GEN5_CLK
        `define APCI_GEN5_CLK APCI_Pclk_1000Mhz
    `endif
    `ifndef APCI_GEN6_CLK
        `define APCI_GEN6_CLK APCI_Pclk_2000Mhz
    `endif
    `ifndef APCI_CCIX_20G_CLK
        `define APCI_CCIX_20G_CLK APCI_CCIX_Pclk_2500Mhz
    `endif
    `ifndef APCI_CCIX_25G_CLK
        `define APCI_CCIX_25G_CLK APCI_CCIX_Pclk_3125Mhz
    `endif
    `ifndef APCI_MAX_DATA_WIDTH
        `define APCI_MAX_DATA_WIDTH APCI_Width_32bit
    `endif
    
    `ifdef APCI_FIXED_WIDTH
        parameter GEN1_W   = APCI_Width_32bit;
        parameter GEN2_W   = APCI_Width_32bit;
        parameter GEN3_W   = APCI_Width_32bit;
        parameter GEN4_W   = APCI_Width_32bit;
        parameter GEN5_W   = APCI_Width_32bit;
        parameter GEN6_W   = APCI_Width_32bit;
        parameter CCIX_20G_W = APCI_Width_32bit;
        parameter CCIX_25G_W = APCI_Width_32bit;
        parameter GEN1_CLK = APCI_Pclk_62_5Mhz; // 62.5M
        parameter GEN2_CLK = APCI_Pclk_125Mhz;  // 125M
        parameter GEN3_CLK = APCI_Pclk_250Mhz;  // 250M
        parameter GEN4_CLK = APCI_Pclk_500Mhz;  // 500M
        parameter GEN5_CLK = APCI_Pclk_1000Mhz; // 1000M
        parameter GEN6_CLK = APCI_Pclk_2000Mhz; // 2000M
        parameter CCIX_20G_CLK = APCI_CCIX_Pclk_625Mhz; // 625M
        parameter CCIX_25G_CLK = APCI_CCIX_Pclk_781_25Mhz; // 781.25M
    `else // fixed  clock
        parameter GEN1_W   = `APCI_GEN1_DW;
        parameter GEN2_W   = `APCI_GEN2_DW;
        parameter GEN3_W   = `APCI_GEN3_DW;
        parameter GEN4_W   = `APCI_GEN4_DW;
        parameter GEN5_W   = `APCI_GEN5_DW;
        parameter GEN6_W   = `APCI_GEN6_DW;
        parameter CCIX_20G_W = `APCI_CCIX_20G_DW;
        parameter CCIX_25G_W = `APCI_CCIX_25G_DW;
        parameter GEN1_CLK = `APCI_GEN1_CLK; 
        parameter GEN2_CLK = `APCI_GEN2_CLK;
        parameter GEN3_CLK = `APCI_GEN3_CLK;
        parameter GEN4_CLK = `APCI_GEN4_CLK; 
        parameter GEN5_CLK = `APCI_GEN5_CLK; 
        parameter GEN6_CLK = `APCI_GEN6_CLK; 
        parameter CCIX_20G_CLK = `APCI_CCIX_20G_CLK;
        parameter CCIX_25G_CLK = `APCI_CCIX_25G_CLK;
    `endif
    

`endif//_CXL_TB_TOP_AVERY_DEFINES_SVH_

