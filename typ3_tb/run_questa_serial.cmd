
setenv RTL_PATH $PWD/../..;
setenv TB_PATH $PWD/../typ3_tb;
sleep 3s;

clear ; perl $TB_PATH/scripts/vcs_execute.pl -cmd questa_run_d -rundir $PWD/../rundir_questa_serial_t3ip_m2s -r_path $RTL_PATH -t_path $TB_PATH -debug -clean -c_defines "+define+T3IP +define+ENABLE_2_BBS_SLICE +define+SIM_MC_RAM_INIT_W_ZERO_PARTIAL_ONLY +define+QPDS_ED_B0" -s_pargs "+CHECK_BBS_DOA +UVM_TESTNAME=cxl_base_test +seqname=cxl_m2s_self_check_seq +TEST_MC0_MC1_INCR_ADDR +num_m2s_req=3000";
#
#clear ; perl $TB_PATH/scripts/vcs_execute.pl -cmd questa_run_d -rundir $PWD/../rundir_questa_serial_t3ip_io -r_path $RTL_PATH -t_path $TB_PATH -debug -clean -c_defines "+define+T3IP +define+ENABLE_2_BBS_SLICE +define+SIM_MC_RAM_INIT_W_ZERO_PARTIAL_ONLY +define+QPDS_ED_B0" -s_pargs "+UVM_TESTNAME=cxl_base_test +seqname=cxl_io_seq +num_io_req=10 +TEST_INCR_ADDR";
#
