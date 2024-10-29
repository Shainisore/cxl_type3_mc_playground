//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2023
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : tb_dtl_filelist.f 
// Date Created    : Thu 13 April 2023
//--------------------------------------------------------------------------------
// Description  :
//     
//    Defines the Child TB files and directories for Simulation build setup.
//    Please include here for additional updates or developments.
//
//--------------------------------------------------------------------------------
// Version Map     :
//   -----------------------------
//    Version             : 1.0
//    Version Information : 
//       1. Initial Version.
//
//--------------------------------------------------------------------------------

//---------------------------------
// Child Package Switches 
//---------------------------------
+define+AVERY_VCS 
-sverilog 
$AVERY_PLI/lib.linux/libtb_vcs64.a 
-P $AVERY_PLI/tb_vcs64.tab   
-CFLAGS 
-DVCS 
+define+AVERY_UVM 
+define+UVM_NO_DEPRECATED 
+define+APCI_UVM_NO_START_BFM
+define+AVERY_NAMED_CONSTRUCTOR
+define+AVERY_CXL 
+define+APCI_NEW_PHY 
+define+APCI_TOP_PATH=$TOP_MODULE

//---------------------------------
// Child Package Directories
//---------------------------------
+incdir+$UVM_HOME/src
+incdir+$UVM_HOME
+incdir+$UVM_HOME/src/vcs
+incdir+$UVM_HOME/verdi
+incdir+$AVERY_PCIE/src.uvm 
+incdir+$AVERY_PCIE/testsuite/examples.uvm 
+incdir+$AVERY_PCIE/src.cxl 
+incdir+$AVERY_PCIE/src 
+incdir+$AVERY_PCIE/testbench  
+incdir+$AVERY_PCIE/src.VCS   
+incdir+$CXL_TOP_DIR/verif/
+incdir+$CXL_TOP_DIR/verif/env
+incdir+$CXL_TOP_DIR/verif/sequences
+incdir+$CXL_TOP_DIR/verif/tb_top
+incdir+$CXL_TOP_DIR/verif/tb_models
+incdir+$CXL_TOP_DIR/tests

//---------------------------------
// Child Package Files
//---------------------------------
$CXL_TOP_DIR/verif/tb_tar_child_dtl_pkg.sv
