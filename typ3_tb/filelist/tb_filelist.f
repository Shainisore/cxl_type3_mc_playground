//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : tb_filelist.f 
// Date Created    : Mon 31 January 2022
//--------------------------------------------------------------------------------
// Description  :
//     
//    Defines the TB files and directories for Simulation build setup.
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
// Common files
//---------------------------------
+incdir+$UVM_HOME/src
+incdir+$UVM_HOME/src/vcs
+incdir+$UVM_HOME/verdi
$UVM_HOME/src/uvm_pkg.sv  
$UVM_HOME/src/vcs/uvm_custom_install_vcs_recorder.sv
$UVM_HOME/verdi/uvm_custom_install_verdi_recorder.sv

//---------------------------------
// AVERY BFM files
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

+incdir+$AVERY_PCIE/src.uvm 
+incdir+$UVM_HOME/src 
+incdir+$AVERY_PCIE/testsuite/examples.uvm 
+incdir+$AVERY_PCIE/src.cxl 
+incdir+$AVERY_PCIE/src 
+incdir+$AVERY_PCIE/testbench  
+incdir+$AVERY_PCIE/src.VCS   
$AVERY_PCIE/src/avery_pkg.sv  
$AVERY_PCIE/src/apci_pkg.sv 
$AVERY_PCIE/src/apci_pkg_test.sv 
$AVERY_PCIE/src/apci_pipe_intf.sv
$AVERY_PCIE/src/apci_mpipe_box.sv
$AVERY_PCIE/src/apci_phy.sv
$AVERY_PCIE/src.uvm/apci_uvm_pkg.sv 
$AVERY_PCIE/src.VCS/apci_device.sv 
$AVERY_PCIE/testsuite/examples.cxl/acxlt_type3_load_store.sv
$AVERY_PCIE/testsuite/examples.cxl/acxlt_wr_rd_throughput.sv

//---------------------------------
// DDR MEM Model files
//---------------------------------

+incdir+$CXL_TOP_DIR/mem_mdl
 
$CXL_TOP_DIR/mem_mdl/altera_emif_ddr4_model_db_chip.sv
$CXL_TOP_DIR/mem_mdl/altera_emif_ddr4_model_rcd_chip.sv
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model.sv
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model_bidir_delay.sv
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model_per_device.sv
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model_per_ping_pong.sv
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model_rank.sv
$CXL_TOP_DIR/mem_mdl/ed_sim_mem_altera_emif_mem_model_191_jkh6tsy.v
$CXL_TOP_DIR/mem_mdl/ed_sim_mem.v

//---------------------------------
// Top TB files
//---------------------------------
+incdir+$CXL_TOP_DIR/verif/env
+incdir+$CXL_TOP_DIR/verif/sequences
+incdir+$CXL_TOP_DIR/verif/tb_top
+incdir+$CXL_TOP_DIR/verif/tb_models
+incdir+$CXL_TOP_DIR/tests
$CXL_TOP_DIR/verif/cxl_tb_pkg.svh
$CXL_TOP_DIR/verif/tb_models/metastable_behav.svp
$CXL_TOP_DIR/verif/tb_top/cxl_tb_top.sv
$CXL_TOP_DIR/verif/tb_top/cxl_tb_top_config.sv

