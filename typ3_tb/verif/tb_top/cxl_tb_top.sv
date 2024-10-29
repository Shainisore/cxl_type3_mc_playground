//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_tb_top.sv 
// Date Created    : Tue 23 November 2021
//--------------------------------------------------------------------------------
// Description  :
//     
//    CXL_RTL, Memory model and Avery RC.
//
//--------------------------------------------------------------------------------
// Version Map     :
//
//   -----------------------------
//    Version             : 1.7
//    Version Information : 
//       1. Added WLF waveform dump commands for Questasim.
//
//   -----------------------------
//    Version             : 1.6
//    Version Information : 
//       1. Added Status Checks
//
//   -----------------------------
//    Version             : 1.5
//    Version Information : 
//       1. Added CFG_IP /QHIP_MIRROR_IP.
//
//   -----------------------------
//    Version             : 1.4
//    Version Information : 
//       1. Added QPDS_ED option for CXLTYP3DDR.
//
//   -----------------------------
//    Version             : 1.3
//    Version Information : 
//       1. Added QPDS option for CXLTYP3DDR.
//
//   -----------------------------
//    Version             : 1.2
//    Version Information : 
//       1. Updated for CXL TYPE3 DDR Support.
//
//   -----------------------------
//    Version             : 1.1
//    Version Information : 
//       1. Removed conditional Compile for SPI ports.
//
//   -----------------------------
//    Version             : 1.0
//    Version Information : 
//       1. Initial Version.
//
//--------------------------------------------------------------------------------

`ifndef CXL_TB_TOP__SV
`define CXL_TB_TOP__SV

    //---------------------------------------------------------------------------
    //Avery BFM Defines
    //---------------------------------------------------------------------------
    `include "apci_defines.svh"

    //---------------------------------------------------------------------------
    `ifndef TB_DTL_MODE
        `include "cxl_seq_lib.svh";
    `endif
    //---------------------------------------------------------------------------
    
    module cxl_tb_top();
    
        //---------------------------------------------------------------------------
        //TB Top defines
        //---------------------------------------------------------------------------
        `include "cxl_tb_top_defines.svhp"
        `include "cxl_tb_top_avery_defines.svh"
    
        //---------------------------------------------------------------------------
        //PKG Imports
        //---------------------------------------------------------------------------
        import                                                          uvm_pkg::*;
        import                                                          apci_pkg::*;
        import                                                          apci_pkg_test::*;
        import                                                          cxl_tb_pkg::*;

        //---------------------------------------------------------------------------
        //TB Base test - for DTL option
        //---------------------------------------------------------------------------
        `include "cxl_base_test.sv"
        //---------------------------------------------------------------------------

        `ifdef CXLTYP3DDR
            import                                                      cxlip_top_pkg::*;
            `define INC_CXLIP_PKG
        `elsif T3IP
            import                                                      cxlip_top_pkg::*;
            `define INC_CXLIP_PKG
        `elsif T2IP
            import                                                      cxlip_top_pkg::*;
            `define INC_CXLIP_PKG
        `elsif T1IP 
            //NA
        `elsif QHIP_MIRROR_CFG
            //NA
        `elsif BASE_IP
            //NA
        `else    
            import                                                      bbs_pkg::*;
            `define INC_BBS_PKG
        `endif
    
        //---------------------------------------------------------------------------
        //Global Declarations
        //---------------------------------------------------------------------------
        apci_pipe_intf                                                  rc_pif[`APCI_NUM_LANES]();
        apci_pipe_intf                                                  ep_pif[`APCI_NUM_LANES]();
        apci_device                                                     apci_rc;

        //---------------------------------------------------------------------------
        //Wire/logic/net/reg declarations
        //---------------------------------------------------------------------------
        wire [15:0]                                                     cxl_rx_n, cxl_rx_p, cxl_tx_n, cxl_tx_p;

        wire [`APCI_NUM_LANES-1:0]                                      tx_data, tx_datan, rx_data, rx_datan;
        wire                                                            clkreq_n;
    
        //---------------------------------------------------------------------------
        //To RTILE
        //---------------------------------------------------------------------------
        logic                                                           refclk0;
        logic                                                           refclk1;
        logic                                                           refclk2;
        logic                                                           refclk3;
        logic                                                           refclk4;
        logic                                                           resetn;
    
        //---------------------------------------------------------------------------
        //To RTILE: CXL_SIM reduction Pipe Mode 
        //---------------------------------------------------------------------------
        `ifdef CXL_PIPE_MODE
            logic         phy_sys_ial_0__pipe_Reset_l;
            logic         phy_sys_ial_1__pipe_Reset_l;
            logic         phy_sys_ial_2__pipe_Reset_l;
            logic         phy_sys_ial_3__pipe_Reset_l;
            logic         phy_sys_ial_4__pipe_Reset_l;
            logic         phy_sys_ial_5__pipe_Reset_l;
            logic         phy_sys_ial_6__pipe_Reset_l;
            logic         phy_sys_ial_7__pipe_Reset_l;
            logic         phy_sys_ial_8__pipe_Reset_l;
            logic         phy_sys_ial_9__pipe_Reset_l;
            logic         phy_sys_ial_10__pipe_Reset_l;
            logic         phy_sys_ial_11__pipe_Reset_l;
            logic         phy_sys_ial_12__pipe_Reset_l;
            logic         phy_sys_ial_13__pipe_Reset_l;
            logic         phy_sys_ial_14__pipe_Reset_l;
            logic         phy_sys_ial_15__pipe_Reset_l;
            logic         o_phy_0_pipe_TxDataValid;
            logic [39:0]  o_phy_0_pipe_TxData;
            logic         o_phy_0_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_0_pipe_TxElecIdle;
            logic [3:0]   o_phy_0_pipe_PowerDown;
            logic [2:0]   o_phy_0_pipe_Rate;
            logic         o_phy_0_pipe_PclkChangeAck;
            logic [2:0]   o_phy_0_pipe_PCLKRate;
            logic [1:0]   o_phy_0_pipe_Width;
            logic         o_phy_0_pipe_PCLK;
            logic         o_phy_0_pipe_rxelecidle_disable;
            logic         o_phy_0_pipe_txcmnmode_disable;
            logic         o_phy_0_pipe_srisenable;
            logic         o_phy_0_pipe_RxStandby;
            logic         o_phy_0_pipe_RxTermination;
            logic [1:0]   o_phy_0_pipe_RxWidth;
            logic [7:0]   o_phy_0_pipe_M2P_MessageBus;
            logic         o_phy_0_pipe_rxbitslip_req;
            logic [4:0]   o_phy_0_pipe_rxbitslip_va;
            logic         i_phy_0_pipe_RxClk;
            logic         i_phy_0_pipe_RxValid;
            logic [39:0]  i_phy_0_pipe_RxData;
            logic         i_phy_0_pipe_RxElecIdle;
            logic [2:0]   i_phy_0_pipe_RxStatus;
            logic         i_phy_0_pipe_RxStandbyStatus;
            logic         i_phy_0_pipe_PhyStatus;
            logic         i_phy_0_pipe_PclkChangeOk;
            logic [7:0]   i_phy_0_pipe_P2M_MessageBus;
            logic         i_phy_0_pipe_RxBitSlip_Ack;
            logic         o_phy_1_pipe_TxDataValid;
            logic [39:0]  o_phy_1_pipe_TxData;
            logic         o_phy_1_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_1_pipe_TxElecIdle;
            logic [3:0]   o_phy_1_pipe_PowerDown;
            logic [2:0]   o_phy_1_pipe_Rate;
            logic         o_phy_1_pipe_PclkChangeAck;
            logic [2:0]   o_phy_1_pipe_PCLKRate;
            logic [1:0]   o_phy_1_pipe_Width;
            logic         o_phy_1_pipe_PCLK;
            logic         o_phy_1_pipe_rxelecidle_disable;
            logic         o_phy_1_pipe_txcmnmode_disable;
            logic         o_phy_1_pipe_srisenable;
            logic         o_phy_1_pipe_RxStandby;
            logic         o_phy_1_pipe_RxTermination;
            logic [1:0]   o_phy_1_pipe_RxWidth;
            logic [7:0]   o_phy_1_pipe_M2P_MessageBus;
            logic         o_phy_1_pipe_rxbitslip_req;
            logic [4:0]   o_phy_1_pipe_rxbitslip_va;
            logic         i_phy_1_pipe_RxClk;
            logic         i_phy_1_pipe_RxValid;
            logic [39:0]  i_phy_1_pipe_RxData;
            logic         i_phy_1_pipe_RxElecIdle;
            logic [2:0]   i_phy_1_pipe_RxStatus;
            logic         i_phy_1_pipe_RxStandbyStatus;
            logic         i_phy_1_pipe_PhyStatus;
            logic         i_phy_1_pipe_PclkChangeOk;
            logic [7:0]   i_phy_1_pipe_P2M_MessageBus;
            logic         i_phy_1_pipe_RxBitSlip_Ack;
            logic         o_phy_2_pipe_TxDataValid;
            logic [39:0]  o_phy_2_pipe_TxData;
            logic         o_phy_2_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_2_pipe_TxElecIdle;
            logic [3:0]   o_phy_2_pipe_PowerDown;
            logic [2:0]   o_phy_2_pipe_Rate;
            logic         o_phy_2_pipe_PclkChangeAck;
            logic [2:0]   o_phy_2_pipe_PCLKRate;
            logic [1:0]   o_phy_2_pipe_Width;
            logic         o_phy_2_pipe_PCLK;
            logic         o_phy_2_pipe_rxelecidle_disable;
            logic         o_phy_2_pipe_txcmnmode_disable;
            logic         o_phy_2_pipe_srisenable;
            logic         o_phy_2_pipe_RxStandby;
            logic         o_phy_2_pipe_RxTermination;
            logic [1:0]   o_phy_2_pipe_RxWidth;
            logic [7:0]   o_phy_2_pipe_M2P_MessageBus;
            logic         o_phy_2_pipe_rxbitslip_req;
            logic [4:0]   o_phy_2_pipe_rxbitslip_va;
            logic         i_phy_2_pipe_RxClk;
            logic         i_phy_2_pipe_RxValid;
            logic [39:0]  i_phy_2_pipe_RxData;
            logic         i_phy_2_pipe_RxElecIdle;
            logic [2:0]   i_phy_2_pipe_RxStatus;
            logic         i_phy_2_pipe_RxStandbyStatus;
            logic         i_phy_2_pipe_PhyStatus;
            logic         i_phy_2_pipe_PclkChangeOk;
            logic [7:0]   i_phy_2_pipe_P2M_MessageBus;
            logic         i_phy_2_pipe_RxBitSlip_Ack;
            logic         o_phy_3_pipe_TxDataValid;
            logic [39:0]  o_phy_3_pipe_TxData;
            logic         o_phy_3_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_3_pipe_TxElecIdle;
            logic [3:0]   o_phy_3_pipe_PowerDown;
            logic [2:0]   o_phy_3_pipe_Rate;
            logic         o_phy_3_pipe_PclkChangeAck;
            logic [2:0]   o_phy_3_pipe_PCLKRate;
            logic [1:0]   o_phy_3_pipe_Width;
            logic         o_phy_3_pipe_PCLK;
            logic         o_phy_3_pipe_rxelecidle_disable;
            logic         o_phy_3_pipe_txcmnmode_disable;
            logic         o_phy_3_pipe_srisenable;
            logic         o_phy_3_pipe_RxStandby;
            logic         o_phy_3_pipe_RxTermination;
            logic [1:0]   o_phy_3_pipe_RxWidth;
            logic [7:0]   o_phy_3_pipe_M2P_MessageBus;
            logic         o_phy_3_pipe_rxbitslip_req;
            logic [4:0]   o_phy_3_pipe_rxbitslip_va;
            logic         i_phy_3_pipe_RxClk;
            logic         i_phy_3_pipe_RxValid;
            logic [39:0]  i_phy_3_pipe_RxData;
            logic         i_phy_3_pipe_RxElecIdle;
            logic [2:0]   i_phy_3_pipe_RxStatus;
            logic         i_phy_3_pipe_RxStandbyStatus;
            logic         i_phy_3_pipe_PhyStatus;
            logic         i_phy_3_pipe_PclkChangeOk;
            logic [7:0]   i_phy_3_pipe_P2M_MessageBus;
            logic         i_phy_3_pipe_RxBitSlip_Ack;
            logic         o_phy_4_pipe_TxDataValid;
            logic [39:0]  o_phy_4_pipe_TxData;
            logic         o_phy_4_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_4_pipe_TxElecIdle;
            logic [3:0]   o_phy_4_pipe_PowerDown;
            logic [2:0]   o_phy_4_pipe_Rate;
            logic         o_phy_4_pipe_PclkChangeAck;
            logic [2:0]   o_phy_4_pipe_PCLKRate;
            logic [1:0]   o_phy_4_pipe_Width;
            logic         o_phy_4_pipe_PCLK;
            logic         o_phy_4_pipe_rxelecidle_disable;
            logic         o_phy_4_pipe_txcmnmode_disable;
            logic         o_phy_4_pipe_srisenable;
            logic         o_phy_4_pipe_RxStandby;
            logic         o_phy_4_pipe_RxTermination;
            logic [1:0]   o_phy_4_pipe_RxWidth;
            logic [7:0]   o_phy_4_pipe_M2P_MessageBus;
            logic         o_phy_4_pipe_rxbitslip_req;
            logic [4:0]   o_phy_4_pipe_rxbitslip_va;
            logic         i_phy_4_pipe_RxClk;
            logic         i_phy_4_pipe_RxValid;
            logic [39:0]  i_phy_4_pipe_RxData;
            logic         i_phy_4_pipe_RxElecIdle;
            logic [2:0]   i_phy_4_pipe_RxStatus;
            logic         i_phy_4_pipe_RxStandbyStatus;
            logic         i_phy_4_pipe_PhyStatus;
            logic         i_phy_4_pipe_PclkChangeOk;
            logic [7:0]   i_phy_4_pipe_P2M_MessageBus;
            logic         i_phy_4_pipe_RxBitSlip_Ack;
            logic         o_phy_5_pipe_TxDataValid;
            logic [39:0]  o_phy_5_pipe_TxData;
            logic         o_phy_5_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_5_pipe_TxElecIdle;
            logic [3:0]   o_phy_5_pipe_PowerDown;
            logic [2:0]   o_phy_5_pipe_Rate;
            logic         o_phy_5_pipe_PclkChangeAck;
            logic [2:0]   o_phy_5_pipe_PCLKRate;
            logic [1:0]   o_phy_5_pipe_Width;
            logic         o_phy_5_pipe_PCLK;
            logic         o_phy_5_pipe_rxelecidle_disable;
            logic         o_phy_5_pipe_txcmnmode_disable;
            logic         o_phy_5_pipe_srisenable;
            logic         o_phy_5_pipe_RxStandby;
            logic         o_phy_5_pipe_RxTermination;
            logic [1:0]   o_phy_5_pipe_RxWidth;
            logic [7:0]   o_phy_5_pipe_M2P_MessageBus;
            logic         o_phy_5_pipe_rxbitslip_req;
            logic [4:0]   o_phy_5_pipe_rxbitslip_va;
            logic         i_phy_5_pipe_RxClk;
            logic         i_phy_5_pipe_RxValid;
            logic [39:0]  i_phy_5_pipe_RxData;
            logic         i_phy_5_pipe_RxElecIdle;
            logic [2:0]   i_phy_5_pipe_RxStatus;
            logic         i_phy_5_pipe_RxStandbyStatus;
            logic         i_phy_5_pipe_PhyStatus;
            logic         i_phy_5_pipe_PclkChangeOk;
            logic [7:0]   i_phy_5_pipe_P2M_MessageBus;
            logic         i_phy_5_pipe_RxBitSlip_Ack;
            logic         o_phy_6_pipe_TxDataValid;
            logic [39:0]  o_phy_6_pipe_TxData;
            logic         o_phy_6_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_6_pipe_TxElecIdle;
            logic [3:0]   o_phy_6_pipe_PowerDown;
            logic [2:0]   o_phy_6_pipe_Rate;
            logic         o_phy_6_pipe_PclkChangeAck;
            logic [2:0]   o_phy_6_pipe_PCLKRate;
            logic [1:0]   o_phy_6_pipe_Width;
            logic         o_phy_6_pipe_PCLK;
            logic         o_phy_6_pipe_rxelecidle_disable;
            logic         o_phy_6_pipe_txcmnmode_disable;
            logic         o_phy_6_pipe_srisenable;
            logic         o_phy_6_pipe_RxStandby;
            logic         o_phy_6_pipe_RxTermination;
            logic [1:0]   o_phy_6_pipe_RxWidth;
            logic [7:0]   o_phy_6_pipe_M2P_MessageBus;
            logic         o_phy_6_pipe_rxbitslip_req;
            logic [4:0]   o_phy_6_pipe_rxbitslip_va;
            logic         i_phy_6_pipe_RxClk;
            logic         i_phy_6_pipe_RxValid;
            logic [39:0]  i_phy_6_pipe_RxData;
            logic         i_phy_6_pipe_RxElecIdle;
            logic [2:0]   i_phy_6_pipe_RxStatus;
            logic         i_phy_6_pipe_RxStandbyStatus;
            logic         i_phy_6_pipe_PhyStatus;
            logic         i_phy_6_pipe_PclkChangeOk;
            logic [7:0]   i_phy_6_pipe_P2M_MessageBus;
            logic         i_phy_6_pipe_RxBitSlip_Ack;
            logic         o_phy_7_pipe_TxDataValid;
            logic [39:0]  o_phy_7_pipe_TxData;
            logic         o_phy_7_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_7_pipe_TxElecIdle;
            logic [3:0]   o_phy_7_pipe_PowerDown;
            logic [2:0]   o_phy_7_pipe_Rate;
            logic         o_phy_7_pipe_PclkChangeAck;
            logic [2:0]   o_phy_7_pipe_PCLKRate;
            logic [1:0]   o_phy_7_pipe_Width;
            logic         o_phy_7_pipe_PCLK;
            logic         o_phy_7_pipe_rxelecidle_disable;
            logic         o_phy_7_pipe_txcmnmode_disable;
            logic         o_phy_7_pipe_srisenable;
            logic         o_phy_7_pipe_RxStandby;
            logic         o_phy_7_pipe_RxTermination;
            logic [1:0]   o_phy_7_pipe_RxWidth;
            logic [7:0]   o_phy_7_pipe_M2P_MessageBus;
            logic         o_phy_7_pipe_rxbitslip_req;
            logic [4:0]   o_phy_7_pipe_rxbitslip_va;
            logic         i_phy_7_pipe_RxClk;
            logic         i_phy_7_pipe_RxValid;
            logic [39:0]  i_phy_7_pipe_RxData;
            logic         i_phy_7_pipe_RxElecIdle;
            logic [2:0]   i_phy_7_pipe_RxStatus;
            logic         i_phy_7_pipe_RxStandbyStatus;
            logic         i_phy_7_pipe_PhyStatus;
            logic         i_phy_7_pipe_PclkChangeOk;
            logic [7:0]   i_phy_7_pipe_P2M_MessageBus;
            logic         i_phy_7_pipe_RxBitSlip_Ack;
            logic         o_phy_8_pipe_TxDataValid;
            logic [39:0]  o_phy_8_pipe_TxData;
            logic         o_phy_8_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_8_pipe_TxElecIdle;
            logic [3:0]   o_phy_8_pipe_PowerDown;
            logic [2:0]   o_phy_8_pipe_Rate;
            logic         o_phy_8_pipe_PclkChangeAck;
            logic [2:0]   o_phy_8_pipe_PCLKRate;
            logic [1:0]   o_phy_8_pipe_Width;
            logic         o_phy_8_pipe_PCLK;
            logic         o_phy_8_pipe_rxelecidle_disable;
            logic         o_phy_8_pipe_txcmnmode_disable;
            logic         o_phy_8_pipe_srisenable;
            logic         o_phy_8_pipe_RxStandby;
            logic         o_phy_8_pipe_RxTermination;
            logic [1:0]   o_phy_8_pipe_RxWidth;
            logic [7:0]   o_phy_8_pipe_M2P_MessageBus;
            logic         o_phy_8_pipe_rxbitslip_req;
            logic [4:0]   o_phy_8_pipe_rxbitslip_va;
            logic         i_phy_8_pipe_RxClk;
            logic         i_phy_8_pipe_RxValid;
            logic [39:0]  i_phy_8_pipe_RxData;
            logic         i_phy_8_pipe_RxElecIdle;
            logic [2:0]   i_phy_8_pipe_RxStatus;
            logic         i_phy_8_pipe_RxStandbyStatus;
            logic         i_phy_8_pipe_PhyStatus;
            logic         i_phy_8_pipe_PclkChangeOk;
            logic [7:0]   i_phy_8_pipe_P2M_MessageBus;
            logic         i_phy_8_pipe_RxBitSlip_Ack;
            logic         o_phy_9_pipe_TxDataValid;
            logic [39:0]  o_phy_9_pipe_TxData;
            logic         o_phy_9_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_9_pipe_TxElecIdle;
            logic [3:0]   o_phy_9_pipe_PowerDown;
            logic [2:0]   o_phy_9_pipe_Rate;
            logic         o_phy_9_pipe_PclkChangeAck;
            logic [2:0]   o_phy_9_pipe_PCLKRate;
            logic [1:0]   o_phy_9_pipe_Width;
            logic         o_phy_9_pipe_PCLK;
            logic         o_phy_9_pipe_rxelecidle_disable;
            logic         o_phy_9_pipe_txcmnmode_disable;
            logic         o_phy_9_pipe_srisenable;
            logic         o_phy_9_pipe_RxStandby;
            logic         o_phy_9_pipe_RxTermination;
            logic [1:0]   o_phy_9_pipe_RxWidth;
            logic [7:0]   o_phy_9_pipe_M2P_MessageBus;
            logic         o_phy_9_pipe_rxbitslip_req;
            logic [4:0]   o_phy_9_pipe_rxbitslip_va;
            logic         i_phy_9_pipe_RxClk;
            logic         i_phy_9_pipe_RxValid;
            logic [39:0]  i_phy_9_pipe_RxData;
            logic         i_phy_9_pipe_RxElecIdle;
            logic [2:0]   i_phy_9_pipe_RxStatus;
            logic         i_phy_9_pipe_RxStandbyStatus;
            logic         i_phy_9_pipe_PhyStatus;
            logic         i_phy_9_pipe_PclkChangeOk;
            logic [7:0]   i_phy_9_pipe_P2M_MessageBus;
            logic         i_phy_9_pipe_RxBitSlip_Ack;
            logic         o_phy_10_pipe_TxDataValid;
            logic [39:0]  o_phy_10_pipe_TxData;
            logic         o_phy_10_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_10_pipe_TxElecIdle;
            logic [3:0]   o_phy_10_pipe_PowerDown;
            logic [2:0]   o_phy_10_pipe_Rate;
            logic         o_phy_10_pipe_PclkChangeAck;
            logic [2:0]   o_phy_10_pipe_PCLKRate;
            logic [1:0]   o_phy_10_pipe_Width;
            logic         o_phy_10_pipe_PCLK;
            logic         o_phy_10_pipe_rxelecidle_disable;
            logic         o_phy_10_pipe_txcmnmode_disable;
            logic         o_phy_10_pipe_srisenable;
            logic         o_phy_10_pipe_RxStandby;
            logic         o_phy_10_pipe_RxTermination;
            logic [1:0]   o_phy_10_pipe_RxWidth;
            logic [7:0]   o_phy_10_pipe_M2P_MessageBus;
            logic         o_phy_10_pipe_rxbitslip_req;
            logic [4:0]   o_phy_10_pipe_rxbitslip_va;
            logic         i_phy_10_pipe_RxClk;
            logic         i_phy_10_pipe_RxValid;
            logic [39:0]  i_phy_10_pipe_RxData;
            logic         i_phy_10_pipe_RxElecIdle;
            logic [2:0]   i_phy_10_pipe_RxStatus;
            logic         i_phy_10_pipe_RxStandbyStatus;
            logic         i_phy_10_pipe_PhyStatus;
            logic         i_phy_10_pipe_PclkChangeOk;
            logic [7:0]   i_phy_10_pipe_P2M_MessageBus;
            logic         i_phy_10_pipe_RxBitSlip_Ack;
            logic         o_phy_11_pipe_TxDataValid;
            logic [39:0]  o_phy_11_pipe_TxData;
            logic         o_phy_11_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_11_pipe_TxElecIdle;
            logic [3:0]   o_phy_11_pipe_PowerDown;
            logic [2:0]   o_phy_11_pipe_Rate;
            logic         o_phy_11_pipe_PclkChangeAck;
            logic [2:0]   o_phy_11_pipe_PCLKRate;
            logic [1:0]   o_phy_11_pipe_Width;
            logic         o_phy_11_pipe_PCLK;
            logic         o_phy_11_pipe_rxelecidle_disable;
            logic         o_phy_11_pipe_txcmnmode_disable;
            logic         o_phy_11_pipe_srisenable;
            logic         o_phy_11_pipe_RxStandby;
            logic         o_phy_11_pipe_RxTermination;
            logic [1:0]   o_phy_11_pipe_RxWidth;
            logic [7:0]   o_phy_11_pipe_M2P_MessageBus;
            logic         o_phy_11_pipe_rxbitslip_req;
            logic [4:0]   o_phy_11_pipe_rxbitslip_va;
            logic         i_phy_11_pipe_RxClk;
            logic         i_phy_11_pipe_RxValid;
            logic [39:0]  i_phy_11_pipe_RxData;
            logic         i_phy_11_pipe_RxElecIdle;
            logic [2:0]   i_phy_11_pipe_RxStatus;
            logic         i_phy_11_pipe_RxStandbyStatus;
            logic         i_phy_11_pipe_PhyStatus;
            logic         i_phy_11_pipe_PclkChangeOk;
            logic [7:0]   i_phy_11_pipe_P2M_MessageBus;
            logic         i_phy_11_pipe_RxBitSlip_Ack;
            logic         o_phy_12_pipe_TxDataValid;
            logic [39:0]  o_phy_12_pipe_TxData;
            logic         o_phy_12_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_12_pipe_TxElecIdle;
            logic [3:0]   o_phy_12_pipe_PowerDown;
            logic [2:0]   o_phy_12_pipe_Rate;
            logic         o_phy_12_pipe_PclkChangeAck;
            logic [2:0]   o_phy_12_pipe_PCLKRate;
            logic [1:0]   o_phy_12_pipe_Width;
            logic         o_phy_12_pipe_PCLK;
            logic         o_phy_12_pipe_rxelecidle_disable;
            logic         o_phy_12_pipe_txcmnmode_disable;
            logic         o_phy_12_pipe_srisenable;
            logic         o_phy_12_pipe_RxStandby;
            logic         o_phy_12_pipe_RxTermination;
            logic [1:0]   o_phy_12_pipe_RxWidth;
            logic [7:0]   o_phy_12_pipe_M2P_MessageBus;
            logic         o_phy_12_pipe_rxbitslip_req;
            logic [4:0]   o_phy_12_pipe_rxbitslip_va;
            logic         i_phy_12_pipe_RxClk;
            logic         i_phy_12_pipe_RxValid;
            logic [39:0]  i_phy_12_pipe_RxData;
            logic         i_phy_12_pipe_RxElecIdle;
            logic [2:0]   i_phy_12_pipe_RxStatus;
            logic         i_phy_12_pipe_RxStandbyStatus;
            logic         i_phy_12_pipe_PhyStatus;
            logic         i_phy_12_pipe_PclkChangeOk;
            logic [7:0]   i_phy_12_pipe_P2M_MessageBus;
            logic         i_phy_12_pipe_RxBitSlip_Ack;
            logic         o_phy_13_pipe_TxDataValid;
            logic [39:0]  o_phy_13_pipe_TxData;
            logic         o_phy_13_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_13_pipe_TxElecIdle;
            logic [3:0]   o_phy_13_pipe_PowerDown;
            logic [2:0]   o_phy_13_pipe_Rate;
            logic         o_phy_13_pipe_PclkChangeAck;
            logic [2:0]   o_phy_13_pipe_PCLKRate;
            logic [1:0]   o_phy_13_pipe_Width;
            logic         o_phy_13_pipe_PCLK;
            logic         o_phy_13_pipe_rxelecidle_disable;
            logic         o_phy_13_pipe_txcmnmode_disable;
            logic         o_phy_13_pipe_srisenable;
            logic         o_phy_13_pipe_RxStandby;
            logic         o_phy_13_pipe_RxTermination;
            logic [1:0]   o_phy_13_pipe_RxWidth;
            logic [7:0]   o_phy_13_pipe_M2P_MessageBus;
            logic         o_phy_13_pipe_rxbitslip_req;
            logic [4:0]   o_phy_13_pipe_rxbitslip_va;
            logic         i_phy_13_pipe_RxClk;
            logic         i_phy_13_pipe_RxValid;
            logic [39:0]  i_phy_13_pipe_RxData;
            logic         i_phy_13_pipe_RxElecIdle;
            logic [2:0]   i_phy_13_pipe_RxStatus;
            logic         i_phy_13_pipe_RxStandbyStatus;
            logic         i_phy_13_pipe_PhyStatus;
            logic         i_phy_13_pipe_PclkChangeOk;
            logic [7:0]   i_phy_13_pipe_P2M_MessageBus;
            logic         i_phy_13_pipe_RxBitSlip_Ack;
            logic         o_phy_14_pipe_TxDataValid;
            logic [39:0]  o_phy_14_pipe_TxData;
            logic         o_phy_14_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_14_pipe_TxElecIdle;
            logic [3:0]   o_phy_14_pipe_PowerDown;
            logic [2:0]   o_phy_14_pipe_Rate;
            logic         o_phy_14_pipe_PclkChangeAck;
            logic [2:0]   o_phy_14_pipe_PCLKRate;
            logic [1:0]   o_phy_14_pipe_Width;
            logic         o_phy_14_pipe_PCLK;
            logic         o_phy_14_pipe_rxelecidle_disable;
            logic         o_phy_14_pipe_txcmnmode_disable;
            logic         o_phy_14_pipe_srisenable;
            logic         o_phy_14_pipe_RxStandby;
            logic         o_phy_14_pipe_RxTermination;
            logic [1:0]   o_phy_14_pipe_RxWidth;
            logic [7:0]   o_phy_14_pipe_M2P_MessageBus;
            logic         o_phy_14_pipe_rxbitslip_req;
            logic [4:0]   o_phy_14_pipe_rxbitslip_va;
            logic         i_phy_14_pipe_RxClk;
            logic         i_phy_14_pipe_RxValid;
            logic [39:0]  i_phy_14_pipe_RxData;
            logic         i_phy_14_pipe_RxElecIdle;
            logic [2:0]   i_phy_14_pipe_RxStatus;
            logic         i_phy_14_pipe_RxStandbyStatus;
            logic         i_phy_14_pipe_PhyStatus;
            logic         i_phy_14_pipe_PclkChangeOk;
            logic [7:0]   i_phy_14_pipe_P2M_MessageBus;
            logic         i_phy_14_pipe_RxBitSlip_Ack;
            logic         o_phy_15_pipe_TxDataValid;
            logic [39:0]  o_phy_15_pipe_TxData;
            logic         o_phy_15_pipe_TxDetRxLpbk;
            logic [3:0]   o_phy_15_pipe_TxElecIdle;
            logic [3:0]   o_phy_15_pipe_PowerDown;
            logic [2:0]   o_phy_15_pipe_Rate;
            logic         o_phy_15_pipe_PclkChangeAck;
            logic [2:0]   o_phy_15_pipe_PCLKRate;
            logic [1:0]   o_phy_15_pipe_Width;
            logic         o_phy_15_pipe_PCLK;
            logic         o_phy_15_pipe_rxelecidle_disable;
            logic         o_phy_15_pipe_txcmnmode_disable;
            logic         o_phy_15_pipe_srisenable;
            logic         o_phy_15_pipe_RxStandby;
            logic         o_phy_15_pipe_RxTermination;
            logic [1:0]   o_phy_15_pipe_RxWidth;
            logic [7:0]   o_phy_15_pipe_M2P_MessageBus;
            logic         o_phy_15_pipe_rxbitslip_req;
            logic [4:0]   o_phy_15_pipe_rxbitslip_va;
            logic         i_phy_15_pipe_RxClk;
            logic         i_phy_15_pipe_RxValid;
            logic [39:0]  i_phy_15_pipe_RxData;
            logic         i_phy_15_pipe_RxElecIdle;
            logic [2:0]   i_phy_15_pipe_RxStatus;
            logic         i_phy_15_pipe_RxStandbyStatus;
            logic         i_phy_15_pipe_PhyStatus;
            logic         i_phy_15_pipe_PclkChangeOk;
            logic [7:0]   i_phy_15_pipe_P2M_MessageBus;
            logic         i_phy_15_pipe_RxBitSlip_Ack;
        `endif

        //---------------------------------------------------------------------------
        //To Fabric
        //---------------------------------------------------------------------------
        reg                                                             pll_refclk;
    
        //---------------------------------------------------------------------------
        // BBS SPI interface
        //---------------------------------------------------------------------------
        logic                                                           spi_MISO;
        logic                                                           spi_MOSI;
        logic                                                           spi_SCLK;
        logic                                                           spi_SS_n;
    
        `ifdef DFC_HDM_CFG_USE_DDR
            //---------------------------------------------------------------------------
            // DDR Memory Interface declaration
            //---------------------------------------------------------------------------
            reg                                                         refclk;
 
            `ifdef INC_BBS_PKG
                logic [bbs_pkg::NUM_BBS_SLICES-1:0]                     mem_refclk;                                    //Note: EMIF PLL reference clock
                logic [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_CK_WIDTH-1:0]             mem_ck         ;  //Note: DDR4 interface signals
                logic [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_CK_WIDTH-1:0]             mem_ck_n       ;
                logic [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_ADDR_WIDTH-1:0]           mem_a          ;
                logic [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_BA_WIDTH-1:0]                     mem_act_n;                                   
                logic [bbs_pkg::NUM_BBS_SLICES-1:0]             mem_ba         ;
                logic [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_BG_WIDTH-1:0]             mem_bg         ;
                logic [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_CKE_WIDTH-1:0]            mem_cke        ;
                logic [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_CS_WIDTH-1:0]             mem_cs_n       ;
                logic [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_ODT_WIDTH-1:0]            mem_odt        ;
                logic [bbs_pkg::NUM_BBS_SLICES-1:0]                     mem_reset_n;                                 
                logic [bbs_pkg::NUM_BBS_SLICES-1:0]                     mem_par;                                     
                logic [bbs_pkg::NUM_BBS_SLICES-1:0]                     mem_oct_rzqin;                               
                logic [bbs_pkg::NUM_BBS_SLICES-1:0]                     mem_alert_n;                                 
                wire  [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_DQS_WIDTH-1:0]            mem_dqs        ;
                wire  [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_DQS_WIDTH-1:0]            mem_dqs_n      ;
                wire  [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_DQ_WIDTH-1:0]             mem_dq         ;
                `ifdef ENABLE_DDR_DBI_PINS
                    wire  [bbs_pkg::NUM_BBS_SLICES-1:0][bbs_pkg::HDM_MC_DDR_IF_DBI_WIDTH-1:0]        mem_dbi_n      ;
                `endif//ENABLE_DDR_DBI_PINS
            `endif
            `ifdef INC_CXLIP_PKG
                logic [cxlip_top_pkg::MC_CHANNEL-1:0]                   mem_refclk;                                      //Note: EMIF PLL reference clock
                logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_CK_WIDTH-1:0]          mem_ck         ;  //Note: DDR4 interface signals
                logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_CK_WIDTH-1:0]          mem_ck_n       ;
                logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_ADDR_WIDTH-1:0]        mem_a          ;
                logic [cxlip_top_pkg::MC_CHANNEL-1:0]                   mem_act_n;                                   
                logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_BA_WIDTH-1:0]          mem_ba         ;
                logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_BG_WIDTH-1:0]          mem_bg         ;
                logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_CKE_WIDTH-1:0]         mem_cke        ;
                logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_CS_WIDTH-1:0]          mem_cs_n       ;
                logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_ODT_WIDTH-1:0]         mem_odt        ;
                logic [cxlip_top_pkg::MC_CHANNEL-1:0]                   mem_reset_n;                                 
                logic [cxlip_top_pkg::MC_CHANNEL-1:0]                   mem_par;                                     
                logic [cxlip_top_pkg::MC_CHANNEL-1:0]                   mem_oct_rzqin;                               
                logic [cxlip_top_pkg::MC_CHANNEL-1:0]                   mem_alert_n;                                 
                wire  [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_DQS_WIDTH-1:0]         mem_dqs        ;
                wire  [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_DQS_WIDTH-1:0]         mem_dqs_n      ;
                wire  [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_DQ_WIDTH-1:0]          mem_dq         ;
                `ifdef ENABLE_DDR_DBI_PINS
                    wire  [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_DBI_WIDTH-1:0]     mem_dbi_n      ;
                `endif//ENABLE_DDR_DBI_PINS
            `endif
        `endif//DFC_HDM_CFG_USE_DDR 
    
        //---------------------------------------------------------------------------
        // CXL_RTL FAST Initialize
        //---------------------------------------------------------------------------

        //--------------------------------------
        // Declarations
        //--------------------------------------
        logic        reset_mst;
        logic        tb_clk;
        logic        tb_clk_62_5mhz;
        logic        tb_clk_125mhz;
        logic        tb_clk_250mhz;
        logic        tb_clk_800mhz;
        logic        tb_clk_700mhz;
        logic        tb_clk_1G;
        logic        tb_clk_1600Mhz;
        logic        tb_clk_2G;
        logic        pll_pld_clk;
        logic [31:0] wdata;
        `ifdef TB_DTL_MODE
           bit          start_save;  // For DTL
        `endif

        //--------------------------------------
        // CXL IP Clk definition
        //--------------------------------------
        initial begin
            tb_clk = '0;
            tb_clk_62_5mhz = '0;
            tb_clk_250mhz = '0;
            tb_clk_800mhz = '0;
            tb_clk_700mhz = '0;
            tb_clk_1G = '0;
            tb_clk_1600Mhz = '0;
            tb_clk_2G = '0;

            reset_mst = '1;
            #110ns;
            reset_mst = '0;          
        end

        always #250ps tb_clk_2G = ~tb_clk_2G;
        assign wire_clk_2G = tb_clk_2G;
        always #5ns tb_clk = ~tb_clk;
        always #8ns tb_clk_62_5mhz = ~tb_clk_62_5mhz; // Change to cru_if later
        always #4ns tb_clk_125mhz = ~tb_clk_125mhz;
        always #2ns tb_clk_250mhz = ~tb_clk_250mhz;
        always #625ps tb_clk_800mhz = ~tb_clk_800mhz;
        always #649ps tb_clk_700mhz = ~tb_clk_700mhz;
        always #500ps tb_clk_1G = ~tb_clk_1G;
        always #312.5ps tb_clk_1600Mhz = ~tb_clk_1600Mhz;
        assign wire_clk_1G = tb_clk_1G;
        assign pll_pld_clk = tb_clk_1G;

        //--------------------------------------
        // CXL IP FAST Initialization. Comment if, not required. 
        //--------------------------------------
        `ifndef REPO
            `ifdef BASE_IP
                `CXL_IP_DO_INIT(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top)
            `elsif T1IP
                `CXL_IP_DO_INIT(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top)
            `elsif T2IP
                `CXL_IP_DO_INIT(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top)
            `elsif T3IP
                `CXL_IP_DO_INIT(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top)
            `endif
        `else
            `ifdef BASE_IP
                `CXL_IP_DO_INIT(cxl_tb_top.dut.cxl_baseip_top)
            `elsif T1IP
                `CXL_IP_DO_INIT(cxl_tb_top.dut.cxl_type1_cxlip_top)
            `elsif T2IP
                `CXL_IP_DO_INIT(cxl_tb_top.dut.cxl_type2_cxlip_top)
            `elsif T3IP
                `CXL_IP_DO_INIT(cxl_tb_top.dut.cxl_type3_top_inst)
            `endif
        `endif
    
        //--------------------------------------
        // CXL IP Masks for Open BUGs. Comment if, not required. 
        //--------------------------------------
        // HSD List:
        //  1. AER_RES issued by R-TILE:- https://hsdes.intel.com/appstore/article/#/14018659238
        //--------------------------------------
        `ifndef REPO
            `ifdef BASE_IP
                `CXL_TB_DO_MASKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top)
            `elsif T1IP
                `CXL_TB_DO_MASKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top)
            `elsif T2IP
                `CXL_TB_DO_MASKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top)
            `elsif T3IP
                `CXL_TB_DO_MASKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top)
            `endif
        `else
            `ifdef BASE_IP
                `CXL_TB_DO_MASKS(cxl_tb_top.dut.cxl_baseip_top)
            `elsif T1IP
                `CXL_TB_DO_MASKS(cxl_tb_top.dut.cxl_type1_cxlip_top)
            `elsif T2IP
                `CXL_TB_DO_MASKS(cxl_tb_top.dut.cxl_type2_cxlip_top)
            `elsif T3IP
                `CXL_TB_DO_MASKS(cxl_tb_top.dut.cxl_type3_top_inst)
            `endif
        `endif
    
        `ifdef DFC_HDM_CFG_USE_DDR
            //Note: DDR Memory Interface basic connection
            always begin : CLK_GEN
                refclk = 0;
                forever #15ns refclk = ~refclk;
            end : CLK_GEN

            assign mem_oct_rzqin[0]  = '0;
            assign mem_refclk[0] = refclk;
            `ifndef ENABLE_1_BBS_SLICE   // MC Channel=2
            assign mem_oct_rzqin[1]  = '0;
            assign mem_refclk[1] = refclk;
            `endif
            `ifdef ENABLE_4_BBS_SLICE   // MC Channel=4
               assign mem_oct_rzqin[2]  = '0;
               assign mem_oct_rzqin[3]  = '0;
               assign mem_refclk[2] = refclk;
               assign mem_refclk[3] = refclk;
            `endif      
        `endif //DFC_HDM_CFG_USE_DDR 
    
           //---------------------------------------------------------------------------
           //RTILE and Fabric CLK/Reset connection
           //---------------------------------------------------------------------------
           always begin : CLK_GEN0
               refclk0 = 0;
               forever #5ns refclk0 = ~refclk0;
           end : CLK_GEN0

           always begin : CLK_GEN1
               refclk1 = 0;
               forever #5ns refclk1 = ~refclk1;
           end : CLK_GEN1

           always begin : CLK_GEN4
               refclk4 = 0;
               forever #5ns refclk4 = ~refclk4;
           end : CLK_GEN4
    
           //---------------------------------------------------------------------------
           //Reset definition 
           //---------------------------------------------------------------------------
           initial begin : RESET_DEFN
               resetn = 'h0;
               #10us;
               resetn = 'h1;
           end : RESET_DEFN
    
           //---------------------------------------------------------------------------
           //Connect CXL Signals
           //---------------------------------------------------------------------------
           assign cxl_rx_n = tx_datan; 
           assign cxl_rx_p = tx_data; 
           assign rx_datan = cxl_tx_n;
           assign rx_data  = cxl_tx_p;

        //---------------------------------------------------------------------------
        //Instantiate CXL_RTL
        //---------------------------------------------------------------------------
        `ifdef QPDS
            `ifdef CXLTYP3DDR
               //v0 cxl_qpds_top dut (
                cxl_memexp_main_top dut (
            `endif
        `elsif QPDS_ED
            `ifdef CXLTYP3DDR
            cxltyp3_memexp_ddr4_top dut (
            `endif
        `elsif QPDS_B0A0_ED
            `ifdef CXLTYP3DDR
                cxl_memexp_main_top dut (
            `endif
        `elsif QPDS_B0A0
            `ifdef CXLTYP3DDR
                cxl_memexp_main_top dut (
            `endif
        `elsif QHIP_MIRROR_CFG
            cxlbasehip_top dut (
        `elsif T3IP
           `ifdef REPO
               cxl_memexp_top dut (
           `elsif QPDS_ED_B0
               cxltyp3_memexp_ddr4_top dut (
           `endif
        `elsif T2IP
           `ifdef REPO
               cxl_t2ip_top dut (
           `elsif QPDS_ED_B0
               cxltyp2_ed dut (
           `endif
        `elsif T1IP
           `ifdef REPO
               cxltyp1_ed dut (
           `elsif QPDS_ED_B0
               cxltyp1_ed dut (
           `endif
        `elsif BASE_IP
            cxlbasehip_top dut (
        `else
            cxl_memexp_top dut (
        `endif
            .refclk0,
            .refclk1,
            .refclk4,
            .resetn,

            //Note: CXL_SIM reduction Pipe Mode 
            `ifdef CXL_PIPE_MODE
                .phy_sys_ial_0__pipe_Reset_l,
                .phy_sys_ial_1__pipe_Reset_l,
                .phy_sys_ial_2__pipe_Reset_l,
                .phy_sys_ial_3__pipe_Reset_l,
                .phy_sys_ial_4__pipe_Reset_l,
                .phy_sys_ial_5__pipe_Reset_l,
                .phy_sys_ial_6__pipe_Reset_l,
                .phy_sys_ial_7__pipe_Reset_l,
                .phy_sys_ial_8__pipe_Reset_l,
                .phy_sys_ial_9__pipe_Reset_l,
                .phy_sys_ial_10__pipe_Reset_l,
                .phy_sys_ial_11__pipe_Reset_l,
                .phy_sys_ial_12__pipe_Reset_l,
                .phy_sys_ial_13__pipe_Reset_l,
                .phy_sys_ial_14__pipe_Reset_l,
                .phy_sys_ial_15__pipe_Reset_l,
                .o_phy_0_pipe_TxDataValid,
                .o_phy_0_pipe_TxData,
                .o_phy_0_pipe_TxDetRxLpbk,
                .o_phy_0_pipe_TxElecIdle,
                .o_phy_0_pipe_PowerDown,
                .o_phy_0_pipe_Rate,
                .o_phy_0_pipe_PclkChangeAck,
                .o_phy_0_pipe_PCLKRate,
                .o_phy_0_pipe_Width,
                .o_phy_0_pipe_PCLK,
                .o_phy_0_pipe_rxelecidle_disable,
                .o_phy_0_pipe_txcmnmode_disable,
                .o_phy_0_pipe_srisenable,
                .o_phy_0_pipe_RxStandby,
                .o_phy_0_pipe_RxTermination,
                .o_phy_0_pipe_RxWidth,
                .o_phy_0_pipe_M2P_MessageBus,
                .o_phy_0_pipe_rxbitslip_req,
                .o_phy_0_pipe_rxbitslip_va,
                .i_phy_0_pipe_RxClk,
                .i_phy_0_pipe_RxValid,
                .i_phy_0_pipe_RxData,
                .i_phy_0_pipe_RxElecIdle,
                .i_phy_0_pipe_RxStatus,
                .i_phy_0_pipe_RxStandbyStatus,
                .i_phy_0_pipe_PhyStatus,
                .i_phy_0_pipe_PclkChangeOk,
                .i_phy_0_pipe_P2M_MessageBus,
                .i_phy_0_pipe_RxBitSlip_Ack,
                .o_phy_1_pipe_TxDataValid,
                .o_phy_1_pipe_TxData,
                .o_phy_1_pipe_TxDetRxLpbk,
                .o_phy_1_pipe_TxElecIdle,
                .o_phy_1_pipe_PowerDown,
                .o_phy_1_pipe_Rate,
                .o_phy_1_pipe_PclkChangeAck,
                .o_phy_1_pipe_PCLKRate,
                .o_phy_1_pipe_Width,
                .o_phy_1_pipe_PCLK,
                .o_phy_1_pipe_rxelecidle_disable,
                .o_phy_1_pipe_txcmnmode_disable,
                .o_phy_1_pipe_srisenable,
                .o_phy_1_pipe_RxStandby,
                .o_phy_1_pipe_RxTermination,
                .o_phy_1_pipe_RxWidth,
                .o_phy_1_pipe_M2P_MessageBus,
                .o_phy_1_pipe_rxbitslip_req,
                .o_phy_1_pipe_rxbitslip_va,
                .i_phy_1_pipe_RxClk,
                .i_phy_1_pipe_RxValid,
                .i_phy_1_pipe_RxData,
                .i_phy_1_pipe_RxElecIdle,
                .i_phy_1_pipe_RxStatus,
                .i_phy_1_pipe_RxStandbyStatus,
                .i_phy_1_pipe_PhyStatus,
                .i_phy_1_pipe_PclkChangeOk,
                .i_phy_1_pipe_P2M_MessageBus,
                .i_phy_1_pipe_RxBitSlip_Ack,
                .o_phy_2_pipe_TxDataValid,
                .o_phy_2_pipe_TxData,
                .o_phy_2_pipe_TxDetRxLpbk,
                .o_phy_2_pipe_TxElecIdle,
                .o_phy_2_pipe_PowerDown,
                .o_phy_2_pipe_Rate,
                .o_phy_2_pipe_PclkChangeAck,
                .o_phy_2_pipe_PCLKRate,
                .o_phy_2_pipe_Width,
                .o_phy_2_pipe_PCLK,
                .o_phy_2_pipe_rxelecidle_disable,
                .o_phy_2_pipe_txcmnmode_disable,
                .o_phy_2_pipe_srisenable,
                .o_phy_2_pipe_RxStandby,
                .o_phy_2_pipe_RxTermination,
                .o_phy_2_pipe_RxWidth,
                .o_phy_2_pipe_M2P_MessageBus,
                .o_phy_2_pipe_rxbitslip_req,
                .o_phy_2_pipe_rxbitslip_va,
                .i_phy_2_pipe_RxClk,
                .i_phy_2_pipe_RxValid,
                .i_phy_2_pipe_RxData,
                .i_phy_2_pipe_RxElecIdle,
                .i_phy_2_pipe_RxStatus,
                .i_phy_2_pipe_RxStandbyStatus,
                .i_phy_2_pipe_PhyStatus,
                .i_phy_2_pipe_PclkChangeOk,
                .i_phy_2_pipe_P2M_MessageBus,
                .i_phy_2_pipe_RxBitSlip_Ack,
                .o_phy_3_pipe_TxDataValid,
                .o_phy_3_pipe_TxData,
                .o_phy_3_pipe_TxDetRxLpbk,
                .o_phy_3_pipe_TxElecIdle,
                .o_phy_3_pipe_PowerDown,
                .o_phy_3_pipe_Rate,
                .o_phy_3_pipe_PclkChangeAck,
                .o_phy_3_pipe_PCLKRate,
                .o_phy_3_pipe_Width,
                .o_phy_3_pipe_PCLK,
                .o_phy_3_pipe_rxelecidle_disable,
                .o_phy_3_pipe_txcmnmode_disable,
                .o_phy_3_pipe_srisenable,
                .o_phy_3_pipe_RxStandby,
                .o_phy_3_pipe_RxTermination,
                .o_phy_3_pipe_RxWidth,
                .o_phy_3_pipe_M2P_MessageBus,
                .o_phy_3_pipe_rxbitslip_req,
                .o_phy_3_pipe_rxbitslip_va,
                .i_phy_3_pipe_RxClk,
                .i_phy_3_pipe_RxValid,
                .i_phy_3_pipe_RxData,
                .i_phy_3_pipe_RxElecIdle,
                .i_phy_3_pipe_RxStatus,
                .i_phy_3_pipe_RxStandbyStatus,
                .i_phy_3_pipe_PhyStatus,
                .i_phy_3_pipe_PclkChangeOk,
                .i_phy_3_pipe_P2M_MessageBus,
                .i_phy_3_pipe_RxBitSlip_Ack,
                .o_phy_4_pipe_TxDataValid,
                .o_phy_4_pipe_TxData,
                .o_phy_4_pipe_TxDetRxLpbk,
                .o_phy_4_pipe_TxElecIdle,
                .o_phy_4_pipe_PowerDown,
                .o_phy_4_pipe_Rate,
                .o_phy_4_pipe_PclkChangeAck,
                .o_phy_4_pipe_PCLKRate,
                .o_phy_4_pipe_Width,
                .o_phy_4_pipe_PCLK,
                .o_phy_4_pipe_rxelecidle_disable,
                .o_phy_4_pipe_txcmnmode_disable,
                .o_phy_4_pipe_srisenable,
                .o_phy_4_pipe_RxStandby,
                .o_phy_4_pipe_RxTermination,
                .o_phy_4_pipe_RxWidth,
                .o_phy_4_pipe_M2P_MessageBus,
                .o_phy_4_pipe_rxbitslip_req,
                .o_phy_4_pipe_rxbitslip_va,
                .i_phy_4_pipe_RxClk,
                .i_phy_4_pipe_RxValid,
                .i_phy_4_pipe_RxData,
                .i_phy_4_pipe_RxElecIdle,
                .i_phy_4_pipe_RxStatus,
                .i_phy_4_pipe_RxStandbyStatus,
                .i_phy_4_pipe_PhyStatus,
                .i_phy_4_pipe_PclkChangeOk,
                .i_phy_4_pipe_P2M_MessageBus,
                .i_phy_4_pipe_RxBitSlip_Ack,
                .o_phy_5_pipe_TxDataValid,
                .o_phy_5_pipe_TxData,
                .o_phy_5_pipe_TxDetRxLpbk,
                .o_phy_5_pipe_TxElecIdle,
                .o_phy_5_pipe_PowerDown,
                .o_phy_5_pipe_Rate,
                .o_phy_5_pipe_PclkChangeAck,
                .o_phy_5_pipe_PCLKRate,
                .o_phy_5_pipe_Width,
                .o_phy_5_pipe_PCLK,
                .o_phy_5_pipe_rxelecidle_disable,
                .o_phy_5_pipe_txcmnmode_disable,
                .o_phy_5_pipe_srisenable,
                .o_phy_5_pipe_RxStandby,
                .o_phy_5_pipe_RxTermination,
                .o_phy_5_pipe_RxWidth,
                .o_phy_5_pipe_M2P_MessageBus,
                .o_phy_5_pipe_rxbitslip_req,
                .o_phy_5_pipe_rxbitslip_va,
                .i_phy_5_pipe_RxClk,
                .i_phy_5_pipe_RxValid,
                .i_phy_5_pipe_RxData,
                .i_phy_5_pipe_RxElecIdle,
                .i_phy_5_pipe_RxStatus,
                .i_phy_5_pipe_RxStandbyStatus,
                .i_phy_5_pipe_PhyStatus,
                .i_phy_5_pipe_PclkChangeOk,
                .i_phy_5_pipe_P2M_MessageBus,
                .i_phy_5_pipe_RxBitSlip_Ack,
                .o_phy_6_pipe_TxDataValid,
                .o_phy_6_pipe_TxData,
                .o_phy_6_pipe_TxDetRxLpbk,
                .o_phy_6_pipe_TxElecIdle,
                .o_phy_6_pipe_PowerDown,
                .o_phy_6_pipe_Rate,
                .o_phy_6_pipe_PclkChangeAck,
                .o_phy_6_pipe_PCLKRate,
                .o_phy_6_pipe_Width,
                .o_phy_6_pipe_PCLK,
                .o_phy_6_pipe_rxelecidle_disable,
                .o_phy_6_pipe_txcmnmode_disable,
                .o_phy_6_pipe_srisenable,
                .o_phy_6_pipe_RxStandby,
                .o_phy_6_pipe_RxTermination,
                .o_phy_6_pipe_RxWidth,
                .o_phy_6_pipe_M2P_MessageBus,
                .o_phy_6_pipe_rxbitslip_req,
                .o_phy_6_pipe_rxbitslip_va,
                .i_phy_6_pipe_RxClk,
                .i_phy_6_pipe_RxValid,
                .i_phy_6_pipe_RxData,
                .i_phy_6_pipe_RxElecIdle,
                .i_phy_6_pipe_RxStatus,
                .i_phy_6_pipe_RxStandbyStatus,
                .i_phy_6_pipe_PhyStatus,
                .i_phy_6_pipe_PclkChangeOk,
                .i_phy_6_pipe_P2M_MessageBus,
                .i_phy_6_pipe_RxBitSlip_Ack,
                .o_phy_7_pipe_TxDataValid,
                .o_phy_7_pipe_TxData,
                .o_phy_7_pipe_TxDetRxLpbk,
                .o_phy_7_pipe_TxElecIdle,
                .o_phy_7_pipe_PowerDown,
                .o_phy_7_pipe_Rate,
                .o_phy_7_pipe_PclkChangeAck,
                .o_phy_7_pipe_PCLKRate,
                .o_phy_7_pipe_Width,
                .o_phy_7_pipe_PCLK,
                .o_phy_7_pipe_rxelecidle_disable,
                .o_phy_7_pipe_txcmnmode_disable,
                .o_phy_7_pipe_srisenable,
                .o_phy_7_pipe_RxStandby,
                .o_phy_7_pipe_RxTermination,
                .o_phy_7_pipe_RxWidth,
                .o_phy_7_pipe_M2P_MessageBus,
                .o_phy_7_pipe_rxbitslip_req,
                .o_phy_7_pipe_rxbitslip_va,
                .i_phy_7_pipe_RxClk,
                .i_phy_7_pipe_RxValid,
                .i_phy_7_pipe_RxData,
                .i_phy_7_pipe_RxElecIdle,
                .i_phy_7_pipe_RxStatus,
                .i_phy_7_pipe_RxStandbyStatus,
                .i_phy_7_pipe_PhyStatus,
                .i_phy_7_pipe_PclkChangeOk,
                .i_phy_7_pipe_P2M_MessageBus,
                .i_phy_7_pipe_RxBitSlip_Ack,
                .o_phy_8_pipe_TxDataValid,
                .o_phy_8_pipe_TxData,
                .o_phy_8_pipe_TxDetRxLpbk,
                .o_phy_8_pipe_TxElecIdle,
                .o_phy_8_pipe_PowerDown,
                .o_phy_8_pipe_Rate,
                .o_phy_8_pipe_PclkChangeAck,
                .o_phy_8_pipe_PCLKRate,
                .o_phy_8_pipe_Width,
                .o_phy_8_pipe_PCLK,
                .o_phy_8_pipe_rxelecidle_disable,
                .o_phy_8_pipe_txcmnmode_disable,
                .o_phy_8_pipe_srisenable,
                .o_phy_8_pipe_RxStandby,
                .o_phy_8_pipe_RxTermination,
                .o_phy_8_pipe_RxWidth,
                .o_phy_8_pipe_M2P_MessageBus,
                .o_phy_8_pipe_rxbitslip_req,
                .o_phy_8_pipe_rxbitslip_va,
                .i_phy_8_pipe_RxClk,
                .i_phy_8_pipe_RxValid,
                .i_phy_8_pipe_RxData,
                .i_phy_8_pipe_RxElecIdle,
                .i_phy_8_pipe_RxStatus,
                .i_phy_8_pipe_RxStandbyStatus,
                .i_phy_8_pipe_PhyStatus,
                .i_phy_8_pipe_PclkChangeOk,
                .i_phy_8_pipe_P2M_MessageBus,
                .i_phy_8_pipe_RxBitSlip_Ack,
                .o_phy_9_pipe_TxDataValid,
                .o_phy_9_pipe_TxData,
                .o_phy_9_pipe_TxDetRxLpbk,
                .o_phy_9_pipe_TxElecIdle,
                .o_phy_9_pipe_PowerDown,
                .o_phy_9_pipe_Rate,
                .o_phy_9_pipe_PclkChangeAck,
                .o_phy_9_pipe_PCLKRate,
                .o_phy_9_pipe_Width,
                .o_phy_9_pipe_PCLK,
                .o_phy_9_pipe_rxelecidle_disable,
                .o_phy_9_pipe_txcmnmode_disable,
                .o_phy_9_pipe_srisenable,
                .o_phy_9_pipe_RxStandby,
                .o_phy_9_pipe_RxTermination,
                .o_phy_9_pipe_RxWidth,
                .o_phy_9_pipe_M2P_MessageBus,
                .o_phy_9_pipe_rxbitslip_req,
                .o_phy_9_pipe_rxbitslip_va,
                .i_phy_9_pipe_RxClk,
                .i_phy_9_pipe_RxValid,
                .i_phy_9_pipe_RxData,
                .i_phy_9_pipe_RxElecIdle,
                .i_phy_9_pipe_RxStatus,
                .i_phy_9_pipe_RxStandbyStatus,
                .i_phy_9_pipe_PhyStatus,
                .i_phy_9_pipe_PclkChangeOk,
                .i_phy_9_pipe_P2M_MessageBus,
                .i_phy_9_pipe_RxBitSlip_Ack,
                .o_phy_10_pipe_TxDataValid,
                .o_phy_10_pipe_TxData,
                .o_phy_10_pipe_TxDetRxLpbk,
                .o_phy_10_pipe_TxElecIdle,
                .o_phy_10_pipe_PowerDown,
                .o_phy_10_pipe_Rate,
                .o_phy_10_pipe_PclkChangeAck,
                .o_phy_10_pipe_PCLKRate,
                .o_phy_10_pipe_Width,
                .o_phy_10_pipe_PCLK,
                .o_phy_10_pipe_rxelecidle_disable,
                .o_phy_10_pipe_txcmnmode_disable,
                .o_phy_10_pipe_srisenable,
                .o_phy_10_pipe_RxStandby,
                .o_phy_10_pipe_RxTermination,
                .o_phy_10_pipe_RxWidth,
                .o_phy_10_pipe_M2P_MessageBus,
                .o_phy_10_pipe_rxbitslip_req,
                .o_phy_10_pipe_rxbitslip_va,
                .i_phy_10_pipe_RxClk,
                .i_phy_10_pipe_RxValid,
                .i_phy_10_pipe_RxData,
                .i_phy_10_pipe_RxElecIdle,
                .i_phy_10_pipe_RxStatus,
                .i_phy_10_pipe_RxStandbyStatus,
                .i_phy_10_pipe_PhyStatus,
                .i_phy_10_pipe_PclkChangeOk,
                .i_phy_10_pipe_P2M_MessageBus,
                .i_phy_10_pipe_RxBitSlip_Ack,
                .o_phy_11_pipe_TxDataValid,
                .o_phy_11_pipe_TxData,
                .o_phy_11_pipe_TxDetRxLpbk,
                .o_phy_11_pipe_TxElecIdle,
                .o_phy_11_pipe_PowerDown,
                .o_phy_11_pipe_Rate,
                .o_phy_11_pipe_PclkChangeAck,
                .o_phy_11_pipe_PCLKRate,
                .o_phy_11_pipe_Width,
                .o_phy_11_pipe_PCLK,
                .o_phy_11_pipe_rxelecidle_disable,
                .o_phy_11_pipe_txcmnmode_disable,
                .o_phy_11_pipe_srisenable,
                .o_phy_11_pipe_RxStandby,
                .o_phy_11_pipe_RxTermination,
                .o_phy_11_pipe_RxWidth,
                .o_phy_11_pipe_M2P_MessageBus,
                .o_phy_11_pipe_rxbitslip_req,
                .o_phy_11_pipe_rxbitslip_va,
                .i_phy_11_pipe_RxClk,
                .i_phy_11_pipe_RxValid,
                .i_phy_11_pipe_RxData,
                .i_phy_11_pipe_RxElecIdle,
                .i_phy_11_pipe_RxStatus,
                .i_phy_11_pipe_RxStandbyStatus,
                .i_phy_11_pipe_PhyStatus,
                .i_phy_11_pipe_PclkChangeOk,
                .i_phy_11_pipe_P2M_MessageBus,
                .i_phy_11_pipe_RxBitSlip_Ack,
                .o_phy_12_pipe_TxDataValid,
                .o_phy_12_pipe_TxData,
                .o_phy_12_pipe_TxDetRxLpbk,
                .o_phy_12_pipe_TxElecIdle,
                .o_phy_12_pipe_PowerDown,
                .o_phy_12_pipe_Rate,
                .o_phy_12_pipe_PclkChangeAck,
                .o_phy_12_pipe_PCLKRate,
                .o_phy_12_pipe_Width,
                .o_phy_12_pipe_PCLK,
                .o_phy_12_pipe_rxelecidle_disable,
                .o_phy_12_pipe_txcmnmode_disable,
                .o_phy_12_pipe_srisenable,
                .o_phy_12_pipe_RxStandby,
                .o_phy_12_pipe_RxTermination,
                .o_phy_12_pipe_RxWidth,
                .o_phy_12_pipe_M2P_MessageBus,
                .o_phy_12_pipe_rxbitslip_req,
                .o_phy_12_pipe_rxbitslip_va,
                .i_phy_12_pipe_RxClk,
                .i_phy_12_pipe_RxValid,
                .i_phy_12_pipe_RxData,
                .i_phy_12_pipe_RxElecIdle,
                .i_phy_12_pipe_RxStatus,
                .i_phy_12_pipe_RxStandbyStatus,
                .i_phy_12_pipe_PhyStatus,
                .i_phy_12_pipe_PclkChangeOk,
                .i_phy_12_pipe_P2M_MessageBus,
                .i_phy_12_pipe_RxBitSlip_Ack,
                .o_phy_13_pipe_TxDataValid,
                .o_phy_13_pipe_TxData,
                .o_phy_13_pipe_TxDetRxLpbk,
                .o_phy_13_pipe_TxElecIdle,
                .o_phy_13_pipe_PowerDown,
                .o_phy_13_pipe_Rate,
                .o_phy_13_pipe_PclkChangeAck,
                .o_phy_13_pipe_PCLKRate,
                .o_phy_13_pipe_Width,
                .o_phy_13_pipe_PCLK,
                .o_phy_13_pipe_rxelecidle_disable,
                .o_phy_13_pipe_txcmnmode_disable,
                .o_phy_13_pipe_srisenable,
                .o_phy_13_pipe_RxStandby,
                .o_phy_13_pipe_RxTermination,
                .o_phy_13_pipe_RxWidth,
                .o_phy_13_pipe_M2P_MessageBus,
                .o_phy_13_pipe_rxbitslip_req,
                .o_phy_13_pipe_rxbitslip_va,
                .i_phy_13_pipe_RxClk,
                .i_phy_13_pipe_RxValid,
                .i_phy_13_pipe_RxData,
                .i_phy_13_pipe_RxElecIdle,
                .i_phy_13_pipe_RxStatus,
                .i_phy_13_pipe_RxStandbyStatus,
                .i_phy_13_pipe_PhyStatus,
                .i_phy_13_pipe_PclkChangeOk,
                .i_phy_13_pipe_P2M_MessageBus,
                .i_phy_13_pipe_RxBitSlip_Ack,
                .o_phy_14_pipe_TxDataValid,
                .o_phy_14_pipe_TxData,
                .o_phy_14_pipe_TxDetRxLpbk,
                .o_phy_14_pipe_TxElecIdle,
                .o_phy_14_pipe_PowerDown,
                .o_phy_14_pipe_Rate,
                .o_phy_14_pipe_PclkChangeAck,
                .o_phy_14_pipe_PCLKRate,
                .o_phy_14_pipe_Width,
                .o_phy_14_pipe_PCLK,
                .o_phy_14_pipe_rxelecidle_disable,
                .o_phy_14_pipe_txcmnmode_disable,
                .o_phy_14_pipe_srisenable,
                .o_phy_14_pipe_RxStandby,
                .o_phy_14_pipe_RxTermination,
                .o_phy_14_pipe_RxWidth,
                .o_phy_14_pipe_M2P_MessageBus,
                .o_phy_14_pipe_rxbitslip_req,
                .o_phy_14_pipe_rxbitslip_va,
                .i_phy_14_pipe_RxClk,
                .i_phy_14_pipe_RxValid,
                .i_phy_14_pipe_RxData,
                .i_phy_14_pipe_RxElecIdle,
                .i_phy_14_pipe_RxStatus,
                .i_phy_14_pipe_RxStandbyStatus,
                .i_phy_14_pipe_PhyStatus,
                .i_phy_14_pipe_PclkChangeOk,
                .i_phy_14_pipe_P2M_MessageBus,
                .i_phy_14_pipe_RxBitSlip_Ack,
                .o_phy_15_pipe_TxDataValid,
                .o_phy_15_pipe_TxData,
                .o_phy_15_pipe_TxDetRxLpbk,
                .o_phy_15_pipe_TxElecIdle,
                .o_phy_15_pipe_PowerDown,
                .o_phy_15_pipe_Rate,
                .o_phy_15_pipe_PclkChangeAck,
                .o_phy_15_pipe_PCLKRate,
                .o_phy_15_pipe_Width,
                .o_phy_15_pipe_PCLK,
                .o_phy_15_pipe_rxelecidle_disable,
                .o_phy_15_pipe_txcmnmode_disable,
                .o_phy_15_pipe_srisenable,
                .o_phy_15_pipe_RxStandby,
                .o_phy_15_pipe_RxTermination,
                .o_phy_15_pipe_RxWidth,
                .o_phy_15_pipe_M2P_MessageBus,
                .o_phy_15_pipe_rxbitslip_req,
                .o_phy_15_pipe_rxbitslip_va,
                .i_phy_15_pipe_RxClk,
                .i_phy_15_pipe_RxValid,
                .i_phy_15_pipe_RxData,
                .i_phy_15_pipe_RxElecIdle,
                .i_phy_15_pipe_RxStatus,
                .i_phy_15_pipe_RxStandbyStatus,
                .i_phy_15_pipe_PhyStatus,
                .i_phy_15_pipe_PclkChangeOk,
                .i_phy_15_pipe_P2M_MessageBus,
                .i_phy_15_pipe_RxBitSlip_Ack,
            `endif

            `ifdef DFC_HDM_CFG_USE_DDR
                //Note: DDR Memory Interface
                .mem_refclk,     //Note: EMIF PLL reference clock
                .mem_ck,         //Note: DDR4 interface signals
                .mem_ck_n,
                .mem_a,
                .mem_act_n,
                .mem_ba,
                .mem_bg,
                .mem_cke,
                .mem_cs_n,
                .mem_odt,
                .mem_reset_n,
                .mem_par,
                .mem_oct_rzqin,
                .mem_alert_n,
                .mem_dqs,
                .mem_dqs_n,
                `ifdef ENABLE_DDR_DBI_PINS //Note: Micron DIMM
                    .mem_dbi_n,
                `endif//ENABLE_DDR_DBI_PINS
                .mem_dq,
            `endif//DFC_HDM_CFG_USE_DDR
            .cxl_rx_n,
            .cxl_rx_p,
            .cxl_tx_n,
            .cxl_tx_p
        );
    
        //---------------------------------------------------------------------------
        //Instantiate Mem models
        //---------------------------------------------------------------------------
        `ifdef DFC_HDM_CFG_USE_DDR
            `ifdef DDR_SIM_CFG_USE_MEM_MDL
                //---------------------------------------------------------------------------
                // DDR Memory Sim Model
                //---------------------------------------------------------------------------
                ed_sim_mem ed_sim_mem_0 (
                    .mem_ck        (mem_ck[0]),
                    .mem_ck_n      (mem_ck_n[0]),
                    .mem_a         (mem_a[0]),
                    .mem_act_n     (mem_act_n[0]),
                    .mem_ba        (mem_ba[0]),
                    .mem_bg        (mem_bg[0]),
                    .mem_cke       (mem_cke[0]),
                    .mem_cs_n      (mem_cs_n[0]),
                    .mem_odt       (mem_odt[0]),
                    .mem_reset_n   (mem_reset_n[0]),
                    .mem_par       (mem_par[0]),
                    .mem_alert_n   (mem_alert_n[0]),
                    .mem_dqs       (mem_dqs[0]),
                    .mem_dqs_n     (mem_dqs_n[0]),
                    .mem_dq        (mem_dq[0])
                    `ifdef ENABLE_DDR_DBI_PINS
                        ,.mem_dbi_n     (mem_dbi_n[0])
                    `endif//ENABLE_DDR_DBI_PINS
                );
                
                `ifndef ENABLE_1_BBS_SLICE   // MC Channel=1
                    //---------------------------------------------------------------------------
                    // DDR Memory Sim Model
                    //---------------------------------------------------------------------------
                    ed_sim_mem ed_sim_mem_1 (
                        .mem_ck        (mem_ck[1]),
                        .mem_ck_n      (mem_ck_n[1]),
                        .mem_a         (mem_a[1]),
                        .mem_act_n     (mem_act_n[1]),
                        .mem_ba        (mem_ba[1]),
                        .mem_bg        (mem_bg[1]),
                        .mem_cke       (mem_cke[1]),
                        .mem_cs_n      (mem_cs_n[1]),
                        .mem_odt       (mem_odt[1]),
                        .mem_reset_n   (mem_reset_n[1]),
                        .mem_par       (mem_par[1]),
                        .mem_alert_n   (mem_alert_n[1]),
                        .mem_dqs       (mem_dqs[1]),
                        .mem_dqs_n     (mem_dqs_n[1]),
                        .mem_dq        (mem_dq[1])
                        `ifdef ENABLE_DDR_DBI_PINS
                            ,.mem_dbi_n     (mem_dbi_n[1])
                        `endif//ENABLE_DDR_DBI_PINS
                    );
                `endif// ENABLE_1_BBS_SLICE   // MC Channel=1

                `ifdef ENABLE_4_BBS_SLICE   // MC Channel=4
                    ed_sim_mem ed_sim_mem_2 (
                        .mem_ck        (mem_ck[2]),
                        .mem_ck_n      (mem_ck_n[2]),
                        .mem_a         (mem_a[2]),
                        .mem_act_n     (mem_act_n[2]),
                        .mem_ba        (mem_ba[2]),
                        .mem_bg        (mem_bg[2]),
                        .mem_cke       (mem_cke[2]),
                        .mem_cs_n      (mem_cs_n[2]),
                        .mem_odt       (mem_odt[2]),
                        .mem_reset_n   (mem_reset_n[2]),
                        .mem_par       (mem_par[2]),
                        .mem_alert_n   (mem_alert_n[2]),
                        .mem_dqs       (mem_dqs[2]),
                        .mem_dqs_n     (mem_dqs_n[2]),
                        .mem_dq        (mem_dq[2])
                        `ifdef ENABLE_DDR_DBI_PINS
                            ,.mem_dbi_n     (mem_dbi_n[2])
                        `endif//ENABLE_DDR_DBI_PINS
                    );
                    
                    ed_sim_mem ed_sim_mem_3 (
                        .mem_ck        (mem_ck[3]),
                        .mem_ck_n      (mem_ck_n[3]),
                        .mem_a         (mem_a[3]),
                        .mem_act_n     (mem_act_n[3]),
                        .mem_ba        (mem_ba[3]),
                        .mem_bg        (mem_bg[3]),
                        .mem_cke       (mem_cke[3]),
                        .mem_cs_n      (mem_cs_n[3]),
                        .mem_odt       (mem_odt[3]),
                        .mem_reset_n   (mem_reset_n[3]),
                        .mem_par       (mem_par[3]),
                        .mem_alert_n   (mem_alert_n[3]),
                        .mem_dqs       (mem_dqs[3]),
                        .mem_dqs_n     (mem_dqs_n[3]),
                        .mem_dq        (mem_dq[3])
                        `ifdef ENABLE_DDR_DBI_PINS
                            ,.mem_dbi_n     (mem_dbi_n[3])
                        `endif//ENABLE_DDR_DBI_PINS
                    );
                `endif // mc -4
            `endif//DDR_SIM_CFG_USE_MEM_MDL
        `endif//DFC_HDM_CFG_USE_DDR
    
        `ifdef CXL_PIPE_MODE
            //---------------------------------------------------------------------------
            //Instantiate Avery MPIPE BOX
            //---------------------------------------------------------------------------
            apci_mpipe_box #(
                .COMMON_CLOCK                   (`APCI_COMMON_CLOCK),
                .COMMON_MODE_V                  (`APCI_COMMON_MODE_V),
                .PCLK_AS_PHY_INPUT              (`APCI_PCLK_AS_PHY_INPUT),
                .DYNAMIC_PRESET_COEF_UPDATES    (`APCI_DYNAMIC_PRESET_COEF_UPDATES),
                .MAX_DATA_WIDTH                 (`APCI_MAX_DATA_WIDTH),
                .LOW_PIN_COUNT                  (1),
        
                .A_SERDES_MODE                  (`APCI_SERDES_MODE),
                .A_NUM_LANES                    (`APCI_NUM_LANES),
                .A_GEN1_DATA_WIDTH              (GEN1_W  ),
                .A_GEN2_DATA_WIDTH              (GEN2_W  ),
                .A_GEN3_DATA_WIDTH              (GEN3_W  ),
                .A_GEN4_DATA_WIDTH              (GEN4_W  ),
                .A_GEN5_DATA_WIDTH              (GEN5_W  ),
                .A_GEN6_DATA_WIDTH              (GEN6_W  ),
                .A_CCIX_20G_DATA_WIDTH          (CCIX_20G_W  ),
                .A_CCIX_25G_DATA_WIDTH          (CCIX_25G_W  ),
                .A_GEN1_CLOCK_RATE              (GEN1_CLK),
                .A_GEN2_CLOCK_RATE              (GEN2_CLK),  //  1: 125, 2: 250 Mhz, 3: 500Mhs
                .A_GEN3_CLOCK_RATE              (GEN3_CLK),
                .A_GEN4_CLOCK_RATE              (GEN4_CLK),
                .A_GEN5_CLOCK_RATE              (GEN5_CLK),
                .A_GEN6_CLOCK_RATE              (GEN6_CLK),
                .A_CCIX_20G_CLOCK_RATE          (CCIX_20G_CLK),
                .A_CCIX_25G_CLOCK_RATE          (CCIX_25G_CLK),
        
                .B_SERDES_MODE                  (`APCI_SERDES_MODE),
                .B_NUM_LANES                    (`APCI_NUM_LANES),
                .B_GEN1_DATA_WIDTH              (GEN1_W  ),
                .B_GEN2_DATA_WIDTH              (GEN2_W  ),
                .B_GEN3_DATA_WIDTH              (GEN3_W  ),
                .B_GEN4_DATA_WIDTH              (GEN4_W  ),
                .B_GEN5_DATA_WIDTH              (GEN5_W  ),
                .B_GEN6_DATA_WIDTH              (GEN6_W  ),
                .B_CCIX_20G_DATA_WIDTH          (CCIX_20G_W  ),
                .B_CCIX_25G_DATA_WIDTH          (CCIX_25G_W  ),
                .B_GEN1_CLOCK_RATE              (GEN1_CLK),
                .B_GEN2_CLOCK_RATE              (GEN2_CLK),
                .B_GEN3_CLOCK_RATE              (GEN3_CLK),
                .B_GEN4_CLOCK_RATE              (GEN4_CLK),
                .B_GEN5_CLOCK_RATE              (GEN5_CLK),
                .B_GEN6_CLOCK_RATE              (GEN6_CLK),
                .B_CCIX_20G_CLOCK_RATE          (CCIX_20G_CLK),
                .B_CCIX_25G_CLOCK_RATE          (CCIX_25G_CLK)
            ) mpipe_box (
                rc_pif,
                ep_pif
            );
        `else
            //---------------------------------------------------------------------------
            //Instantiate Avery RC
            //---------------------------------------------------------------------------
            apci_phy #(
                .COMMON_CLOCK                   (`APCI_COMMON_CLOCK),
                .NUM_LANES                      (`APCI_NUM_LANES),
                .PCLK_AS_PHY_INPUT              (`APCI_PCLK_AS_PHY_INPUT),
                .SERDES_MODE                    (`APCI_SERDES_MODE),
                .DYNAMIC_PRESET_COEF_UPDATES    (`APCI_DYNAMIC_PRESET_COEF_UPDATES),
                .GENERATE_REF_CLK               (0),  //Note: 0 to disable reference clock at rc_pif[0].Clk
                .GEN1_DATA_WIDTH                (GEN1_W  ), 
                .GEN2_DATA_WIDTH                (GEN2_W  ),
                .GEN3_DATA_WIDTH                (GEN3_W  ),
                .GEN4_DATA_WIDTH                (GEN4_W  ), 
                .GEN5_DATA_WIDTH                (GEN5_W  ),
                .GEN6_DATA_WIDTH                (GEN6_W  ),
                .CCIX_20G_DATA_WIDTH            (CCIX_20G_W  ), 
                .CCIX_25G_DATA_WIDTH            (CCIX_25G_W  ), 
                .GEN1_CLOCK_RATE                (GEN1_CLK),
                .GEN2_CLOCK_RATE                (GEN2_CLK),  //Note: 1: 125, 2: 250 Mhz, 3: 500Mhs
                .GEN3_CLOCK_RATE                (GEN3_CLK),
                .GEN4_CLOCK_RATE                (GEN4_CLK),
                .GEN5_CLOCK_RATE                (GEN5_CLK),
                .GEN6_CLOCK_RATE                (GEN6_CLK),
                .CCIX_20G_CLOCK_RATE            (CCIX_20G_CLK),
                .CCIX_25G_CLOCK_RATE            (CCIX_25G_CLK)
            ) rc_phy (
                .pifs     (rc_pif),
                .txp      (tx_data),
                .txn      (tx_datan),
                .rxp      (rx_data),
                .rxn      (rx_datan),
                .clkreq_n (clkreq_n)
            );
        `endif

        //-----------------------------------------
        //Avery BFM Config
        //-----------------------------------------
        initial begin : APCI_RC_NUM_LANES_DEFN
            bit ok;
            //Note: pass virtual interface to UVM env
            uvm_config_db#(int)::set(uvm_root::get(), "*", "num_lanes", `APCI_NUM_LANES);
            
            //Note: wait for UVM env to pass drivers back
            forever begin : WAIT_DRV
                ok = uvm_config_db#(apci_device)::get(uvm_root::get(), "*", "apci_rc", apci_rc);
                if (ok)
                    break;
                else
                    #1us;
            end : WAIT_DRV
            `uvm_info("cxl_tb_top", $psprintf("Obtained APCI_RC"), UVM_LOW)
            
        end : APCI_RC_NUM_LANES_DEFN
            
        initial begin : APCI_RC_CONFIG

            bit [1023:0] detect_quiet_timeout_ps_arg;
            bit [1023:0] polling_active_timeout_ps_arg;
            int          set_bfm_mps = 'd128;

            `uvm_info("cxl_tb_top", $psprintf("Waiting for apci_rc assign"), UVM_LOW)
            wait (apci_rc != null);
            `uvm_info("cxl_tb_top", $psprintf("Obtained apci_rc!"), UVM_LOW)
            apci_rc.cfg_info.speed_sup         = 5; //Note: PCIE5.0
            apci_rc.cfg_info.cxl_sup           = 1;
            apci_rc.cxl_cfg_info.pcie_cap      = 0;
            apci_rc.cxl_cfg_info.cxl_io_cap    = 1;
            apci_rc.cxl_cfg_info.cxl_mem_cap   = 1;
            apci_rc.cxl_cfg_info.cxl_cache_cap = 1;
            apci_rc.set("auto_speedup", 1);
            if(!$test$plusargs("EN_GEN3_GEN4_EQBYP"))
              apci_rc.set("skip_equal_phase23", 1);
            else 
              apci_rc.set("skip_equal_phase23", 0);
            `uvm_info("cxl_tb_top", $psprintf("Inside AVERY_CXL"), UVM_LOW)
            #10ps;
            apci_rc.port_set_tracker(-1, "cfg", 1);                                                                                                                                                                             
            apci_rc.port_set_tracker(-1, "tl" , 1);
            apci_rc.port_set_tracker(-1, "dll", 1);
            apci_rc.port_set_tracker(-1, "phy", 1);
            apci_rc.cfg_info.lanenum_wait_delay = 800ns;  //Note: Set for Framing Error issue

            //Note: For Err [APCI4_2_6_4_2_2_3n4] DUT must continuously request for at least 1000ns, but it only request for 896ns
            `ifdef CXL_PIPE_MODE
               apci_rc.cfg_info.dut_recov_equal_rxeq_cont_requested =800ns;
            `endif

            if($value$plusargs("detect_quiet_timeout_ps_arg=%0d",detect_quiet_timeout_ps_arg)) begin : DETECT_QUIET_TIMEOUT_PS_ARG
                apci_rc.cfg_info.detect_quiet_timeout = detect_quiet_timeout_ps_arg;
                `uvm_info("cxl_tb_top", $sformatf("Detect.Quiet Timeout is overriden from cmdline to %0d ps", detect_quiet_timeout_ps_arg), UVM_LOW)
            end : DETECT_QUIET_TIMEOUT_PS_ARG 

            if($value$plusargs("polling_active_timeout_ps_arg=%0d",polling_active_timeout_ps_arg)) begin : POLLING_ACTIVE_TIMEOUT_PS_ARG
                apci_rc.cfg_info.polling_active_timeout = polling_active_timeout_ps_arg;
                `uvm_info("cxl_tb_top", $sformatf("Polling.Active Timeout is overriden from cmdline to %0d ps", polling_active_timeout_ps_arg), UVM_LOW)
            end : POLLING_ACTIVE_TIMEOUT_PS_ARG 

            if($test$plusargs("wait_for_ica_rdy4configload_i")) begin : WAIT_FOR_RDY4CONFIGLOAD
                `uvm_info("cxl_tb_top", $sformatf("Waiting for ica_rdy4configload_i === 1 to start_bfm"),UVM_LOW)
                `ifndef REPO
                    `ifdef BASE_IP
                        wait((`CFG_AVMM_CSR(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top, CFG_AVMM_CSR_k_partial_bypass_configload) === 1'b1) & (`CFG_AVMM_CSR(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top, CFG_AVMM_CSR_ica_rdy4configload_i) === 1'b1));
                    `elsif T1IP
                        wait((`CFG_AVMM_CSR(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top, CFG_AVMM_CSR_k_partial_bypass_configload) === 1'b1) & (`CFG_AVMM_CSR(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top, CFG_AVMM_CSR_ica_rdy4configload_i) === 1'b1));
                    `elsif T2IP
                        wait((`CFG_AVMM_CSR(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top, CFG_AVMM_CSR_k_partial_bypass_configload) === 1'b1) & (`CFG_AVMM_CSR(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top, CFG_AVMM_CSR_ica_rdy4configload_i) === 1'b1));
                    `elsif T3IP
                        wait((`CFG_AVMM_CSR(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top, CFG_AVMM_CSR_k_partial_bypass_configload) === 1'b1) & (`CFG_AVMM_CSR(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top, CFG_AVMM_CSR_ica_rdy4configload_i) === 1'b1));
                    `endif
                `else
                    `ifdef BASE_IP
                        wait((`CFG_AVMM_CSR(cxl_tb_top.dut.cxl_baseip_top, CFG_AVMM_CSR_k_partial_bypass_configload) === 1'b1) & (`CFG_AVMM_CSR(cxl_tb_top.dut.cxl_baseip_top, CFG_AVMM_CSR_ica_rdy4configload_i) === 1'b1));
                    `elsif T1IP
                        wait((`CFG_AVMM_CSR(cxl_tb_top.dut.cxl_type1_cxlip_top, CFG_AVMM_CSR_k_partial_bypass_configload) === 1'b1) & (`CFG_AVMM_CSR(cxl_tb_top.dut.cxl_type1_cxlip_top, CFG_AVMM_CSR_ica_rdy4configload_i) === 1'b1));
                    `elsif T2IP
                        wait((`CFG_AVMM_CSR(cxl_tb_top.dut.cxl_type2_cxlip_top, CFG_AVMM_CSR_k_partial_bypass_configload) === 1'b1) & (`CFG_AVMM_CSR(cxl_tb_top.dut.cxl_type2_cxlip_top, CFG_AVMM_CSR_ica_rdy4configload_i) === 1'b1));
                    `elsif T3IP
                        wait((`CFG_AVMM_CSR(cxl_tb_top.dut.cxl_type3_top_inst, CFG_AVMM_CSR_k_partial_bypass_configload) === 1'b1) & (`CFG_AVMM_CSR(cxl_tb_top.dut.cxl_type3_top_inst, CFG_AVMM_CSR_ica_rdy4configload_i) === 1'b1));
                    `endif
                `endif
                `uvm_info("cxl_tb_top", $sformatf("Done Waiting for ica_rdy4configload_i === 1 to start_bfm"),UVM_LOW)
            end : WAIT_FOR_RDY4CONFIGLOAD
        
            `uvm_info("cxl_tb_top", $sformatf("Waiting for cxl_tb_top.resetn === 1 to start_bfm"),UVM_LOW)
            wait(cxl_tb_top.resetn == 'h1);
            `uvm_info("cxl_tb_top", $sformatf("Done Waiting for cxl_tb_top.resetn === 1 to start_bfm"),UVM_LOW)
            if($value$plusargs("SET_BFM_MPS=%0d", set_bfm_mps))
            begin : BFM_MPS
                `uvm_info("cxl_tb_top", $sformatf("Set BFM MPS as %0d",set_bfm_mps), UVM_NONE)
                apci_rc.set("bus_enum_mps", set_bfm_mps);
            end : BFM_MPS
            apci_rc.set("start_bfm");

        end : APCI_RC_CONFIG
        
        task automatic start_test(apci_testcase_base test);

            apci_pkg_test::apci_test_select(test.test_name);
            //Note: user shall not put any delays inside this task Otherwise, pre_bfm_started() could be compromised.
            fork
                begin : WAIT_APCI_RC_OBTAIN
                    wait (apci_rc != null);
                    `uvm_info("cxl_tb_top", $psprintf("Obtained APCI_RC!"), UVM_LOW)
                end : WAIT_APCI_RC_OBTAIN
                begin : WAIT_APCI_RC_OBTAIN_WDOG
                    repeat(10) #100us `uvm_info("cxl_tb_top", $psprintf("still waiting for apci_rc assign"), UVM_LOW)
                    wait(0);
                end : WAIT_APCI_RC_OBTAIN_WDOG
            join_any
            disable fork;
            test.add_rc(apci_rc);
            test.add_bfm(apci_rc);
            test.add_rc_app_bfm(apci_rc);   //Note: to run DUT0-RC test
            test.add_dut1_bfm(apci_rc);     //Note: to run DUT1-RC test
            if (apci_rc && apci_rc.get("bfm_started"))
                test_log.usage("RC shall not be started yet");

            `ifdef APCI_NEW_PHY
                test_info.serial_phy = 1;
            `else
                test_info.serial_phy = 0;
            `endif //APCI_NEW_PHY
            test.run();

        endtask : start_test
        
        final begin : REPORT_PEND
            if (apci_rc)
                apci_rc.my_report("pending_trans");
        end : REPORT_PEND

        //---------------------------------------------------------------------------
        // Dump Enable
        //---------------------------------------------------------------------------
        initial begin : DUMP_ENABLE
            if($test$plusargs("APCI_DUMP_VCD")) begin : DUMP_VCD
                $dumpfile("cxl_tb_top.vcd");
                $dumpvars(0, cxl_tb_top);
                $dumpon;
            end : DUMP_VCD

            if($test$plusargs("APCI_DUMP_VPD")) begin : DUMP_VPD
                //Note: may need -debug_pp argument
                $vcdplusmemon(); //Note: for interface array
                $vcdplusfile("cxl_tb_top.vpd");
                $vcdpluson(0, cxl_tb_top);
            end : DUMP_VPD

            if($test$plusargs("APCI_DUMP_FSDB")) begin : DUMP_FSDB
                `uvm_info("cxl_tb_top", $psprintf("Start Dumping"), UVM_LOW)
                $fsdbDumpfile("cxl_tb_top.fsdb");
                $fsdbDumpvars(0, cxl_tb_top);
                $fsdbDumpvars("+struct");
                $fsdbDumpvars("+mda");
                $fsdbDumpvars("+all");
                $fsdbDumpon;
            end : DUMP_FSDB

            `ifdef QUESTASIM_TB 
               if($test$plusargs("APCI_DUMP_WLF")) begin : DUMP_WLF
                   `uvm_info("cxl_tb_top", $psprintf("Start WLF Dumping"), UVM_LOW)
                   $wlfdumpvars(0, cxl_tb_top);
               end : DUMP_WLF
            `endif

        end : DUMP_ENABLE
    
        //---------------------------------------------------------------------------
        // Initial: Turn off expected assertions
        //---------------------------------------------------------------------------
        initial begin : ASSERT_TURN_OFF
            `ifndef REPO
                `ifdef BASE_IP
                    `CXL_IP_DO_ASSERT_OFF(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top)
                `elsif T1IP
                    `CXL_IP_DO_ASSERT_OFF(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top)
                `elsif T2IP
                    `CXL_IP_DO_ASSERT_OFF(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top)
                `elsif T3IP
                    `CXL_IP_DO_ASSERT_OFF(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top)
                `endif
            `else
                `ifdef BASE_IP
                    `CXL_IP_DO_ASSERT_OFF(cxl_tb_top.dut.cxl_baseip_top)
                `elsif T1IP
                    `CXL_IP_DO_ASSERT_OFF(cxl_tb_top.dut.cxl_type1_cxlip_top)
                `elsif T2IP
                    `CXL_IP_DO_ASSERT_OFF(cxl_tb_top.dut.cxl_type2_cxlip_top)
                `elsif T3IP
                    `CXL_IP_DO_ASSERT_OFF(cxl_tb_top.dut.cxl_type3_top_inst)
                `endif
            `endif
    
        end : ASSERT_TURN_OFF
    
        
        //---------------------------------------------------------------------------
        // Initial: b_RUN_TEST
        // Set global time printing format and Call UVM's run_test task
        //---------------------------------------------------------------------------
        initial begin : b_RUN_TEST
            $timeformat(-9, 6, " ns", 18);
            `uvm_info("cxl_tb_top", $psprintf("Test Started!!"), UVM_LOW)
            run_test();
        end : b_RUN_TEST
    
        
        //---------------------------------------------------------------------------
        // Set the RC Phy Intf
        //---------------------------------------------------------------------------
        generate
            for (genvar i = 0; i < `APCI_NUM_LANES; i++) begin
                initial begin : PIPE_LANES
                    string s;
                    s = $psprintf("rc_pif[%0d]", i);
                    uvm_config_db#(virtual apci_pipe_intf)::set(uvm_root::get(), "*", s, rc_pif[i]);
        
                end : PIPE_LANES
            end
        endgenerate
        
        //---------------------------------------------------------------------------
        // Set the RC Device Number of lanes
        //---------------------------------------------------------------------------
        initial begin : SET_RC_NUM_LANES
            uvm_config_db#(int)::set(uvm_root::get(), "*", "num_lanes", `APCI_NUM_LANES);
        end : SET_RC_NUM_LANES
    
        // --------------------------------------
        // Adapter skew insertion logic
        // Note: Needs argument as a name finder for each RTILE instances
        //       like "inst_rtile_1".
        // --------------------------------------
        `include "adapter_skew.svhp"
        `ifndef REPO
            `ifdef BASE_IP
                `rnr_adaptor_skewer(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top, inst_rtile_1)
            `elsif T1IP
                `rnr_adaptor_skewer(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top, inst_rtile_1)
            `elsif T2IP
                `rnr_adaptor_skewer(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top, inst_rtile_1)
            `elsif T3IP
                `rnr_adaptor_skewer(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top, inst_rtile_1)
            `endif
        `else
            `ifdef BASE_IP
                `rnr_adaptor_skewer(cxl_tb_top.dut.cxl_baseip_top, inst_rtile_1)
            `elsif T1IP
                `rnr_adaptor_skewer(cxl_tb_top.dut.cxl_type1_cxlip_top, inst_rtile_1)
            `elsif T2IP
                `rnr_adaptor_skewer(cxl_tb_top.dut.cxl_type2_cxlip_top, inst_rtile_1)
            `elsif T3IP
                `rnr_adaptor_skewer(cxl_tb_top.dut.cxl_type3_top_inst, inst_rtile_1)
            `endif
        `endif
                                                             
        // --------------------------------------
        //PIPE mode connections
        // --------------------------------------
        `ifdef CXL_PIPE_MODE
            assign cxl_tb_top.ep_pif[0].SRISEnable                      =  o_phy_0_pipe_srisenable;
            assign cxl_tb_top.ep_pif[1].SRISEnable                      =  o_phy_1_pipe_srisenable;
            assign cxl_tb_top.ep_pif[2].SRISEnable                      =  o_phy_2_pipe_srisenable;
            assign cxl_tb_top.ep_pif[3].SRISEnable                      =  o_phy_3_pipe_srisenable;
            assign cxl_tb_top.ep_pif[4].SRISEnable                      =  o_phy_4_pipe_srisenable;
            assign cxl_tb_top.ep_pif[5].SRISEnable                      =  o_phy_5_pipe_srisenable;
            assign cxl_tb_top.ep_pif[6].SRISEnable                      =  o_phy_6_pipe_srisenable;
            assign cxl_tb_top.ep_pif[7].SRISEnable                      =  o_phy_7_pipe_srisenable;
            assign cxl_tb_top.ep_pif[8].SRISEnable                      =  o_phy_8_pipe_srisenable;
            assign cxl_tb_top.ep_pif[9].SRISEnable                      =  o_phy_9_pipe_srisenable;
            assign cxl_tb_top.ep_pif[10].SRISEnable                     =  o_phy_10_pipe_srisenable;
            assign cxl_tb_top.ep_pif[11].SRISEnable                     =  o_phy_11_pipe_srisenable;
            assign cxl_tb_top.ep_pif[12].SRISEnable                     =  o_phy_12_pipe_srisenable;
            assign cxl_tb_top.ep_pif[13].SRISEnable                     =  o_phy_13_pipe_srisenable;
            assign cxl_tb_top.ep_pif[14].SRISEnable                     =  o_phy_14_pipe_srisenable;
            assign cxl_tb_top.ep_pif[15].SRISEnable                     =  o_phy_15_pipe_srisenable;
            assign cxl_tb_top.ep_pif[0].M2P_MessageBus                  =  o_phy_0_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[1].M2P_MessageBus                  =  o_phy_1_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[2].M2P_MessageBus                  =  o_phy_2_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[3].M2P_MessageBus                  =  o_phy_3_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[4].M2P_MessageBus                  =  o_phy_4_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[5].M2P_MessageBus                  =  o_phy_5_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[6].M2P_MessageBus                  =  o_phy_6_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[7].M2P_MessageBus                  =  o_phy_7_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[8].M2P_MessageBus                  =  o_phy_8_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[9].M2P_MessageBus                  =  o_phy_9_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[10].M2P_MessageBus                 =  o_phy_10_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[11].M2P_MessageBus                 =  o_phy_11_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[12].M2P_MessageBus                 =  o_phy_12_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[13].M2P_MessageBus                 =  o_phy_13_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[14].M2P_MessageBus                 =  o_phy_14_pipe_M2P_MessageBus;
            assign cxl_tb_top.ep_pif[15].M2P_MessageBus                 =  o_phy_15_pipe_M2P_MessageBus;
            assign i_phy_0_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[0].P2M_MessageBus ;
            assign i_phy_1_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[1].P2M_MessageBus ;
            assign i_phy_2_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[2].P2M_MessageBus ;
            assign i_phy_3_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[3].P2M_MessageBus ;
            assign i_phy_4_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[4].P2M_MessageBus ;
            assign i_phy_5_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[5].P2M_MessageBus ;
            assign i_phy_6_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[6].P2M_MessageBus ;
            assign i_phy_7_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[7].P2M_MessageBus ;
            assign i_phy_8_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[8].P2M_MessageBus ;
            assign i_phy_9_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[9].P2M_MessageBus ;
            assign i_phy_10_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[10].P2M_MessageBus ;
            assign i_phy_11_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[11].P2M_MessageBus ;
            assign i_phy_12_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[12].P2M_MessageBus ;
            assign i_phy_13_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[13].P2M_MessageBus ;
            assign i_phy_14_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[14].P2M_MessageBus ;
            assign i_phy_15_pipe_P2M_MessageBus =  cxl_tb_top.ep_pif[15].P2M_MessageBus ;
            assign cxl_tb_top.ep_pif[0].RxEIDetectDisable                  =  o_phy_0_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[1].RxEIDetectDisable                  =  o_phy_1_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[2].RxEIDetectDisable                  =  o_phy_2_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[3].RxEIDetectDisable                  =  o_phy_3_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[4].RxEIDetectDisable                  =  o_phy_4_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[5].RxEIDetectDisable                  =  o_phy_5_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[6].RxEIDetectDisable                  =  o_phy_6_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[7].RxEIDetectDisable                  =  o_phy_7_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[8].RxEIDetectDisable                  =  o_phy_8_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[9].RxEIDetectDisable                  =  o_phy_9_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[10].RxEIDetectDisable                 =  o_phy_10_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[11].RxEIDetectDisable                 =  o_phy_11_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[12].RxEIDetectDisable                 =  o_phy_12_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[13].RxEIDetectDisable                 =  o_phy_13_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[14].RxEIDetectDisable                 =  o_phy_14_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[15].RxEIDetectDisable                 =  o_phy_15_pipe_rxelecidle_disable;
            assign cxl_tb_top.ep_pif[0].Width                  =  o_phy_0_pipe_Width;
            assign cxl_tb_top.ep_pif[1].Width                  =  o_phy_1_pipe_Width;
            assign cxl_tb_top.ep_pif[2].Width                  =  o_phy_2_pipe_Width;
            assign cxl_tb_top.ep_pif[3].Width                  =  o_phy_3_pipe_Width;
            assign cxl_tb_top.ep_pif[4].Width                  =  o_phy_4_pipe_Width;
            assign cxl_tb_top.ep_pif[5].Width                  =  o_phy_5_pipe_Width;
            assign cxl_tb_top.ep_pif[6].Width                  =  o_phy_6_pipe_Width;
            assign cxl_tb_top.ep_pif[7].Width                  =  o_phy_7_pipe_Width;
            assign cxl_tb_top.ep_pif[8].Width                  =  o_phy_8_pipe_Width;
            assign cxl_tb_top.ep_pif[9].Width                  =  o_phy_9_pipe_Width;
            assign cxl_tb_top.ep_pif[10].Width                 =  o_phy_10_pipe_Width;
            assign cxl_tb_top.ep_pif[11].Width                 =  o_phy_11_pipe_Width;
            assign cxl_tb_top.ep_pif[12].Width                 =  o_phy_12_pipe_Width;
            assign cxl_tb_top.ep_pif[13].Width                 =  o_phy_13_pipe_Width;
            assign cxl_tb_top.ep_pif[14].Width                 =  o_phy_14_pipe_Width;
            assign cxl_tb_top.ep_pif[15].Width                 =  o_phy_15_pipe_Width;
            assign cxl_tb_top.ep_pif[0].PclkRate                  =  o_phy_0_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[1].PclkRate                  =  o_phy_1_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[2].PclkRate                  =  o_phy_2_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[3].PclkRate                  =  o_phy_3_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[4].PclkRate                  =  o_phy_4_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[5].PclkRate                  =  o_phy_5_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[6].PclkRate                  =  o_phy_6_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[7].PclkRate                  =  o_phy_7_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[8].PclkRate                  =  o_phy_8_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[9].PclkRate                  =  o_phy_9_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[10].PclkRate                 =  o_phy_10_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[11].PclkRate                 =  o_phy_11_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[12].PclkRate                 =  o_phy_12_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[13].PclkRate                 =  o_phy_13_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[14].PclkRate                 =  o_phy_14_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[15].PclkRate                 =  o_phy_15_pipe_PCLKRate;
            assign cxl_tb_top.ep_pif[0].Pclk                  =  o_phy_0_pipe_PCLK;
            assign cxl_tb_top.ep_pif[1].Pclk                  =  o_phy_1_pipe_PCLK;
            assign cxl_tb_top.ep_pif[2].Pclk                  =  o_phy_2_pipe_PCLK;
            assign cxl_tb_top.ep_pif[3].Pclk                  =  o_phy_3_pipe_PCLK;
            assign cxl_tb_top.ep_pif[4].Pclk                  =  o_phy_4_pipe_PCLK;
            assign cxl_tb_top.ep_pif[5].Pclk                  =  o_phy_5_pipe_PCLK;
            assign cxl_tb_top.ep_pif[6].Pclk                  =  o_phy_6_pipe_PCLK;
            assign cxl_tb_top.ep_pif[7].Pclk                  =  o_phy_7_pipe_PCLK;
            assign cxl_tb_top.ep_pif[8].Pclk                  =  o_phy_8_pipe_PCLK;
            assign cxl_tb_top.ep_pif[9].Pclk                  =  o_phy_9_pipe_PCLK;
            assign cxl_tb_top.ep_pif[10].Pclk                 =  o_phy_10_pipe_PCLK;
            assign cxl_tb_top.ep_pif[11].Pclk                 =  o_phy_11_pipe_PCLK;
            assign cxl_tb_top.ep_pif[12].Pclk                 =  o_phy_12_pipe_PCLK;
            assign cxl_tb_top.ep_pif[13].Pclk                 =  o_phy_13_pipe_PCLK;
            assign cxl_tb_top.ep_pif[14].Pclk                 =  o_phy_14_pipe_PCLK;
            assign cxl_tb_top.ep_pif[15].Pclk                 =  o_phy_15_pipe_PCLK;
            assign cxl_tb_top.ep_pif[0].RxStandby                  =  o_phy_0_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[1].RxStandby                  =  o_phy_1_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[2].RxStandby                  =  o_phy_2_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[3].RxStandby                  =  o_phy_3_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[4].RxStandby                  =  o_phy_4_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[5].RxStandby                  =  o_phy_5_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[6].RxStandby                  =  o_phy_6_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[7].RxStandby                  =  o_phy_7_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[8].RxStandby                  =  o_phy_8_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[9].RxStandby                  =  o_phy_9_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[10].RxStandby                 =  o_phy_10_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[11].RxStandby                 =  o_phy_11_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[12].RxStandby                 =  o_phy_12_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[13].RxStandby                 =  o_phy_13_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[14].RxStandby                 =  o_phy_14_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[15].RxStandby                 =  o_phy_15_pipe_RxStandby;
            assign cxl_tb_top.ep_pif[0].RxTermination                  =  o_phy_0_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[1].RxTermination                  =  o_phy_1_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[2].RxTermination                  =  o_phy_2_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[3].RxTermination                  =  o_phy_3_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[4].RxTermination                  =  o_phy_4_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[5].RxTermination                  =  o_phy_5_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[6].RxTermination                  =  o_phy_6_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[7].RxTermination                  =  o_phy_7_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[8].RxTermination                  =  o_phy_8_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[9].RxTermination                  =  o_phy_9_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[10].RxTermination                 =  o_phy_10_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[11].RxTermination                 =  o_phy_11_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[12].RxTermination                 =  o_phy_12_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[13].RxTermination                 =  o_phy_13_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[14].RxTermination                 =  o_phy_14_pipe_RxTermination;
            assign cxl_tb_top.ep_pif[15].RxTermination                 =  o_phy_15_pipe_RxTermination;
            assign i_phy_0_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[0].RxStandbyStatus ;
            assign i_phy_1_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[1].RxStandbyStatus ;
            assign i_phy_2_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[2].RxStandbyStatus ;
            assign i_phy_3_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[3].RxStandbyStatus ;
            assign i_phy_4_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[4].RxStandbyStatus ;
            assign i_phy_5_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[5].RxStandbyStatus ;
            assign i_phy_6_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[6].RxStandbyStatus ;
            assign i_phy_7_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[7].RxStandbyStatus ;
            assign i_phy_8_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[8].RxStandbyStatus ;
            assign i_phy_9_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[9].RxStandbyStatus ;
            assign i_phy_10_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[10].RxStandbyStatus ;
            assign i_phy_11_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[11].RxStandbyStatus ;
            assign i_phy_12_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[12].RxStandbyStatus ;
            assign i_phy_13_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[13].RxStandbyStatus ;
            assign i_phy_14_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[14].RxStandbyStatus ;
            assign i_phy_15_pipe_RxStandbyStatus =  cxl_tb_top.ep_pif[15].RxStandbyStatus ;
            assign i_phy_0_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[0].PclkChangeOk ;
            assign i_phy_1_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[1].PclkChangeOk ;
            assign i_phy_2_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[2].PclkChangeOk ;
            assign i_phy_3_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[3].PclkChangeOk ;
            assign i_phy_4_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[4].PclkChangeOk ;
            assign i_phy_5_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[5].PclkChangeOk ;
            assign i_phy_6_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[6].PclkChangeOk ;
            assign i_phy_7_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[7].PclkChangeOk ;
            assign i_phy_8_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[8].PclkChangeOk ;
            assign i_phy_9_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[9].PclkChangeOk ;
            assign i_phy_10_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[10].PclkChangeOk ;
            assign i_phy_11_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[11].PclkChangeOk ;
            assign i_phy_12_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[12].PclkChangeOk ;
            assign i_phy_13_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[13].PclkChangeOk ;
            assign i_phy_14_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[14].PclkChangeOk ;
            assign i_phy_15_pipe_PclkChangeOk =  cxl_tb_top.ep_pif[15].PclkChangeOk ;
            assign cxl_tb_top.ep_pif[0].PclkChangeAck                  =  o_phy_0_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[1].PclkChangeAck                  =  o_phy_1_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[2].PclkChangeAck                  =  o_phy_2_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[3].PclkChangeAck                  =  o_phy_3_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[4].PclkChangeAck                  =  o_phy_4_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[5].PclkChangeAck                  =  o_phy_5_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[6].PclkChangeAck                  =  o_phy_6_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[7].PclkChangeAck                  =  o_phy_7_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[8].PclkChangeAck                  =  o_phy_8_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[9].PclkChangeAck                  =  o_phy_9_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[10].PclkChangeAck                 =  o_phy_10_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[11].PclkChangeAck                 =  o_phy_11_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[12].PclkChangeAck                 =  o_phy_12_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[13].PclkChangeAck                 =  o_phy_13_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[14].PclkChangeAck                 =  o_phy_14_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[15].PclkChangeAck                 =  o_phy_15_pipe_PclkChangeAck;
            assign cxl_tb_top.ep_pif[0].TxElecIdle                  =  o_phy_0_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[1].TxElecIdle                  =  o_phy_1_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[2].TxElecIdle                  =  o_phy_2_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[3].TxElecIdle                  =  o_phy_3_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[4].TxElecIdle                  =  o_phy_4_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[5].TxElecIdle                  =  o_phy_5_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[6].TxElecIdle                  =  o_phy_6_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[7].TxElecIdle                  =  o_phy_7_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[8].TxElecIdle                  =  o_phy_8_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[9].TxElecIdle                  =  o_phy_9_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[10].TxElecIdle                 =  o_phy_10_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[11].TxElecIdle                 =  o_phy_11_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[12].TxElecIdle                 =  o_phy_12_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[13].TxElecIdle                 =  o_phy_13_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[14].TxElecIdle                 =  o_phy_14_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[15].TxElecIdle                 =  o_phy_15_pipe_TxElecIdle;
            assign cxl_tb_top.ep_pif[0].Reset_                  =  phy_sys_ial_0__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[1].Reset_                  =  phy_sys_ial_1__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[2].Reset_                  =  phy_sys_ial_2__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[3].Reset_                  =  phy_sys_ial_3__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[4].Reset_                  =  phy_sys_ial_4__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[5].Reset_                  =  phy_sys_ial_5__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[6].Reset_                  =  phy_sys_ial_6__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[7].Reset_                  =  phy_sys_ial_7__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[8].Reset_                  =  phy_sys_ial_8__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[9].Reset_                  =  phy_sys_ial_9__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[10].Reset_                 =  phy_sys_ial_10__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[11].Reset_                 =  phy_sys_ial_11__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[12].Reset_                 =  phy_sys_ial_12__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[13].Reset_                 =  phy_sys_ial_13__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[14].Reset_                 =  phy_sys_ial_14__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[15].Reset_                 =  phy_sys_ial_15__pipe_Reset_l;
            assign cxl_tb_top.ep_pif[0].PowerDown                  =  o_phy_0_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[1].PowerDown                  =  o_phy_1_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[2].PowerDown                  =  o_phy_2_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[3].PowerDown                  =  o_phy_3_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[4].PowerDown                  =  o_phy_4_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[5].PowerDown                  =  o_phy_5_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[6].PowerDown                  =  o_phy_6_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[7].PowerDown                  =  o_phy_7_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[8].PowerDown                  =  o_phy_8_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[9].PowerDown                  =  o_phy_9_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[10].PowerDown                 =  o_phy_10_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[11].PowerDown                 =  o_phy_11_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[12].PowerDown                 =  o_phy_12_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[13].PowerDown                 =  o_phy_13_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[14].PowerDown                 =  o_phy_14_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[15].PowerDown                 =  o_phy_15_pipe_PowerDown;
            assign cxl_tb_top.ep_pif[0].TxDetectRx                 =  o_phy_0_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[1].TxDetectRx                 =  o_phy_1_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[2].TxDetectRx                 =  o_phy_2_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[3].TxDetectRx                 =  o_phy_3_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[4].TxDetectRx                 =  o_phy_4_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[5].TxDetectRx                 =  o_phy_5_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[6].TxDetectRx                 =  o_phy_6_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[7].TxDetectRx                 =  o_phy_7_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[8].TxDetectRx                 =  o_phy_8_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[9].TxDetectRx                 =  o_phy_9_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[10].TxDetectRx                =  o_phy_10_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[11].TxDetectRx                =  o_phy_11_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[12].TxDetectRx                =  o_phy_12_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[13].TxDetectRx                =  o_phy_13_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[14].TxDetectRx                =  o_phy_14_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[15].TxDetectRx                =  o_phy_15_pipe_TxDetRxLpbk;
            assign cxl_tb_top.ep_pif[0].Rate                  =  o_phy_0_pipe_Rate;
            assign cxl_tb_top.ep_pif[1].Rate                  =  o_phy_1_pipe_Rate;
            assign cxl_tb_top.ep_pif[2].Rate                  =  o_phy_2_pipe_Rate;
            assign cxl_tb_top.ep_pif[3].Rate                  =  o_phy_3_pipe_Rate;
            assign cxl_tb_top.ep_pif[4].Rate                  =  o_phy_4_pipe_Rate;
            assign cxl_tb_top.ep_pif[5].Rate                  =  o_phy_5_pipe_Rate;
            assign cxl_tb_top.ep_pif[6].Rate                  =  o_phy_6_pipe_Rate;
            assign cxl_tb_top.ep_pif[7].Rate                  =  o_phy_7_pipe_Rate;
            assign cxl_tb_top.ep_pif[8].Rate                  =  o_phy_8_pipe_Rate;
            assign cxl_tb_top.ep_pif[9].Rate                  =  o_phy_9_pipe_Rate;
            assign cxl_tb_top.ep_pif[10].Rate                 =  o_phy_10_pipe_Rate;
            assign cxl_tb_top.ep_pif[11].Rate                 =  o_phy_11_pipe_Rate;
            assign cxl_tb_top.ep_pif[12].Rate                 =  o_phy_12_pipe_Rate;
            assign cxl_tb_top.ep_pif[13].Rate                 =  o_phy_13_pipe_Rate;
            assign cxl_tb_top.ep_pif[14].Rate                 =  o_phy_14_pipe_Rate;
            assign cxl_tb_top.ep_pif[15].Rate                 =  o_phy_15_pipe_Rate;
            assign i_phy_0_pipe_RxValid =  cxl_tb_top.ep_pif[0].RxValid;
            assign i_phy_1_pipe_RxValid =  cxl_tb_top.ep_pif[1].RxValid;
            assign i_phy_2_pipe_RxValid =  cxl_tb_top.ep_pif[2].RxValid;
            assign i_phy_3_pipe_RxValid =  cxl_tb_top.ep_pif[3].RxValid;
            assign i_phy_4_pipe_RxValid =  cxl_tb_top.ep_pif[4].RxValid;
            assign i_phy_5_pipe_RxValid =  cxl_tb_top.ep_pif[5].RxValid;
            assign i_phy_6_pipe_RxValid =  cxl_tb_top.ep_pif[6].RxValid;
            assign i_phy_7_pipe_RxValid =  cxl_tb_top.ep_pif[7].RxValid;
            assign i_phy_8_pipe_RxValid =  cxl_tb_top.ep_pif[8].RxValid;
            assign i_phy_9_pipe_RxValid =  cxl_tb_top.ep_pif[9].RxValid;
            assign i_phy_10_pipe_RxValid =  cxl_tb_top.ep_pif[10].RxValid;
            assign i_phy_11_pipe_RxValid =  cxl_tb_top.ep_pif[11].RxValid;
            assign i_phy_12_pipe_RxValid =  cxl_tb_top.ep_pif[12].RxValid;
            assign i_phy_13_pipe_RxValid =  cxl_tb_top.ep_pif[13].RxValid;
            assign i_phy_14_pipe_RxValid =  cxl_tb_top.ep_pif[14].RxValid;
            assign i_phy_15_pipe_RxValid =  cxl_tb_top.ep_pif[15].RxValid;
            assign i_phy_0_pipe_PhyStatus =  cxl_tb_top.ep_pif[0].PhyStatus;
            assign i_phy_1_pipe_PhyStatus =  cxl_tb_top.ep_pif[1].PhyStatus;
            assign i_phy_2_pipe_PhyStatus =  cxl_tb_top.ep_pif[2].PhyStatus;
            assign i_phy_3_pipe_PhyStatus =  cxl_tb_top.ep_pif[3].PhyStatus;
            assign i_phy_4_pipe_PhyStatus =  cxl_tb_top.ep_pif[4].PhyStatus;
            assign i_phy_5_pipe_PhyStatus =  cxl_tb_top.ep_pif[5].PhyStatus;
            assign i_phy_6_pipe_PhyStatus =  cxl_tb_top.ep_pif[6].PhyStatus;
            assign i_phy_7_pipe_PhyStatus =  cxl_tb_top.ep_pif[7].PhyStatus;
            assign i_phy_8_pipe_PhyStatus =  cxl_tb_top.ep_pif[8].PhyStatus;
            assign i_phy_9_pipe_PhyStatus =  cxl_tb_top.ep_pif[9].PhyStatus;
            assign i_phy_10_pipe_PhyStatus =  cxl_tb_top.ep_pif[10].PhyStatus;
            assign i_phy_11_pipe_PhyStatus =  cxl_tb_top.ep_pif[11].PhyStatus;
            assign i_phy_12_pipe_PhyStatus =  cxl_tb_top.ep_pif[12].PhyStatus;
            assign i_phy_13_pipe_PhyStatus =  cxl_tb_top.ep_pif[13].PhyStatus;
            assign i_phy_14_pipe_PhyStatus =  cxl_tb_top.ep_pif[14].PhyStatus;
            assign i_phy_15_pipe_PhyStatus =  cxl_tb_top.ep_pif[15].PhyStatus;
            assign i_phy_0_pipe_RxElecIdle =  cxl_tb_top.ep_pif[0].RxElecIdle;
            assign i_phy_1_pipe_RxElecIdle =  cxl_tb_top.ep_pif[1].RxElecIdle;
            assign i_phy_2_pipe_RxElecIdle =  cxl_tb_top.ep_pif[2].RxElecIdle;
            assign i_phy_3_pipe_RxElecIdle =  cxl_tb_top.ep_pif[3].RxElecIdle;
            assign i_phy_4_pipe_RxElecIdle =  cxl_tb_top.ep_pif[4].RxElecIdle;
            assign i_phy_5_pipe_RxElecIdle =  cxl_tb_top.ep_pif[5].RxElecIdle;
            assign i_phy_6_pipe_RxElecIdle =  cxl_tb_top.ep_pif[6].RxElecIdle;
            assign i_phy_7_pipe_RxElecIdle =  cxl_tb_top.ep_pif[7].RxElecIdle;
            assign i_phy_8_pipe_RxElecIdle =  cxl_tb_top.ep_pif[8].RxElecIdle;
            assign i_phy_9_pipe_RxElecIdle =  cxl_tb_top.ep_pif[9].RxElecIdle;
            assign i_phy_10_pipe_RxElecIdle =  cxl_tb_top.ep_pif[10].RxElecIdle;
            assign i_phy_11_pipe_RxElecIdle =  cxl_tb_top.ep_pif[11].RxElecIdle;
            assign i_phy_12_pipe_RxElecIdle =  cxl_tb_top.ep_pif[12].RxElecIdle;
            assign i_phy_13_pipe_RxElecIdle =  cxl_tb_top.ep_pif[13].RxElecIdle;
            assign i_phy_14_pipe_RxElecIdle =  cxl_tb_top.ep_pif[14].RxElecIdle;
            assign i_phy_15_pipe_RxElecIdle =  cxl_tb_top.ep_pif[15].RxElecIdle;
            assign i_phy_0_pipe_RxStatus =  cxl_tb_top.ep_pif[0].RxStatus;
            assign i_phy_1_pipe_RxStatus =  cxl_tb_top.ep_pif[1].RxStatus;
            assign i_phy_2_pipe_RxStatus =  cxl_tb_top.ep_pif[2].RxStatus;
            assign i_phy_3_pipe_RxStatus =  cxl_tb_top.ep_pif[3].RxStatus;
            assign i_phy_4_pipe_RxStatus =  cxl_tb_top.ep_pif[4].RxStatus;
            assign i_phy_5_pipe_RxStatus =  cxl_tb_top.ep_pif[5].RxStatus;
            assign i_phy_6_pipe_RxStatus =  cxl_tb_top.ep_pif[6].RxStatus;
            assign i_phy_7_pipe_RxStatus =  cxl_tb_top.ep_pif[7].RxStatus;
            assign i_phy_8_pipe_RxStatus =  cxl_tb_top.ep_pif[8].RxStatus;
            assign i_phy_9_pipe_RxStatus =  cxl_tb_top.ep_pif[9].RxStatus;
            assign i_phy_10_pipe_RxStatus =  cxl_tb_top.ep_pif[10].RxStatus;
            assign i_phy_11_pipe_RxStatus =  cxl_tb_top.ep_pif[11].RxStatus;
            assign i_phy_12_pipe_RxStatus =  cxl_tb_top.ep_pif[12].RxStatus;
            assign i_phy_13_pipe_RxStatus =  cxl_tb_top.ep_pif[13].RxStatus;
            assign i_phy_14_pipe_RxStatus =  cxl_tb_top.ep_pif[14].RxStatus;
            assign i_phy_15_pipe_RxStatus =  cxl_tb_top.ep_pif[15].RxStatus;
            assign i_phy_0_pipe_RxClk =  cxl_tb_top.ep_pif[0].RxCLK;
            assign i_phy_1_pipe_RxClk =  cxl_tb_top.ep_pif[1].RxCLK;
            assign i_phy_2_pipe_RxClk =  cxl_tb_top.ep_pif[2].RxCLK;
            assign i_phy_3_pipe_RxClk =  cxl_tb_top.ep_pif[3].RxCLK;
            assign i_phy_4_pipe_RxClk =  cxl_tb_top.ep_pif[4].RxCLK;
            assign i_phy_5_pipe_RxClk =  cxl_tb_top.ep_pif[5].RxCLK;
            assign i_phy_6_pipe_RxClk =  cxl_tb_top.ep_pif[6].RxCLK;
            assign i_phy_7_pipe_RxClk =  cxl_tb_top.ep_pif[7].RxCLK;
            assign i_phy_8_pipe_RxClk =  cxl_tb_top.ep_pif[8].RxCLK;
            assign i_phy_9_pipe_RxClk =  cxl_tb_top.ep_pif[9].RxCLK;
            assign i_phy_10_pipe_RxClk =  cxl_tb_top.ep_pif[10].RxCLK;
            assign i_phy_11_pipe_RxClk =  cxl_tb_top.ep_pif[11].RxCLK;
            assign i_phy_12_pipe_RxClk =  cxl_tb_top.ep_pif[12].RxCLK;
            assign i_phy_13_pipe_RxClk =  cxl_tb_top.ep_pif[13].RxCLK;
            assign i_phy_14_pipe_RxClk =  cxl_tb_top.ep_pif[14].RxCLK;
            assign i_phy_15_pipe_RxClk =  cxl_tb_top.ep_pif[15].RxCLK;
            assign cxl_tb_top.ep_pif[0].RxWidth                  =  o_phy_0_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[1].RxWidth                  =  o_phy_1_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[2].RxWidth                  =  o_phy_2_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[3].RxWidth                  =  o_phy_3_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[4].RxWidth                  =  o_phy_4_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[5].RxWidth                  =  o_phy_5_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[6].RxWidth                  =  o_phy_6_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[7].RxWidth                  =  o_phy_7_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[8].RxWidth                  =  o_phy_8_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[9].RxWidth                  =  o_phy_9_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[10].RxWidth                 =  o_phy_10_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[11].RxWidth                 =  o_phy_11_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[12].RxWidth                 =  o_phy_12_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[13].RxWidth                 =  o_phy_13_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[14].RxWidth                 =  o_phy_14_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[15].RxWidth                 =  o_phy_15_pipe_RxWidth;
            assign cxl_tb_top.ep_pif[0].TxDataValid                  =  o_phy_0_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[1].TxDataValid                  =  o_phy_1_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[2].TxDataValid                  =  o_phy_2_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[3].TxDataValid                  =  o_phy_3_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[4].TxDataValid                  =  o_phy_4_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[5].TxDataValid                  =  o_phy_5_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[6].TxDataValid                  =  o_phy_6_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[7].TxDataValid                  =  o_phy_7_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[8].TxDataValid                  =  o_phy_8_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[9].TxDataValid                  =  o_phy_9_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[10].TxDataValid                 =  o_phy_10_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[11].TxDataValid                 =  o_phy_11_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[12].TxDataValid                 =  o_phy_12_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[13].TxDataValid                 =  o_phy_13_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[14].TxDataValid                 =  o_phy_14_pipe_TxDataValid;
            assign cxl_tb_top.ep_pif[15].TxDataValid                 =  o_phy_15_pipe_TxDataValid;
            assign {cxl_tb_top.ep_pif[0].TxData9[0],cxl_tb_top.ep_pif[0].TxDataK[0],cxl_tb_top.ep_pif[0].TxData[7:0]}   = o_phy_0_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[0].TxData9[1],cxl_tb_top.ep_pif[0].TxDataK[1],cxl_tb_top.ep_pif[0].TxData[15:8]}  = o_phy_0_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[0].TxData9[2],cxl_tb_top.ep_pif[0].TxDataK[2],cxl_tb_top.ep_pif[0].TxData[23:16]} = o_phy_0_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[0].TxData9[3],cxl_tb_top.ep_pif[0].TxDataK[3],cxl_tb_top.ep_pif[0].TxData[31:24]} = o_phy_0_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[1].TxData9[0], cxl_tb_top.ep_pif[1].TxDataK[0], cxl_tb_top.ep_pif[1].TxData[7:0]}   = o_phy_1_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[1].TxData9[1], cxl_tb_top.ep_pif[1].TxDataK[1], cxl_tb_top.ep_pif[1].TxData[15:8]}  = o_phy_1_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[1].TxData9[2], cxl_tb_top.ep_pif[1].TxDataK[2], cxl_tb_top.ep_pif[1].TxData[23:16]} = o_phy_1_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[1].TxData9[3], cxl_tb_top.ep_pif[1].TxDataK[3], cxl_tb_top.ep_pif[1].TxData[31:24]} = o_phy_1_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[2].TxData9[0], cxl_tb_top.ep_pif[2].TxDataK[0], cxl_tb_top.ep_pif[2].TxData[7:0]}   = o_phy_2_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[2].TxData9[1], cxl_tb_top.ep_pif[2].TxDataK[1], cxl_tb_top.ep_pif[2].TxData[15:8]}  = o_phy_2_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[2].TxData9[2], cxl_tb_top.ep_pif[2].TxDataK[2], cxl_tb_top.ep_pif[2].TxData[23:16]} = o_phy_2_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[2].TxData9[3], cxl_tb_top.ep_pif[2].TxDataK[3], cxl_tb_top.ep_pif[2].TxData[31:24]} = o_phy_2_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[3].TxData9[0], cxl_tb_top.ep_pif[3].TxDataK[0], cxl_tb_top.ep_pif[3].TxData[7:0]}   = o_phy_3_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[3].TxData9[1], cxl_tb_top.ep_pif[3].TxDataK[1], cxl_tb_top.ep_pif[3].TxData[15:8]}  = o_phy_3_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[3].TxData9[2], cxl_tb_top.ep_pif[3].TxDataK[2], cxl_tb_top.ep_pif[3].TxData[23:16]} = o_phy_3_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[3].TxData9[3], cxl_tb_top.ep_pif[3].TxDataK[3], cxl_tb_top.ep_pif[3].TxData[31:24]} = o_phy_3_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[4].TxData9[0], cxl_tb_top.ep_pif[4].TxDataK[0], cxl_tb_top.ep_pif[4].TxData[7:0]}   = o_phy_4_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[4].TxData9[1], cxl_tb_top.ep_pif[4].TxDataK[1], cxl_tb_top.ep_pif[4].TxData[15:8]}  = o_phy_4_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[4].TxData9[2], cxl_tb_top.ep_pif[4].TxDataK[2], cxl_tb_top.ep_pif[4].TxData[23:16]} = o_phy_4_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[4].TxData9[3], cxl_tb_top.ep_pif[4].TxDataK[3], cxl_tb_top.ep_pif[4].TxData[31:24]} = o_phy_4_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[5].TxData9[0], cxl_tb_top.ep_pif[5].TxDataK[0], cxl_tb_top.ep_pif[5].TxData[7:0]}   = o_phy_5_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[5].TxData9[1], cxl_tb_top.ep_pif[5].TxDataK[1], cxl_tb_top.ep_pif[5].TxData[15:8]}  = o_phy_5_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[5].TxData9[2], cxl_tb_top.ep_pif[5].TxDataK[2], cxl_tb_top.ep_pif[5].TxData[23:16]} = o_phy_5_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[5].TxData9[3], cxl_tb_top.ep_pif[5].TxDataK[3], cxl_tb_top.ep_pif[5].TxData[31:24]} = o_phy_5_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[6].TxData9[0], cxl_tb_top.ep_pif[6].TxDataK[0], cxl_tb_top.ep_pif[6].TxData[7:0]}   = o_phy_6_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[6].TxData9[1], cxl_tb_top.ep_pif[6].TxDataK[1], cxl_tb_top.ep_pif[6].TxData[15:8]}  = o_phy_6_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[6].TxData9[2], cxl_tb_top.ep_pif[6].TxDataK[2], cxl_tb_top.ep_pif[6].TxData[23:16]} = o_phy_6_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[6].TxData9[3], cxl_tb_top.ep_pif[6].TxDataK[3], cxl_tb_top.ep_pif[6].TxData[31:24]} = o_phy_6_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[7].TxData9[0], cxl_tb_top.ep_pif[7].TxDataK[0], cxl_tb_top.ep_pif[7].TxData[7:0]}   = o_phy_7_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[7].TxData9[1], cxl_tb_top.ep_pif[7].TxDataK[1], cxl_tb_top.ep_pif[7].TxData[15:8]}  = o_phy_7_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[7].TxData9[2], cxl_tb_top.ep_pif[7].TxDataK[2], cxl_tb_top.ep_pif[7].TxData[23:16]} = o_phy_7_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[7].TxData9[3], cxl_tb_top.ep_pif[7].TxDataK[3], cxl_tb_top.ep_pif[7].TxData[31:24]} = o_phy_7_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[8].TxData9[0], cxl_tb_top.ep_pif[8].TxDataK[0], cxl_tb_top.ep_pif[8].TxData[7:0]}   = o_phy_8_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[8].TxData9[1], cxl_tb_top.ep_pif[8].TxDataK[1], cxl_tb_top.ep_pif[8].TxData[15:8]}  = o_phy_8_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[8].TxData9[2], cxl_tb_top.ep_pif[8].TxDataK[2], cxl_tb_top.ep_pif[8].TxData[23:16]} = o_phy_8_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[8].TxData9[3], cxl_tb_top.ep_pif[8].TxDataK[3], cxl_tb_top.ep_pif[8].TxData[31:24]} = o_phy_8_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[9].TxData9[0], cxl_tb_top.ep_pif[9].TxDataK[0], cxl_tb_top.ep_pif[9].TxData[7:0]}   = o_phy_9_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[9].TxData9[1], cxl_tb_top.ep_pif[9].TxDataK[1], cxl_tb_top.ep_pif[9].TxData[15:8]}  = o_phy_9_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[9].TxData9[2], cxl_tb_top.ep_pif[9].TxDataK[2], cxl_tb_top.ep_pif[9].TxData[23:16]} = o_phy_9_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[9].TxData9[3], cxl_tb_top.ep_pif[9].TxDataK[3], cxl_tb_top.ep_pif[9].TxData[31:24]} = o_phy_9_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[10].TxData9[0], cxl_tb_top.ep_pif[10].TxDataK[0], cxl_tb_top.ep_pif[10].TxData[7:0]}   = o_phy_10_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[10].TxData9[1], cxl_tb_top.ep_pif[10].TxDataK[1], cxl_tb_top.ep_pif[10].TxData[15:8]}  = o_phy_10_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[10].TxData9[2], cxl_tb_top.ep_pif[10].TxDataK[2], cxl_tb_top.ep_pif[10].TxData[23:16]} = o_phy_10_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[10].TxData9[3], cxl_tb_top.ep_pif[10].TxDataK[3], cxl_tb_top.ep_pif[10].TxData[31:24]} = o_phy_10_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[11].TxData9[0], cxl_tb_top.ep_pif[11].TxDataK[0], cxl_tb_top.ep_pif[11].TxData[7:0]}   = o_phy_11_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[11].TxData9[1], cxl_tb_top.ep_pif[11].TxDataK[1], cxl_tb_top.ep_pif[11].TxData[15:8]}  = o_phy_11_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[11].TxData9[2], cxl_tb_top.ep_pif[11].TxDataK[2], cxl_tb_top.ep_pif[11].TxData[23:16]} = o_phy_11_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[11].TxData9[3], cxl_tb_top.ep_pif[11].TxDataK[3], cxl_tb_top.ep_pif[11].TxData[31:24]} = o_phy_11_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[12].TxData9[0], cxl_tb_top.ep_pif[12].TxDataK[0], cxl_tb_top.ep_pif[12].TxData[7:0]}   = o_phy_12_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[12].TxData9[1], cxl_tb_top.ep_pif[12].TxDataK[1], cxl_tb_top.ep_pif[12].TxData[15:8]}  = o_phy_12_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[12].TxData9[2], cxl_tb_top.ep_pif[12].TxDataK[2], cxl_tb_top.ep_pif[12].TxData[23:16]} = o_phy_12_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[12].TxData9[3], cxl_tb_top.ep_pif[12].TxDataK[3], cxl_tb_top.ep_pif[12].TxData[31:24]} = o_phy_12_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[13].TxData9[0], cxl_tb_top.ep_pif[13].TxDataK[0], cxl_tb_top.ep_pif[13].TxData[7:0]}   = o_phy_13_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[13].TxData9[1], cxl_tb_top.ep_pif[13].TxDataK[1], cxl_tb_top.ep_pif[13].TxData[15:8]}  = o_phy_13_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[13].TxData9[2], cxl_tb_top.ep_pif[13].TxDataK[2], cxl_tb_top.ep_pif[13].TxData[23:16]} = o_phy_13_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[13].TxData9[3], cxl_tb_top.ep_pif[13].TxDataK[3], cxl_tb_top.ep_pif[13].TxData[31:24]} = o_phy_13_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[14].TxData9[0], cxl_tb_top.ep_pif[14].TxDataK[0], cxl_tb_top.ep_pif[14].TxData[7:0]}   = o_phy_14_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[14].TxData9[1], cxl_tb_top.ep_pif[14].TxDataK[1], cxl_tb_top.ep_pif[14].TxData[15:8]}  = o_phy_14_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[14].TxData9[2], cxl_tb_top.ep_pif[14].TxDataK[2], cxl_tb_top.ep_pif[14].TxData[23:16]} = o_phy_14_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[14].TxData9[3], cxl_tb_top.ep_pif[14].TxDataK[3], cxl_tb_top.ep_pif[14].TxData[31:24]} = o_phy_14_pipe_TxData[39:30];
            assign {cxl_tb_top.ep_pif[15].TxData9[0], cxl_tb_top.ep_pif[15].TxDataK[0], cxl_tb_top.ep_pif[15].TxData[7:0]}   = o_phy_15_pipe_TxData[9:0];
            assign {cxl_tb_top.ep_pif[15].TxData9[1], cxl_tb_top.ep_pif[15].TxDataK[1], cxl_tb_top.ep_pif[15].TxData[15:8]}  = o_phy_15_pipe_TxData[19:10];
            assign {cxl_tb_top.ep_pif[15].TxData9[2], cxl_tb_top.ep_pif[15].TxDataK[2], cxl_tb_top.ep_pif[15].TxData[23:16]} = o_phy_15_pipe_TxData[29:20];
            assign {cxl_tb_top.ep_pif[15].TxData9[3], cxl_tb_top.ep_pif[15].TxDataK[3], cxl_tb_top.ep_pif[15].TxData[31:24]} = o_phy_15_pipe_TxData[39:30];
            assign i_phy_0_pipe_RxData[9:0] = {cxl_tb_top.ep_pif[0].RxData9[0], cxl_tb_top.ep_pif[0].RxDataK[0], cxl_tb_top.ep_pif[0].RxData[7:0]}  ;
            assign i_phy_0_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[0].RxData9[1], cxl_tb_top.ep_pif[0].RxDataK[1], cxl_tb_top.ep_pif[0].RxData[15:8]}   ;
            assign i_phy_0_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[0].RxData9[2], cxl_tb_top.ep_pif[0].RxDataK[2], cxl_tb_top.ep_pif[0].RxData[23:16]}  ;
            assign i_phy_0_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[0].RxData9[3], cxl_tb_top.ep_pif[0].RxDataK[3], cxl_tb_top.ep_pif[0].RxData[31:24]}  ;
            assign i_phy_1_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[1].RxData9[0], cxl_tb_top.ep_pif[1].RxDataK[0], cxl_tb_top.ep_pif[1].RxData[7:0]}  ;
            assign i_phy_1_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[1].RxData9[1], cxl_tb_top.ep_pif[1].RxDataK[1], cxl_tb_top.ep_pif[1].RxData[15:8]}   ;
            assign i_phy_1_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[1].RxData9[2], cxl_tb_top.ep_pif[1].RxDataK[2], cxl_tb_top.ep_pif[1].RxData[23:16]}  ;
            assign i_phy_1_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[1].RxData9[3], cxl_tb_top.ep_pif[1].RxDataK[3], cxl_tb_top.ep_pif[1].RxData[31:24]}  ;
            assign i_phy_2_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[2].RxData9[0], cxl_tb_top.ep_pif[2].RxDataK[0], cxl_tb_top.ep_pif[2].RxData[7:0]}  ;
            assign i_phy_2_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[2].RxData9[1], cxl_tb_top.ep_pif[2].RxDataK[1], cxl_tb_top.ep_pif[2].RxData[15:8]}   ;
            assign i_phy_2_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[2].RxData9[2], cxl_tb_top.ep_pif[2].RxDataK[2], cxl_tb_top.ep_pif[2].RxData[23:16]}  ;
            assign i_phy_2_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[2].RxData9[3], cxl_tb_top.ep_pif[2].RxDataK[3], cxl_tb_top.ep_pif[2].RxData[31:24]}  ;
            assign i_phy_3_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[3].RxData9[0], cxl_tb_top.ep_pif[3].RxDataK[0], cxl_tb_top.ep_pif[3].RxData[7:0]}  ;
            assign i_phy_3_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[3].RxData9[1], cxl_tb_top.ep_pif[3].RxDataK[1], cxl_tb_top.ep_pif[3].RxData[15:8]}   ;
            assign i_phy_3_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[3].RxData9[2], cxl_tb_top.ep_pif[3].RxDataK[2], cxl_tb_top.ep_pif[3].RxData[23:16]}  ;
            assign i_phy_3_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[3].RxData9[3], cxl_tb_top.ep_pif[3].RxDataK[3], cxl_tb_top.ep_pif[3].RxData[31:24]}  ;
            assign i_phy_4_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[4].RxData9[0], cxl_tb_top.ep_pif[4].RxDataK[0], cxl_tb_top.ep_pif[4].RxData[7:0]}  ;
            assign i_phy_4_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[4].RxData9[1], cxl_tb_top.ep_pif[4].RxDataK[1], cxl_tb_top.ep_pif[4].RxData[15:8]}   ;
            assign i_phy_4_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[4].RxData9[2], cxl_tb_top.ep_pif[4].RxDataK[2], cxl_tb_top.ep_pif[4].RxData[23:16]}  ;
            assign i_phy_4_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[4].RxData9[3], cxl_tb_top.ep_pif[4].RxDataK[3], cxl_tb_top.ep_pif[4].RxData[31:24]}  ;
            assign i_phy_5_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[5].RxData9[0], cxl_tb_top.ep_pif[5].RxDataK[0], cxl_tb_top.ep_pif[5].RxData[7:0]}  ;
            assign i_phy_5_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[5].RxData9[1], cxl_tb_top.ep_pif[5].RxDataK[1], cxl_tb_top.ep_pif[5].RxData[15:8]}   ;
            assign i_phy_5_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[5].RxData9[2], cxl_tb_top.ep_pif[5].RxDataK[2], cxl_tb_top.ep_pif[5].RxData[23:16]}  ;
            assign i_phy_5_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[5].RxData9[3], cxl_tb_top.ep_pif[5].RxDataK[3], cxl_tb_top.ep_pif[5].RxData[31:24]}  ;
            assign i_phy_6_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[6].RxData9[0], cxl_tb_top.ep_pif[6].RxDataK[0], cxl_tb_top.ep_pif[6].RxData[7:0]}  ;
            assign i_phy_6_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[6].RxData9[1], cxl_tb_top.ep_pif[6].RxDataK[1], cxl_tb_top.ep_pif[6].RxData[15:8]}   ;
            assign i_phy_6_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[6].RxData9[2], cxl_tb_top.ep_pif[6].RxDataK[2], cxl_tb_top.ep_pif[6].RxData[23:16]}  ;
            assign i_phy_6_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[6].RxData9[3], cxl_tb_top.ep_pif[6].RxDataK[3], cxl_tb_top.ep_pif[6].RxData[31:24]}  ;
            assign i_phy_7_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[7].RxData9[0], cxl_tb_top.ep_pif[7].RxDataK[0], cxl_tb_top.ep_pif[7].RxData[7:0]}  ;
            assign i_phy_7_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[7].RxData9[1], cxl_tb_top.ep_pif[7].RxDataK[1], cxl_tb_top.ep_pif[7].RxData[15:8]}   ;
            assign i_phy_7_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[7].RxData9[2], cxl_tb_top.ep_pif[7].RxDataK[2], cxl_tb_top.ep_pif[7].RxData[23:16]}  ;
            assign i_phy_7_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[7].RxData9[3], cxl_tb_top.ep_pif[7].RxDataK[3], cxl_tb_top.ep_pif[7].RxData[31:24]}  ;
            assign i_phy_8_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[8].RxData9[0], cxl_tb_top.ep_pif[8].RxDataK[0], cxl_tb_top.ep_pif[8].RxData[7:0]}  ;
            assign i_phy_8_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[8].RxData9[1], cxl_tb_top.ep_pif[8].RxDataK[1], cxl_tb_top.ep_pif[8].RxData[15:8]}   ;
            assign i_phy_8_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[8].RxData9[2], cxl_tb_top.ep_pif[8].RxDataK[2], cxl_tb_top.ep_pif[8].RxData[23:16]}  ;
            assign i_phy_8_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[8].RxData9[3], cxl_tb_top.ep_pif[8].RxDataK[3], cxl_tb_top.ep_pif[8].RxData[31:24]}  ;
            assign i_phy_9_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[9].RxData9[0], cxl_tb_top.ep_pif[9].RxDataK[0], cxl_tb_top.ep_pif[9].RxData[7:0]}  ;
            assign i_phy_9_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[9].RxData9[1], cxl_tb_top.ep_pif[9].RxDataK[1], cxl_tb_top.ep_pif[9].RxData[15:8]}   ;
            assign i_phy_9_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[9].RxData9[2], cxl_tb_top.ep_pif[9].RxDataK[2], cxl_tb_top.ep_pif[9].RxData[23:16]}  ;
            assign i_phy_9_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[9].RxData9[3], cxl_tb_top.ep_pif[9].RxDataK[3], cxl_tb_top.ep_pif[9].RxData[31:24]}  ;
            assign i_phy_10_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[10].RxData9[0], cxl_tb_top.ep_pif[10].RxDataK[0], cxl_tb_top.ep_pif[10].RxData[7:0]}  ;
            assign i_phy_10_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[10].RxData9[1], cxl_tb_top.ep_pif[10].RxDataK[1], cxl_tb_top.ep_pif[10].RxData[15:8]}   ;
            assign i_phy_10_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[10].RxData9[2], cxl_tb_top.ep_pif[10].RxDataK[2], cxl_tb_top.ep_pif[10].RxData[23:16]}  ;
            assign i_phy_10_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[10].RxData9[3], cxl_tb_top.ep_pif[10].RxDataK[3], cxl_tb_top.ep_pif[10].RxData[31:24]}  ;
            assign i_phy_11_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[11].RxData9[0], cxl_tb_top.ep_pif[11].RxDataK[0], cxl_tb_top.ep_pif[11].RxData[7:0]}  ;
            assign i_phy_11_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[11].RxData9[1], cxl_tb_top.ep_pif[11].RxDataK[1], cxl_tb_top.ep_pif[11].RxData[15:8]}   ;
            assign i_phy_11_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[11].RxData9[2], cxl_tb_top.ep_pif[11].RxDataK[2], cxl_tb_top.ep_pif[11].RxData[23:16]}  ;
            assign i_phy_11_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[11].RxData9[3], cxl_tb_top.ep_pif[11].RxDataK[3], cxl_tb_top.ep_pif[11].RxData[31:24]}  ;
            assign i_phy_12_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[12].RxData9[0], cxl_tb_top.ep_pif[12].RxDataK[0], cxl_tb_top.ep_pif[12].RxData[7:0]}  ;
            assign i_phy_12_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[12].RxData9[1], cxl_tb_top.ep_pif[12].RxDataK[1], cxl_tb_top.ep_pif[12].RxData[15:8]}   ;
            assign i_phy_12_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[12].RxData9[2], cxl_tb_top.ep_pif[12].RxDataK[2], cxl_tb_top.ep_pif[12].RxData[23:16]}  ;
            assign i_phy_12_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[12].RxData9[3], cxl_tb_top.ep_pif[12].RxDataK[3], cxl_tb_top.ep_pif[12].RxData[31:24]}  ;
            assign i_phy_13_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[13].RxData9[0], cxl_tb_top.ep_pif[13].RxDataK[0], cxl_tb_top.ep_pif[13].RxData[7:0]}  ;
            assign i_phy_13_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[13].RxData9[1], cxl_tb_top.ep_pif[13].RxDataK[1], cxl_tb_top.ep_pif[13].RxData[15:8]}   ;
            assign i_phy_13_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[13].RxData9[2], cxl_tb_top.ep_pif[13].RxDataK[2], cxl_tb_top.ep_pif[13].RxData[23:16]}  ;
            assign i_phy_13_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[13].RxData9[3], cxl_tb_top.ep_pif[13].RxDataK[3], cxl_tb_top.ep_pif[13].RxData[31:24]}  ;
            assign i_phy_14_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[14].RxData9[0], cxl_tb_top.ep_pif[14].RxDataK[0], cxl_tb_top.ep_pif[14].RxData[7:0]}  ;
            assign i_phy_14_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[14].RxData9[1], cxl_tb_top.ep_pif[14].RxDataK[1], cxl_tb_top.ep_pif[14].RxData[15:8]}   ;
            assign i_phy_14_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[14].RxData9[2], cxl_tb_top.ep_pif[14].RxDataK[2], cxl_tb_top.ep_pif[14].RxData[23:16]}  ;
            assign i_phy_14_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[14].RxData9[3], cxl_tb_top.ep_pif[14].RxDataK[3], cxl_tb_top.ep_pif[14].RxData[31:24]}  ;
            assign i_phy_15_pipe_RxData[9:0]   = {cxl_tb_top.ep_pif[15].RxData9[0], cxl_tb_top.ep_pif[15].RxDataK[0], cxl_tb_top.ep_pif[15].RxData[7:0]}  ;
            assign i_phy_15_pipe_RxData[19:10] = {cxl_tb_top.ep_pif[15].RxData9[1], cxl_tb_top.ep_pif[15].RxDataK[1], cxl_tb_top.ep_pif[15].RxData[15:8]}   ;
            assign i_phy_15_pipe_RxData[29:20] = {cxl_tb_top.ep_pif[15].RxData9[2], cxl_tb_top.ep_pif[15].RxDataK[2], cxl_tb_top.ep_pif[15].RxData[23:16]}  ;
            assign i_phy_15_pipe_RxData[39:30] = {cxl_tb_top.ep_pif[15].RxData9[3], cxl_tb_top.ep_pif[15].RxDataK[3], cxl_tb_top.ep_pif[15].RxData[31:24]}  ;
    

            initial
            begin
                force cxl_tb_top.ep_pif[0].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[1].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[2].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[3].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[4].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[5].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[6].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[7].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[8].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[9].PclkChangeOk_for_Width  =  1;
                force cxl_tb_top.ep_pif[10].PclkChangeOk_for_Width =  1;
                force cxl_tb_top.ep_pif[11].PclkChangeOk_for_Width =  1;
                force cxl_tb_top.ep_pif[12].PclkChangeOk_for_Width =  1;
                force cxl_tb_top.ep_pif[13].PclkChangeOk_for_Width =  1;
                force cxl_tb_top.ep_pif[14].PclkChangeOk_for_Width =  1;
                force cxl_tb_top.ep_pif[15].PclkChangeOk_for_Width =  1;
            end

            //FIXME - Temporary force. HIP team has to fix this in RTL.
            initial
            begin
                `ifdef REPO
                    `ifdef BASE_IP
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_0_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_1_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_2_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_3_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_4_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_5_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_6_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_7_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_8_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_9_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_10_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_11_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_12_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_13_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_14_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_baseip_top.cxl_ip.rtile_cxl_ip.i_phy_15_pipe_RxBitSlip_Ack = 0;
                    `elsif T1IP
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_0_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_1_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_2_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_3_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_4_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_5_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_6_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_7_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_8_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_9_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_10_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_11_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_12_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_13_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_14_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_15_pipe_RxBitSlip_Ack = 0;
                    `elsif T2IP
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_0_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_1_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_2_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_3_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_4_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_5_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_6_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_7_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_8_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_9_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_10_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_11_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_12_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_13_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_14_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type2_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_15_pipe_RxBitSlip_Ack = 0;                    
                    `elsif T3IP
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_0_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_1_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_2_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_3_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_4_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_5_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_6_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_7_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_8_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_9_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_10_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_11_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_12_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_13_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_14_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.cxl_type3_top_inst.cxl_ip.rtile_cxl_ip.i_phy_15_pipe_RxBitSlip_Ack = 0;                    
                    `endif                
                `else
                    `ifdef BASE_IP
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_0_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_1_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_2_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_3_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_4_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_5_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_6_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_7_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_8_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_9_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_10_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_11_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_12_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_13_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_14_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_15_pipe_RxBitSlip_Ack = 0;                
                    `elsif T1IP
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_0_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_1_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_2_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_3_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_4_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_5_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_6_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_7_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_8_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_9_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_10_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_11_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_12_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_13_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_14_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top.cxl_ip.rtile_cxl_ip.i_phy_15_pipe_RxBitSlip_Ack = 0;                    
                    `elsif T2IP
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_0_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_1_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_2_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_3_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_4_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_5_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_6_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_7_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_8_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_9_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_10_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_11_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_12_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_13_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_14_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top.cxl_ip.rtile_cxl_ip.i_phy_15_pipe_RxBitSlip_Ack = 0;                    
                    `elsif T3IP
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_0_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_1_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_2_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_3_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_4_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_5_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_6_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_7_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_8_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_9_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_10_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_11_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_12_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_13_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_14_pipe_RxBitSlip_Ack = 0;
                        force cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top.cxl_ip.rtile_cxl_ip.i_phy_15_pipe_RxBitSlip_Ack = 0;                    
                    `endif
                `endif
            end
        `endif
                                                    
        //---------------------------------------------------------------------------
        // Disable RTILE CLK Gates for faster TXNs flow
        //---------------------------------------------------------------------------
        initial
        begin : CLK_GATE_DIS
            if(!($test$plusargs("ENABLE_RTILE_CLK_GATING")))
            begin
                `ifndef REPO
                    `ifdef BASE_IP
                        `CXL_RTILE_CLKGATE_SPEEDING(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top)
                    `elsif T1IP
                        `CXL_RTILE_CLKGATE_SPEEDING(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top)
                    `elsif T2IP
                        `CXL_RTILE_CLKGATE_SPEEDING(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top)
                    `elsif T3IP
                        `CXL_RTILE_CLKGATE_SPEEDING(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top)
                    `endif
                `else
                    `ifdef BASE_IP
                        `CXL_RTILE_CLKGATE_SPEEDING(cxl_tb_top.dut.cxl_baseip_top)
                    `elsif T1IP
                        `CXL_RTILE_CLKGATE_SPEEDING(cxl_tb_top.dut.cxl_type1_cxlip_top)
                    `elsif T2IP
                        `CXL_RTILE_CLKGATE_SPEEDING(cxl_tb_top.dut.cxl_type2_cxlip_top)
                    `elsif T3IP
                        `CXL_RTILE_CLKGATE_SPEEDING(cxl_tb_top.dut.cxl_type3_top_inst)
                    `endif
                `endif
            end
        end : CLK_GATE_DIS
    

    endmodule : cxl_tb_top

`endif //CXL_TB_TOP__SV

