//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_tb_top_config.sv 
// Date Created    : Mon 07 February 2022
//--------------------------------------------------------------------------------
// Description  :
//     
//    TB Config to define the required Libraries. 
//
//--------------------------------------------------------------------------------
// Version Map     :
//   -----------------------------
//    Version             : 1.4
//    Version Information : 
//       1. Added SIM_REVB_DEVKIT.
//
//   -----------------------------
//    Version             : 1.3
//    Version Information : 
//       1. Added QPDS_B0A0_ED, QPDS_B0A0 CXLTYP3DDR.
//       2. Added CFG_IP /QHIP_MIRROR_IP.
//
//   -----------------------------
//    Version             : 1.2
//    Version Information : 
//       1. Added QPDS_ED CXLTYP3DDR.
//
//   -----------------------------
//    Version             : 1.1
//    Version Information : 
//       1. Added QPDS CXLTYP3DDR.
//
//   -----------------------------
//    Version             : 1.0
//    Version Information : 
//       1. Initial Version.
//
//--------------------------------------------------------------------------------

`ifndef CXL_TB_TOP_CONFIG__SV
`define CXL_TB_TOP_CONFIG__SV

    config cxl_tb_top_config;
        
        design  tb_lib.cxl_tb_top;

        `ifdef QPDS
          `ifdef CXLTYP3DDR
                default liblist tb_lib avmm_interconnect lib ;
          `endif    
        `elsif QPDS_ED
          `ifdef CXLTYP3DDR
                default liblist tb_lib avmm_interconnect lib ;
          `endif
        `elsif QPDS_ED_B0
          `ifdef SIM_REVB_DEVKIT
             default liblist tb_lib ed_ip_emif_lib lib eda_lib ;
          `else //REVA_DEVKIT
             default liblist tb_lib lib eda_lib ;
          `endif
        `elsif QPDS_B0A0_ED
          `ifdef CXLTYP3DDR
                default liblist tb_lib avmm_interconnect lib ;
          `endif
        `elsif QPDS_B0A0
          `ifdef CXLTYP3DDR
                default liblist tb_lib avmm_interconnect lib ;
          `endif
        `elsif QHIP_MIRROR_CFG
            default liblist tb_lib avmm_interconnect qhip_lib_2 cxlbasehip_lib_1 cxlbasehip_top_4 ;
        `elsif REPO
          `ifdef T3IP
             `ifdef ENABLE_4_BBS_SLICE
                default liblist tb_lib avmm_interconnect qhip_lib_2 cxl_memexp_lib_1 cxl_memexp_top_slice_based_4 mem_model_tb ;
             `else
                default liblist tb_lib avmm_interconnect qhip_lib_2 cxl_memexp_lib_1 cxl_memexp_top_4 mem_model_tb ;
             `endif
          `elsif T2IP
             `ifdef ENABLE_4_BBS_SLICE
                default liblist tb_lib avmm_interconnect qhip_lib_2 cxl_t2ip_top_lib_1 cxl_t2ip_top_slice_based_4 mem_model_tb ;
             `else
                default liblist tb_lib avmm_interconnect qhip_lib_2 cxl_t2ip_top_lib_1 cxl_t2ip_top_4 mem_model_tb ;
             `endif
          `elsif T1IP
             `ifdef ENABLE_4_BBS_SLICE
                default liblist tb_lib avmm_interconnect qhip_lib_2 cxltyp1_ed_lib_1 cxltyp1_ed_slice_based_4 ;
             `else
                default liblist tb_lib avmm_interconnect qhip_lib_2 cxltyp1_ed_lib_1 cxltyp1_ed_4 ;
             `endif
          `endif
        `else
            default liblist tb_lib avmm_interconnect rtile_cxl_ip cxl_memexp_sip_top;
        `endif

    
    endconfig

`endif//CXL_TB_TOP_CONFIG__SV
