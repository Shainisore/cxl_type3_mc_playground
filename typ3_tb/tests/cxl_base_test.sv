//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_base_test.sv 
// Date Created    : Wed 24 November 2021
//--------------------------------------------------------------------------------
// Description  :
//     
//    CXL_Base Test using the Avery BFM to initiate M2S/S2M Traffic 
//    Steps:
//        1. Creates the Base ENV defined for this TB Setup.
//        2. Waits for the AVERY BFM Devices collection which happens after the 
//           Enumeration complete.
//        3. Execute the sequence picked from the elaborated sequences based on
//           on the sequence name passed from the command-line as "+seqname=<>"
//
//--------------------------------------------------------------------------------
// Version Map     :
//   -----------------------------
//    Version             : 1.1
//    Version Information : 
//       1. Added Idle->Busy->Idle Checks.
//       2. Added EOT checks for analyzing STATUS Register.
//
//   -----------------------------
//    Version             : 1.0
//    Version Information : 
//       1. Initial Version.
//
//--------------------------------------------------------------------------------

`ifndef CXL_BASE_TEST__SV
`define CXL_BASE_TEST__SV

    //---------------------------------------------------------------------------
    // CXL_BASE_TEST Definition
    //---------------------------------------------------------------------------
    class cxl_base_test extends uvm_test;
    
        `uvm_component_utils(cxl_base_test)
        
        //----------------------------------------
        // Global Decalartions
        //----------------------------------------
        apci_device         bfm;
        apci_device_mgr     mgrs[$];
        cxl_tb_env          env0;
        uvm_table_printer   printer;
        uvm_report_server   reporter = uvm_report_server::get_server();
        int                 num_max_quit_count; 
        int                 seq_timeout;

        static bit          CAFU_BUSYtoIDLE;
        `ifndef BASE_IP
        static bit          BBS_BUSYtoIDLE;
        `endif
        
        //----------------------------------------
        // New
        //----------------------------------------
        function new( string name = "cxl_base_test", uvm_component parent=null );
            super.new(name, parent);
        endfunction : new
        
        //----------------------------------------
        // Build Phase 
        //----------------------------------------
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            //Note: logs* in case for multiple root ports
            uvm_config_db#(bit)::set(this, "env0.apci_rc.log*" , "enable_cfg_tracker" , 1);
            uvm_config_db#(bit)::set(this, "env0.apci_rc.log*" , "enable_tl_tracker"  , 1);
            uvm_config_db#(bit)::set(this, "env0.apci_rc.log*" , "enable_dll_tracker" , 1);
            uvm_config_db#(bit)::set(this, "env0.apci_rc.log*" , "enable_phy_tracker" , 1);
            
            env0 = cxl_tb_env::type_id::create("env0", this);
            
            if(!$value$plusargs("SEQ_TIMEOUT=%d",seq_timeout))
                seq_timeout = 1500;
            
            if(!$value$plusargs("UVM_MAX_QUIT_COUNT=%d",num_max_quit_count)) begin
                num_max_quit_count = 100;
            end

            reporter.set_max_quit_count(num_max_quit_count);
        endfunction : build_phase
        
        //----------------------------------------
        // Connect Phase
        //----------------------------------------
        virtual function void connect_phase(uvm_phase phase);
            //Note: bring BFM handles to testbench top module
            uvm_config_db#(apci_device)::set(uvm_root::get(), "*", "apci_rc", env0.apci_rc);
        endfunction : connect_phase
        
        //----------------------------------------
        // End of Elab Phase
        //----------------------------------------
        virtual function void end_of_elaboration_phase(uvm_phase phase);
            printer = new();
            printer.knobs.depth = 4;
    
            //Note: print the uvm hierarchy
            `uvm_info(get_full_name(), $psprintf("The Test Topology:\n%s", this.sprint(printer)), UVM_HIGH);
        endfunction : end_of_elaboration_phase
        
        //----------------------------------------
        //Start of sim Phase
        //----------------------------------------
        virtual function void start_of_simulation_phase(uvm_phase phase);
            this.check_config_usage(1); //Note: uvm_component method
        endfunction : start_of_simulation_phase
        
        //----------------------------------------
        // Run Phase
        //----------------------------------------
        virtual task run_phase(uvm_phase phase);
    
            phase.raise_objection(this);
    
            `uvm_info(get_full_name(), $sformatf("Run Phase Started!!"), UVM_MEDIUM);
            super.main_phase(phase);

            bfm = env0.apci_rc.sequencer.bfm;   

            bfm.wait_event("bfm_started", 1e9);

            if($test$plusargs("AVERY_PERF_MODE"))
            begin : AVERY_PERF_MODE
                env0.apci_rc.sequencer.bfm.cfg_info.max_performance = 1;
                env0.apci_rc.port_set_ifc(-1, 0, APCI_FC_ph  , (0) );
                env0.apci_rc.port_set_ifc(-1, 0, APCI_FC_pd  , (0) );
                env0.apci_rc.port_set_ifc(-1, 0, APCI_FC_nph , (0) );
                env0.apci_rc.port_set_ifc(-1, 0, APCI_FC_npd , (0) );
                env0.apci_rc.port_set_ifc(-1, 0, APCI_FC_cplh, (0) );
                env0.apci_rc.port_set_ifc(-1, 0, APCI_FC_cpld, (0) );
                env0.apci_rc.port_set_ufc(-1, 0, APCI_FC_ph  , 1, (100) , (0));
                env0.apci_rc.port_set_ufc(-1, 0, APCI_FC_pd  , 1, (2040) , (0));
                env0.apci_rc.port_set_ufc(-1, 0, APCI_FC_nph , 1, (100) , (0));
                env0.apci_rc.port_set_ufc(-1, 0, APCI_FC_npd , 1, (2040) , (0));
                env0.apci_rc.port_set_ufc(-1, 0, APCI_FC_cplh, 1, (100) , (0));
                env0.apci_rc.port_set_ufc(-1, 0, APCI_FC_cpld, 1, (2040) , (0));
                env0.apci_rc.cxl_port_set_ifc(0, ACXL_FC_cache_req , 1023);
                env0.apci_rc.cxl_port_set_ifc(0, ACXL_FC_cache_data, 1023);
                env0.apci_rc.cxl_port_set_ifc(0, ACXL_FC_cache_rsp , 1023);
                env0.apci_rc.cxl_port_set_ifc(0, ACXL_FC_mem_rsp   , 1023);
                env0.apci_rc.cxl_port_set_ifc(0, ACXL_FC_mem_data  , 1023);
                `uvm_info(get_name(), "Enabled the Perf Mode settings", UVM_NONE)
            end : AVERY_PERF_MODE

            if (bfm.get("dev_type") != APCI_DEVICE_rc)
              `uvm_fatal(get_full_name(), $psprintf("acxl_m2s_self_check: device type %0h is not APCI_DEVICE_rc", bfm.get("dev_type")));

            //Note: Since the device is not supporting meta value
            env0.apci_rc.cxl_port_set(-1,"meta_value_sup", 0);
    
            `ifdef CXL_PIPE_MODE
               //Note: For AVY_ERR [APCI4_2_6_4_2_2_3n4] DUT must continuously request for at least 1000ns, but it only request for 896ns
               bfm.cfg_info.dut_recov_equal_rxeq_cont_requested = 800ns;
               //Note: Configure VDR register 
               cxl_tb_top.mpipe_box.b_phy.set_vda_in_p2m(12'hC00);
            `endif
            //Note: Wait for BUS ENUM done
            `uvm_info(get_name(), " wait for PCIe/CXL enumeration done ...", UVM_MEDIUM);
            bfm.collect_devices(-1, mgrs);

            `ifdef TB_DTL_MODE
               //Note: DTL : invoke save snapshot
               force cxl_tb_top.start_save = 1;  
               #1ns;
               `uvm_info(get_full_name(), $sformatf("DEBUG: save snspshot completed  !!"), UVM_MEDIUM);
               #1ns;
            `endif

            fork
                begin : SEQ_EXE_WITH_CHECKS
                    fork
                        begin : EXE_SEQ
                            `uvm_info(get_full_name(), $sformatf("Start of Running sequence !!"), UVM_NONE)
                            exe_cmdline_seq();
                            `uvm_info(get_full_name(), $sformatf("End of Running sequence !!"), UVM_NONE)

                            //Note: Drain time
                            #10us;
                        end : EXE_SEQ
                        begin : ENGINE_BUSY_CHECKS
                            `uvm_info(get_full_name(), $sformatf("Start of Running Engine Busy Checks!!"), UVM_NONE)

                            fork
                                if($test$plusargs("CHECK_CAFU_DOA"))
                                begin : CAFU_BUSY_CHECKS
                                    `ifdef BASE_IP
                                        `CXL_TB_DO_CAFU_BUSY_CHECKS(cxl_tb_top.dut.ed_top_wrapper_baseip)
                                    `elsif T1IP
                                        `CXL_TB_DO_CAFU_BUSY_CHECKS(cxl_tb_top.dut.ed_top_wrapper_typ1_inst)
                                    `elsif T2IP
                                        `CXL_TB_DO_CAFU_BUSY_CHECKS(cxl_tb_top.dut.ed_top_wrapper_typ2_inst)
                                    `endif
                                end : CAFU_BUSY_CHECKS

                                if($test$plusargs("CHECK_BBS_DOA"))
                                begin : BBS_BUSY_CHECKS
                                    `ifndef BASE_IP
                                        `ifndef REPO
                                            `ifdef BASE_IP
                                                `CXL_TB_DO_BBS_BUSY_CHECKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top)
                                            `elsif T1IP
                                                `CXL_TB_DO_BBS_BUSY_CHECKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top)
                                            `elsif T2IP
                                                `CXL_TB_DO_BBS_BUSY_CHECKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top)
                                            `elsif T3IP
                                                `CXL_TB_DO_BBS_BUSY_CHECKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top)
                                            `endif
                                        `else
                                            `ifdef BASE_IP
                                                `CXL_TB_DO_BBS_BUSY_CHECKS(cxl_tb_top.dut.cxl_baseip_top)
                                            `elsif T1IP
                                                `CXL_TB_DO_BBS_BUSY_CHECKS(cxl_tb_top.dut.cxl_type1_cxlip_top)
                                            `elsif T2IP
                                                `CXL_TB_DO_BBS_BUSY_CHECKS(cxl_tb_top.dut.cxl_type2_cxlip_top)
                                            `elsif T3IP
                                                `CXL_TB_DO_BBS_BUSY_CHECKS(cxl_tb_top.dut.cxl_type3_top_inst)
                                            `endif
                                        `endif
                                    `endif
                                end : BBS_BUSY_CHECKS
                            join

                            `uvm_info(get_full_name(), $sformatf("End of Running Engine Busy Checks!!"), UVM_NONE)
                        end : ENGINE_BUSY_CHECKS
                    join
                end : SEQ_EXE_WITH_CHECKS
                begin : SEQ_TIMEOUT
                    #(1us * seq_timeout);
                    `uvm_fatal("CXL_REPORT", $sformatf("Sequence is running for %0dus! Probable timeout or else increase the timeout by simulation plusargs \"+SEQ_TIMEOUT=<number in us>\" from the cmd-line",seq_timeout))
                end : SEQ_TIMEOUT
            join_any
            disable fork;
    
            #1ns;
    
            `uvm_info(get_full_name(), $sformatf("Run Phase ends!!"), UVM_MEDIUM);
    
            phase.drop_objection(this);
        endtask : run_phase
        
        //----------------------------------------
        // Report Phase
        //----------------------------------------
        virtual function void report_phase(uvm_phase phase);
            int  cnt1 = reporter.get_severity_count(UVM_ERROR);
            int  cnt2 = reporter.get_severity_count(UVM_FATAL);
            
            super.report();
            
            if (cnt1 || cnt2) begin
                `uvm_info("CXL_REPORT",$psprintf("Test failed due to UVM_ERROR=%0d and UVM_FATAL=%0d", cnt1, cnt2), UVM_NONE); 
            end else begin
                `uvm_info("CXL_REPORT",$psprintf("Test Passed as no UVM_ERROR/UVM_FATAL reported. UVM_ERROR=%0d and UVM_FATAL=%0d", cnt1, cnt2), UVM_NONE); 
            end
            
        endfunction : report_phase
    
        //----------------------------------------
        // Check Phase
        //----------------------------------------
        virtual function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            
            //Note: Call End of test checks Macro by passing the CXL IP Hierarchy
            `ifndef REPO
                `ifdef BASE_IP
                    `CXL_TB_DO_EOT_CHECKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxlip_top, cxl_tb_top.dut.ed_top_wrapper_baseip)
                `elsif T1IP
                    `CXL_TB_DO_EOT_CHECKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.cxl_type1_cxlip_top, cxl_tb_top.dut.ed_top_wrapper_typ1_inst)
                `elsif T2IP
                    `CXL_TB_DO_EOT_CHECKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type2_top, cxl_tb_top.dut.ed_top_wrapper_typ2_inst)
                `elsif T3IP
                    `CXL_TB_DO_EOT_CHECKS(cxl_tb_top.dut.intel_rtile_cxl_top_inst.intel_rtile_cxl_top_0.inst_cxl_type3_top, cxl_tb_top.dut.ed_top_wrapper_typ3_inst)
                `endif
            `else
                `ifdef BASE_IP
                    `CXL_TB_DO_EOT_CHECKS(cxl_tb_top.dut.cxl_baseip_top, cxl_tb_top.dut.ed_top_wrapper_baseip)
                `elsif T1IP
                    `CXL_TB_DO_EOT_CHECKS(cxl_tb_top.dut.cxl_type1_cxlip_top, cxl_tb_top.dut.ed_top_wrapper_typ1_inst)
                `elsif T2IP
                    `CXL_TB_DO_EOT_CHECKS(cxl_tb_top.dut.cxl_type2_cxlip_top, cxl_tb_top.dut.ed_top_wrapper_typ2_inst)
                `elsif T3IP
                    `CXL_TB_DO_EOT_CHECKS(cxl_tb_top.dut.cxl_type3_top_inst, cxl_tb_top.dut.ed_top_wrapper_typ3_inst)
                `endif
            `endif

            if($test$plusargs("CHECK_CAFU_DOA"))
                if(CAFU_BUSYtoIDLE == 0)
                    `uvm_error("CXL_REPORT", $sformatf("C-AFU was never busy; no traffic is pushed through C-AFU"))

            `ifndef BASE_IP
                if($test$plusargs("CHECK_BBS_DOA"))
                    if(BBS_BUSYtoIDLE == 0)
                        `uvm_error("CXL_REPORT", $sformatf("DCOH was never busy; no traffic is pushed through DCOH"))
            `endif

        endfunction : check_phase
    
        //----------------------------------------
        // Execute the Commandline Sequence
        //----------------------------------------
        virtual task exe_cmdline_seq();
    
            uvm_object tmp_object;
            uvm_factory m_factory;
            uvm_sequence #(apci_data_base) exec_seq;
    
            string seq_name;
    
            m_factory = uvm_factory::get();
    
            if($value$plusargs("seqname=%s", seq_name)) begin 
                `uvm_info(get_full_name(), $sformatf("Sequence Name = %s",seq_name), UVM_MEDIUM)   
                tmp_object = m_factory.create_object_by_name(seq_name);
                assert($cast(exec_seq,tmp_object));
                exec_seq.start(env0.apci_rc.sequencer,null);
            end
            `ifndef TB_DTL_MODE
                else begin
                    `uvm_error("", $psprintf("There is no sequence from command line, please review run command"));
                end
            `endif
        endtask : exe_cmdline_seq
    
    endclass : cxl_base_test

`endif//CXL_BASE_TEST__SV
