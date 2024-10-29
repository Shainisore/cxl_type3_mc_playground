\
+define+QUESTASIM_TB \
\
+define+UVM_USE_OVM_RUN_SEMANTIC \
+define+UVM_NO_DEPRECATED \
+incdir+$UVM_HOME/src \
+incdir+$UVM_HOME/src/mentor \
$UVM_HOME/src/uvm_pkg.sv \
\
+define+AVERY_UVM \
+define+AVERY_NAMED_CONSTRUCTOR \
+define+AVERY_CXL \
+define+APCI_NEW_PHY \
+define+APCI_TOP_PATH=cxl_tb_top \
+define+APCI_UVM_NO_START_BFM \
+incdir+$AVERY_PCIE/src.uvm \
+incdir+$AVERY_PCIE/testsuite/examples.uvm \
+incdir+$AVERY_PCIE/src.cxl \
+incdir+$AVERY_PCIE/src \
+incdir+$AVERY_PCIE/testbench \
+incdir+$AVERY_PCIE/src.MTI \
$AVERY_PCIE/src/avery_pkg.sv \
$AVERY_PCIE/src/apci_pkg.sv \
$AVERY_PCIE/src/apci_pkg_test.sv \
$AVERY_PCIE/src/apci_pipe_intf.sv \
$AVERY_PCIE/src/apci_mpipe_box.sv \
$AVERY_PCIE/src.uvm/apci_uvm_pkg.sv \
$AVERY_PCIE/testsuite/examples.cxl/acxlt_type3_load_store.sv \
$AVERY_PCIE/testsuite/examples.cxl/acxlt_wr_rd_throughput.sv \
\
+incdir+$CXL_TOP_DIR/mem_mdl \
$CXL_TOP_DIR/mem_mdl/altera_emif_ddr4_model_db_chip.sv \
$CXL_TOP_DIR/mem_mdl/altera_emif_ddr4_model_rcd_chip.sv \
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model.sv \
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model_bidir_delay.sv \
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model_per_device.sv \
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model_per_ping_pong.sv \
$CXL_TOP_DIR/mem_mdl/altera_emif_ddrx_model_rank.sv \
$CXL_TOP_DIR/mem_mdl/ed_sim_mem_altera_emif_mem_model_191_jkh6tsy.v \
$CXL_TOP_DIR/mem_mdl/ed_sim_mem.v \
\
+incdir+$CXL_TOP_DIR/verif/env \
+incdir+$CXL_TOP_DIR/verif/sequences \
+incdir+$CXL_TOP_DIR/verif/tb_top \
+incdir+$CXL_TOP_DIR/verif/tb_models \
+incdir+$CXL_TOP_DIR/tests \
$CXL_TOP_DIR/verif/cxl_tb_pkg.svh \
$CXL_TOP_DIR/verif/tb_tar_child_dtl_pkg.sv \
$CXL_TOP_DIR/verif/tb_models/metastable_behav.svp \
$CXL_TOP_DIR/verif/tb_top/cxl_tb_top.sv \
$CXL_TOP_DIR/verif/tb_top/cxl_tb_top_config.sv
