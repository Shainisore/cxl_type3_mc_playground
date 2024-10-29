//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_tb_env.sv 
// Date Created    : Tue 23 November 2021
//--------------------------------------------------------------------------------
// Description  :
//     
//    CXL_TB Env setup extended from Avery BFM base Env.  
//    Steps:
//        1. AVERY PCIE ROOT COMPLEX(apci_rc) created and sequencer is connected
//           along with the root complex interface from the TB TOP.
//        2. apci_rc callback function used to define the Device Memory Address Range.
//
//--------------------------------------------------------------------------------
// Version Map     :
//   -----------------------------
//    Version             : 1.1
//    Version Information : 
//       1. Updated Expected Error list for Demoter.
//
//   -----------------------------
//    Version             : 1.0
//    Version Information : 
//       1. Initial Version.
//
//--------------------------------------------------------------------------------

`ifndef CXL_TB_ENV__SV
`define CXL_TB_ENV__SV

    //--------------------------------------------------------------------------------
    // Import AVERY PCIE UVM Package 
    //--------------------------------------------------------------------------------
    import uvm_pkg::*;
    import apci_uvm_pkg::*;
    import apci_pkg::*;
    `include "uvm_macros.svh"
    
    //--------------------------------------------------------------------------------
    // AVERY Error demoter
    //--------------------------------------------------------------------------------
    class err_demoter extends uvm_report_catcher;
        bit         avery_err_demoted;
        string      msg_actual;
        string      msg_expected1;
        string      msg_expected2;
        string      msg_expected3;
        string      msg_expected4;
        string      msg_expected5;

        `uvm_object_utils(err_demoter)
    
        //----------------------------------------------------
        // New
        //----------------------------------------------------
        function new(string name="err_demoter");
            super.new(name);
        endfunction : new
       
        //----------------------------------------------------
        // Function: catch 
        //----------------------------------------------------
        function action_e catch();

            if(get_severity() == UVM_ERROR) begin : SEVERITY_CHECK
                msg_actual = get_message();
                
                //Note: Error Type - 1  //RNR_A0
                msg_expected1 = "Peer shall return same PCIe Enable";
                //Note: Error Type - 2,3 //RNR_A0
                msg_expected2 = "could not locate mandatory capability structure of APCI_CAP_pcie for rcrb_";
                //Note: Error Type - 4 //RNR_A0
                msg_expected3 = "Received a bogus Data Chunck at slot";
                //Note: Error Type - 5 //EQ-BYPS
                msg_expected4 = "Check if peer noted the TxPreset correctly during the most recent transition to";
                //Note: Error Type - 6 //RCiEP register related
                msg_expected5 = "PCIe capability of func_aa_0_0 should be APCI_PORT_rc_ie in CXL 1.1 enumeration";

                if((!uvm_re_match(msg_expected1,msg_actual)) || 
                   (!uvm_re_match(msg_expected2,msg_actual)) ||
                   (!uvm_re_match(msg_expected3,msg_actual)) || 
                   (!uvm_re_match(msg_expected4,msg_actual)) ||
                   (!uvm_re_match(msg_expected5,msg_actual))) begin : MSG_STR_CHECK
                    set_severity(UVM_INFO);
                    avery_err_demoted = 1;
                end : MSG_STR_CHECK
            end : SEVERITY_CHECK

            return THROW;

        endfunction : catch

    endclass : err_demoter

    //--------------------------------------------------------------------------------
    // CXL_TB Env
    //--------------------------------------------------------------------------------
    class cxl_tb_env extends uvm_env;

        apci_device             apci_rc; 
        err_demoter             avy_err_demoter;
        apci_uvm_virtual_seqr   vseqr0; //Note: the virtual sequencer
    
        `uvm_component_utils(cxl_tb_env)
    
        //----------------------------------------------------
        // Externally defined method list 
        //----------------------------------------------------
        extern function new(string name, uvm_component parent);
        extern virtual function void build_phase(uvm_phase phase);
        extern virtual function void connect_phase(uvm_phase phase);
        extern virtual task run_phase(uvm_phase phase);
    
    endclass : cxl_tb_env
    
    //--------------------------------------------------------------------------------
    // New
    //--------------------------------------------------------------------------------
    function cxl_tb_env::new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    //--------------------------------------------------------------------------------
    // Build Phase
    //--------------------------------------------------------------------------------
    function void cxl_tb_env::build_phase(uvm_phase phase);
    
        `uvm_info(get_full_name(), $sformatf("Build Phase Entered!!"), UVM_MEDIUM)
        super.build_phase(phase);
    
        apci_rc = apci_device::type_id::create("apci_rc", this);
        apci_rc.set("dev_type", APCI_DEVICE_rc);
        vseqr0 = apci_uvm_virtual_seqr::type_id::create("vseqr0", this);
        avy_err_demoter = err_demoter::type_id::create("avy_err_demoter",this);

        uvm_config_db#(apci_device)::set(uvm_root::get(), "*", "apci_rc", apci_rc);
        `uvm_info(get_full_name(), $sformatf("Build Phase Completed!!"), UVM_MEDIUM)
        
    endfunction : build_phase
    
    //--------------------------------------------------------------------------------
    // Connect Phase
    //--------------------------------------------------------------------------------
    function void cxl_tb_env::connect_phase(uvm_phase phase);
        bit ok;
        string s;
        int n_lanes;
        virtual apci_pipe_intf rc_pif[];
    
        `uvm_info(get_full_name(), $sformatf("Connect Phase Entered!!"), UVM_MEDIUM)
        ok = uvm_config_db#(int)::get(uvm_root::get(), "*", "num_lanes", n_lanes);
        if (!ok)
            `uvm_fatal(get_full_name(), "Testbench module shall pass in num_lanes");
    
        rc_pif = new[n_lanes];
        for (int i = 0; i < n_lanes; i++) begin
            s  = $psprintf("rc_pif[%0d]", i);
            ok = uvm_config_db#(virtual apci_pipe_intf)::get(uvm_root::get(), "*", s, rc_pif[i]);
            if (!ok || rc_pif[i] == null)
                `uvm_fatal("", $psprintf("virtual interface rc_pif[%0d] is NOT passed in from testbench top properly", i))
        end
    
        apci_rc.assign_vi(0, rc_pif);
        if (apci_pkg_test::test_log.dbg_flag[APCI_DBG_uvm])
            apci_rc.print();
    
        vseqr0.rc_app_bfm_seqr = apci_rc.sequencer;
        vseqr0.bfm_seqr = apci_rc.sequencer;
        vseqr0.seqrs.push_back(apci_rc.sequencer);
        
        `uvm_info(get_full_name(), $sformatf("Connect Phase Completed!!"), UVM_MEDIUM)
    
    endfunction : connect_phase
    
    //--------------------------------------------------------------------------------
    // Run Phase 
    //--------------------------------------------------------------------------------
    task cxl_tb_env::run_phase(uvm_phase phase);
    
        uvm_report_cb::add(null,avy_err_demoter);

        `uvm_info(get_full_name(), $sformatf("Run Phase Entered!!"), UVM_MEDIUM)
        super.run_phase(phase);
    
        `uvm_info(get_full_name(), $sformatf("Before BFM Started"), UVM_MEDIUM)
        apci_rc.wait_event("bfm_started");
        `uvm_info(get_full_name(), $sformatf("After BFM Started"), UVM_MEDIUM)
    
        `uvm_info(get_full_name(), $sformatf("Run Phase Completed!!"), UVM_MEDIUM)
    
    endtask : run_phase

`endif//CXL_TB_ENV__SV
