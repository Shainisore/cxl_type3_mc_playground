##--------------------------------------------------------------------------------
## Copyright (c) Programmable Solutions Group (PSG),
## Intel Corporation 2022.
## All rights reserved.
##--------------------------------------------------------------------------------
## File name       : Makefile 
## Date Created    : Mon 13 December 2021
##--------------------------------------------------------------------------------
## Description     : 
##     
##    Makefile to setup and execute Synopsys VCS Commands. 
##
##--------------------------------------------------------------------------------
## Version Map     :
##   -----------------------------
##    Version             : 1.4
##    Version Information : 
##       1. Added commands for Questasim support.
##
##   -----------------------------
##    Version             : 1.3
##    Version Information : 
##       1. Added commands for DTL simulation support.
##
##   -----------------------------
##    Version             : 1.2
##    Version Information : 
##       1. Added option for External simulation directoy name.
##
##   -----------------------------
##    Version             : 1.1
##    Version Information : 
##       1. File Header Updates.
##       2. Added option for External only VCS  Simulation argunments.
##
##   -----------------------------
##    Version             : 1.0
##    Version Information : 
##       1. Initial Version.
##
##--------------------------------------------------------------------------------


##################################################################
#### USER should source the terminal with below Variables - starts
##################################################################
#setenv VCS_HOME 			 <path from root>;
#setenv VERDI_HOME 			 <path from root>;
#setenv UVM_HOME 			 <path from root>;
#setenv QUARTUS_INSTALL_DIR  <path from root>;
#setenv QUARTUS_LIB_DIR      <path from root>;
 
#setenv LM_LICENSE_FILE 	 <path from root>;
#setenv SNPSLMD_LICENSE_FILE <path from root>;
 
#setenv AVERY_PCIE 			 <path from root>;
#setenv AVERY_PLI 			 <path from root>;
##################################################################
#### USER should source the terminal with below Variables - ends
##################################################################



########################################################
## Setup (based on the $USER shell)
########################################################

##################################
#### Makefile Variables
##################################
export CXL_TOP_DIR := $(CXL_TOP_DIR) 
export ELAB_PARAM_DEFINES := $(ELAB_PARAM_DEFINES)
export MEM_RTL_PATH := $(MEM_RTL_PATH)
export PRJ_IP_FILELIST := $(PRJ_IP_FILELIST)
export PRJ_SIM_DEFINES := $(CXL_TOP_DIR)/verif/defines/sim_defines.args
export E_PRJ_SIM_DEFINES := $(E_PRJ_SIM_DEFINES)
export PRJ_TB_DEFINES := $(CXL_TOP_DIR)/verif/defines/tb_defines.svhp
export PRJ_TB_QDEFINES := $(CXL_TOP_DIR)/verif/defines/tb_defines.args
export PRJ_TB_FILELIST := $(PRJ_TB_FILELIST)
export CXL_TILE_RTL_PATH := $(CXL_TILE_RTL_PATH)
export RTL_PATH := $(RTL_PATH)
export TOP_MODULE_CFG := $(TOP_MODULE_CFG)
export TOP_MODULE := $(TOP_MODULE)
export WORK_DIR := $(WORK_DIR)
export SIM_DIR_NAME := $(SIM_DIR_NAME)
export LIBNAME := $(LIBNAME)
export PRJ_CMP_DEFINES := $(PRJ_CMP_DEFINES)
export PRJ_SIM_ARGS := $(PRJ_SIM_ARGS)

########################################################
## Targets (commands based on default options)
########################################################
set_vcs:
	cp -rf ${VCS_HOME}/doc/examples/basic-hdl/sv/Nettype/nettype_res_func/synopsys_sim.setup ${WORK_DIR}/. ;

compile_ip_cmd:
	ln -sf $(CXL_TOP_DIR)/scripts/xprop.cfg ${WORK_DIR}/xprop.cfg; \
	${VCS_HOME}/bin/vlogan -sverilog +libext+.v+.vs+.sv+.vh+.svh +v2k -full64 +vcs+nostdout -kdb -assert enable_diag -assert svaext -timescale=1ps/1fs +warn=noTMR +error+100 +define+VCS +define+VCSSIM -f ${PRJ_IP_FILELIST} -l ${WORK_DIR}/$(LOGNAME) -f ${PRJ_CMP_DEFINES} -work ${LIBNAME} 
                                                                                                                                                                                 
compile_tb_cmd:                                                                                                                                                                      
	${VCS_HOME}/bin/vlogan -sverilog +libext+.v+.vs+.sv+.vh+.svh +v2k -full64 +vcs+nostdout -kdb -assert enable_diag -assert svaext -timescale=1ps/1fs +warn=noTMR +error+100 +define+VCS +define+VCSSIM ${PRJ_TB_DEFINES} -f ${PRJ_TB_FILELIST} -l ${WORK_DIR}/$(LOGNAME) -f ${PRJ_CMP_DEFINES} -work ${LIBNAME}

elab_cmd:
	${VCS_HOME}/bin/vcs +vcs+lic+wait  ${TOP_MODULE_CFG} +plusarg_save -xprop=${WORK_DIR}/xprop.cfg +vcs+lic+wait -full64 +vcs+nostdout -kdb -lca -assert enable_diag -assert svaext -o ${WORK_DIR}/simv +lint=TFIPC-L +lint=PCWM +warn=noSVA-LDRF -j4  -P ${VERDI_HOME}/share/PLI/VCS/LINUX/novas.tab +warn=noLCA_FEATURES_ENABLED +warn=noDFLT_OPT +warn=noSVA-TIDE +warn=noOSVF-NPVIUFPI +warn=noUFTMD  +error+1000  -debug_access+all+classdbg+f -debug_region=lib+cell -CFLAGS -DVCS ${VCS_HOME}/etc/uvm-1.2/src/dpi/uvm_dpi.cc ${AVERY_PLI}/lib.linux/libtb_vcs64.a -P ${AVERY_PLI}/tb_vcs64.tab  -l ${WORK_DIR}/elab.log 

compile_dtl_ip_cmd:
	ln -sf $(CXL_TOP_DIR)/scripts/xprop.cfg ${WORK_DIR}/xprop.cfg; \
	${VCS_HOME}/bin/vlogan -sverilog +libext+.v+.vs+.sv+.vh+.svh +v2k -full64 +vcs+nostdout -kdb=common_elab -assert svaext -timescale=1ps/1fs +warn=noTMR +define+VCS +define+VCSSIM +define+UVM_VCS_DTL +define+TB_DTL_MODE -f ${PRJ_IP_FILELIST} -l ${WORK_DIR}/$(LOGNAME) -f ${PRJ_CMP_DEFINES} -work ${LIBNAME} 
                                                                                                                                                                                 
compile_dtl_save_tb_cmd:                                                                                                                                                                      
	${VCS_HOME}/bin/vlogan -sverilog +libext+.v+.vs+.sv+.vh+.svh +v2k -full64 +vcs+nostdout -kdb=common_elab -assert svaext -timescale=1ps/1fs +warn=noTMR +define+VCS +define+VCSSIM +define+UVM_VCS_DTL +define+TB_DTL_MODE ${PRJ_TB_DEFINES} -f ${PRJ_TB_FILELIST} -l ${WORK_DIR}/$(LOGNAME) -f ${PRJ_CMP_DEFINES} -work ${LIBNAME}

compile_dtl_restore_tb_cmd:                                                                                                                                                                      
	${VCS_HOME}/bin/vlogan -sverilog +libext+.v+.vs+.sv+.vh+.svh +v2k -full64 +vcs+nostdout -kdb=common_elab -assert svaext -timescale=1ps/1fs +warn=noTMR +define+VCS +define+VCSSIM +define+UVM_VCS_DTL +define+TB_DTL_MODE -f ${PRJ_TB_FILELIST} -l ${WORK_DIR}/$(LOGNAME) -f ${PRJ_CMP_DEFINES} -work ${LIBNAME}

elab_dtl_save_cmd:
	${VCS_HOME}/bin/vcs +vcs+lic+wait   ${TOP_MODULE_CFG} -partcomp -partcomp=autopart_high -dir=tb_tar_base_dtl_pkg_IP -enable_dynamic_tb -ntb_opts uvm-1.2 +plusarg_save -xprop=${WORK_DIR}/xprop.cfg +vcs+lic+wait -full64  -kdb=common_elab -lca -assert svaext -o ${WORK_DIR}/simv +lint=TFIPC-L +lint=PCWM +warn=noSVA-LDRF -j4  -P ${VERDI_HOME}/share/PLI/VCS/LINUX/novas.tab +warn=noLCA_FEATURES_ENABLED +warn=noDFLT_OPT +warn=noSVA-TIDE +warn=noOSVF-NPVIUFPI +warn=noUFTMD  +error+1000 -partcomp  -CFLAGS -DVCS ${VCS_HOME}/etc/uvm-1.2/src/dpi/uvm_dpi.cc ${AVERY_PLI}/lib.linux/libtb_vcs64.a -P ${AVERY_PLI}/tb_vcs64.tab -l ${WORK_DIR}/elab_dtl_save.log -debug_access+pp+f -debug_region=cell+lib -Xvgprofile

elab_dtl_restore_cmd:
	${VCS_HOME}/bin/vcs -dynamic_tb +vcs+lic+wait  -ntb_opts uvm-1.2 -partcomp=autopart_high -sharedlib=${WORK_DIR}/tb_tar_base_dtl_pkg_IP -partcomp tb_tar_child_dtl_pkg  -dynamic_tb -dir=tb_tar_child_dtl_dir +plusarg_save -xprop=${WORK_DIR}/xprop.cfg +vcs+lic+wait -full64  -kdb=common_elab -lca -assert svaext -o ${WORK_DIR}/simv +lint=TFIPC-L +lint=PCWM +warn=noSVA-LDRF -j4  -P ${VERDI_HOME}/share/PLI/VCS/LINUX/novas.tab +warn=noLCA_FEATURES_ENABLED +warn=noDFLT_OPT +warn=noSVA-TIDE +warn=noOSVF-NPVIUFPI +warn=noUFTMD  +error+1000 -partcomp  -CFLAGS -DVCS ${AVERY_PLI}/lib.linux/libtb_vcs64.a -P ${AVERY_PLI}/tb_vcs64.tab -l ${WORK_DIR}/elab_dtl_restore.log  -debug_access+pp+f -debug_region=cell+lib -Xvgprofile

#Note: Refer VCS files for the softlinks. Ex.: ${CXL_TILE_RTL_PATH}/rtl/subIP/qhip/rnr_cxl_tlp_bypass/sim/common/vcs_files.tcl
set_sim:
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen0.mif ${WORK_DIR}/${SIM_DIR_NAME}/lutlen0.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen1.mif ${WORK_DIR}/${SIM_DIR_NAME}/lutlen1.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen2.mif ${WORK_DIR}/${SIM_DIR_NAME}/lutlen2.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen3.mif ${WORK_DIR}/${SIM_DIR_NAME}/lutlen3.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen4.mif ${WORK_DIR}/${SIM_DIR_NAME}/lutlen4.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen5.mif ${WORK_DIR}/${SIM_DIR_NAME}/lutlen5.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen6.mif ${WORK_DIR}/${SIM_DIR_NAME}/lutlen6.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen7.mif ${WORK_DIR}/${SIM_DIR_NAME}/lutlen7.mif; \
	touch ucli.do; \
  ln -sf $(CXL_TOP_DIR)/scripts/save_dtl.ucli ${WORK_DIR}/${SIM_DIR_NAME}/save_dtl.ucli; \
  ln -sf $(CXL_TOP_DIR)/scripts/restore_dtl.ucli ${WORK_DIR}/${SIM_DIR_NAME}/restore_dtl.ucli;

set_rundir:
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen0.mif ${WORK_DIR}/lutlen0.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen1.mif ${WORK_DIR}/lutlen1.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen2.mif ${WORK_DIR}/lutlen2.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen3.mif ${WORK_DIR}/lutlen3.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen4.mif ${WORK_DIR}/lutlen4.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen5.mif ${WORK_DIR}/lutlen5.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen6.mif ${WORK_DIR}/lutlen6.mif; \
	ln -sf  ${CXL_TILE_RTL_PATH}/lutlen7.mif ${WORK_DIR}/lutlen7.mif;

qverilog_cmd:
	qverilog -f ${CXL_TOP_DIR}/filelist/questa_opt.f -f ${PRJ_TB_QDEFINES} -f ${RTL_PATH}/sim_filelist/filelist.f -f ${CXL_TOP_DIR}/filelist/questa_eda_ncrypt_lib.f -f ${CXL_TOP_DIR}/filelist/questa_tb_filelist.f -f ${PRJ_CMP_DEFINES} -f ${PRJ_SIM_DEFINES} ${E_PRJ_SIM_DEFINES} -f ${PRJ_SIM_ARGS} -l mti.log; 

sim_cmd:
	${WORK_DIR}/simv -debug_access+all -assert nopostproc -assert maxfail=2+maxsuccess=2 +memcbk +vcs+nostdout +warn=noFCDCI +warn=noFCICIO +vcs+lic+wait -l ${WORK_DIR}/${SIM_DIR_NAME}/sim.log -ucli -do ucli.do -f ${PRJ_SIM_DEFINES} ${E_PRJ_SIM_DEFINES} -f ${PRJ_SIM_ARGS}

sim_d_cmd:
	${WORK_DIR}/simv -debug_access+all -assert nopostproc -assert maxfail=2+maxsuccess=2 +memcbk +vcs+nostdout +warn=noFCDCI +warn=noFCICIO +vcs+lic+wait +fsdb+sva_success -l ${WORK_DIR}/${SIM_DIR_NAME}/sim.log -ucli -do ucli.do -f ${PRJ_SIM_DEFINES}  ${E_PRJ_SIM_DEFINES} -f ${PRJ_SIM_ARGS}

sim_g_cmd:
	${WORK_DIR}/simv -debug_access+all -assert nopostproc -assert maxfail=2+maxsuccess=2 +memcbk +vcs+nostdout +warn=noFCDCI +warn=noFCICIO +vcs+lic+wait +fsdb+sva_success -l ${WORK_DIR}/${SIM_DIR_NAME}/sim.log -gui -ucli -do ucli.do -f ${PRJ_SIM_DEFINES}  ${E_PRJ_SIM_DEFINES} -f ${PRJ_SIM_ARGS}

sim_dtl_save_d_cmd:
	${WORK_DIR}/simv -debug_access+all -assert nopostproc +memcbk +vcs+nostdout +warn=noFCDCI +warn=noFCICIO +vcs+lic+wait +fsdb+sva_success -l ${WORK_DIR}/${SIM_DIR_NAME}/sim.log -ucli -i save_dtl.ucli -ucli -do ucli.do -f ${PRJ_SIM_DEFINES}  ${E_PRJ_SIM_DEFINES} -f ${PRJ_SIM_ARGS}

sim_dtl_restore_d_cmd:
	${WORK_DIR}/simv -debug_access+all -assert nopostproc +memcbk +vcs+nostdout +warn=noFCDCI +warn=noFCICIO +vcs+lic+wait +fsdb+sva_success -l ${WORK_DIR}/${SIM_DIR_NAME}/sim_restore.log -ucli -i restore_dtl.ucli -ucli -do ucli.do -f ${PRJ_SIM_DEFINES}  ${E_PRJ_SIM_DEFINES} -f ${PRJ_SIM_ARGS}

sim_dtl_save_cmd:
	${WORK_DIR}/simv -debug_access+all -assert nopostproc +memcbk  +warn=noFCDCI +warn=noFCICIO +vcs+lic+wait -l ${WORK_DIR}/${SIM_DIR_NAME}/sim.log -ucli -ucli2proc -ucli -i save_dtl.ucli -ucli -do ucli.do -f ${PRJ_SIM_DEFINES} ${E_PRJ_SIM_DEFINES} -f ${PRJ_SIM_ARGS}

sim_dtl_restore_cmd:
	${WORK_DIR}/simv -debug_access+all -assert nopostproc +memcbk  +warn=noFCDCI +warn=noFCICIO +vcs+lic+wait -l ${WORK_DIR}/${SIM_DIR_NAME}/sim_restore.log -ucli -ucli2proc -ucli -i restore_dtl.ucli -ucli -do ucli.do -f ${PRJ_SIM_DEFINES} ${E_PRJ_SIM_DEFINES} -f ${PRJ_SIM_ARGS}

clean_all:
	rm -rf ${WORK_DIR}

update_ucli:
	echo run> ucli.do;

compile_ip: compile_ip_cmd

compile_tb: compile_tb_cmd

elab: elab_cmd

sim: set_sim update_ucli sim_cmd

sim_d: set_sim update_ucli sim_d_cmd

sim_g: set_sim sim_g_cmd

compile_dtl_ip: compile_dtl_ip_cmd

compile_dtl_restore_tb: compile_dtl_restore_tb_cmd

compile_dtl_save_tb: compile_dtl_save_tb_cmd

elab_dtl_save: elab_dtl_save_cmd

elab_dtl_restore: elab_dtl_restore_cmd

sim_dtl_save_d: set_sim update_ucli sim_dtl_save_d_cmd

sim_dtl_restore_d: set_sim update_ucli sim_dtl_restore_d_cmd

sim_dtl_save: set_sim update_ucli sim_dtl_save_cmd

sim_dtl_restore: set_sim update_ucli sim_dtl_restore_cmd

questa_run: set_rundir qverilog_cmd

.PHONY: clean_all set_vcs compile_ip_cmd compile_tb_cmd elab_cmd sim_cmd sim_d_cmd compile_ip compile_tb elab set_sim update_ucli sim sim_d elab_dtl_save_cmd elab_dtl_restore_cmd elab_dtl_save elab_dtl_restore compile_dtl_ip compile_dtl_ip_cmd compile_dtl_restore_tb compile_dtl_restore_tb_cmd sim_dtl_save_d_cmd sim_dtl_save_d sim_dtl_restore_d_cmd sim_dtl_restore_d compile_dtl_save_tb compile_dtl_save_tb_cmd sim_dtl_save sim_dtl_restore sim_dtl_save_cmd sim_dtl_restore_cmd questa_run qverilog_cmd set_rundir

