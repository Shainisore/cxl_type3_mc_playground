
setenv RTL_PATH $PWD/../..;
setenv TB_PATH $PWD/../typ3_tb;
sleep 3s;

clear ; perl $TB_PATH/scripts/vcs_execute.pl -cmd run_full_dtl_save_d -rundir $PWD/../rundir_vcs_pipe_dtl_t3ip -r_path $RTL_PATH -t_path $TB_PATH -debug -clean -c_defines "+define+T3IP +define+ENABLE_2_BBS_SLICE +define+CXL_PIPE_MODE +define+SIM_MC_RAM_INIT_W_ZERO_PARTIAL_ONLY +define+QPDS_ED_B0 +define+RTILE_PIPE_MODE +define+RTILE_BYPASS_PHY" -s_pargs "+UVM_TESTNAME=cxl_base_test" -simdir_n sim_save;

perl $TB_PATH/scripts/vcs_execute.pl -cmd tb_comp_dtl_restore -rundir $PWD/../rundir_vcs_pipe_dtl_t3ip -r_path $RTL_PATH -t_path $TB_PATH -debug -c_defines "+define+T3IP +define+ENABLE_2_BBS_SLICE +define+CXL_PIPE_MODE +define+SIM_MC_RAM_INIT_W_ZERO_PARTIAL_ONLY +define+QPDS_ED_B0 +define+RTILE_PIPE_MODE +define+RTILE_BYPASS_PHY";
perl $TB_PATH/scripts/vcs_execute.pl -cmd elab_dtl_restore -rundir $PWD/../rundir_vcs_pipe_dtl_t3ip -r_path $RTL_PATH -t_path $TB_PATH -debug -c_defines "+define+T3IP +define+ENABLE_2_BBS_SLICE +define+CXL_PIPE_MODE +define+SIM_MC_RAM_INIT_W_ZERO_PARTIAL_ONLY +define+QPDS_ED_B0 +define+RTILE_PIPE_MODE +define+RTILE_BYPASS_PHY";

perl $TB_PATH/scripts/vcs_execute.pl -cmd sim_dtl_restore_d -rundir $PWD/../rundir_vcs_pipe_dtl_t3ip -r_path $RTL_PATH -t_path $TB_PATH -debug -s_pargs "+CHECK_BBS_DOA +UVM_TESTNAME=cxl_base_test +seqname=cxl_m2s_self_check_seq +TEST_MC0_MC1_INCR_ADDR +num_m2s_req=10000 +dtl_add_pkg=$PWD/../rundir_vcs_pipe_dtl_t3ip/tb_tar_child_dtl_dir:TB_DTL_LIB.tb_tar_child_dtl_pkg" -simdir_n sim_m2s_dtl &;
perl $TB_PATH/scripts/vcs_execute.pl -cmd sim_dtl_restore_d -rundir $PWD/../rundir_vcs_pipe_dtl_t3ip -r_path $RTL_PATH -t_path $TB_PATH -debug -s_pargs "+UVM_TESTNAME=cxl_base_test +seqname=cxl_io_seq +num_io_req=1 +TEST_INCR_ADDR +dtl_add_pkg=$PWD/../rundir_vcs_pipe_dtl_t3ip/tb_tar_child_dtl_dir:TB_DTL_LIB.tb_tar_child_dtl_pkg" -simdir_n sim_io_dtl &;
