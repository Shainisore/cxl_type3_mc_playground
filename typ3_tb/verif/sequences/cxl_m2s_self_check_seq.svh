//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_m2s_self_check_seq.svh 
// Date Created    : Wed 24 November 2021
//--------------------------------------------------------------------------------
// Description  :
//     
//    CXL_M2S Traffic generation sequence and does Data integrity check. 
//    Sequence flow:
//        1. Gets the Device Memory Address ranges which should be updated as part
//           of Enumeration process in the BFM.
//        2. Selects a number of traffic which needs to be exercised for this seq.
//        3. Initiate the AVERY BFM to start M2S Write followed by Read Accesses.
//        4. The read data and write data will be compared and reported.
//
//--------------------------------------------------------------------------------
// Version Map     :
//
//   -----------------------------
//    Version             : 1.2
//    Version Information : 
//       1. Updated for CFG_IP/ QHIP_MIRROR_IP support.
//
//   -----------------------------
//    Version             : 1.1
//    Version Information : 
//       1. Added Cmdline options for MC0/1 Selection.
//
//   -----------------------------
//    Version             : 1.0
//    Version Information : 
//       1. Initial Version.
//
//--------------------------------------------------------------------------------

`ifndef CXL_M2S_SELF_CHECK_SEQ__SVH
`define CXL_M2S_SELF_CHECK_SEQ__SVH

    //--------------------------------------------------------------------------------
    // Base UVM Package
    //--------------------------------------------------------------------------------
    import uvm_pkg::*;
    
    //--------------------------------------------------------------------------------
    // CXL_M2S_SELF_CHECK_SEQ Class Definition 
    //--------------------------------------------------------------------------------
    class cxl_m2s_self_check_seq extends uvm_sequence #(apci_data_base);
    
        int                     num_m2s_req;

        `uvm_declare_p_sequencer(apci_uvm_seqr)
    
        `uvm_object_utils_begin(cxl_m2s_self_check_seq)
        `uvm_object_utils_end
        
        //--------------------------------------------------------------------------------
        // New 
        //--------------------------------------------------------------------------------
        function new (string name="cxl_m2s_self_check_seq");
            super.new(name);
        endfunction : new
        
        //--------------------------------------------------------------------------------
        // Body
        //--------------------------------------------------------------------------------
        virtual task body();
            apci_device         bfm;  
            acxl_msg            m_wr,all_m2s_wr[$], c_mwr;
            acxl_msg            m_rd,all_m2s_rd[$], c_mrd;
            apci_device_mgr     mgrs[$];
            apci_bar_t          mbar = 0;
            apci_bar_t          pf_bar_base[][][];
            apci_addr_range_t   ranges[$];
            apci_transaction    tr, all_trs[$];
            
            bit [63:0]          bbs_dfccfg_addr;
            bit [63:0]          wdata, rdata;
            bit                 address_obtained;
            bit [63:0]          first_be2 = 4'hf;
            bit                 ok, is_hdm0;
            bit [51:0]          address, address_q[$];
            int                 num_element[$];
            int                 num_m2s_req;
            int                 indexes[$], idx0;
            
            bfm = p_sequencer.bfm;   

            `uvm_info("CXL_REPORT", $psprintf("M2S/S2M Traffic Self Check Sequence starts!"), UVM_NONE);
            
            //Note: Check that CXL mode was enabled through linkup process
            if (bfm.port_get(0, "cxl_mode_active") == 0) begin : CXL_MODE_ACTIVE
                `uvm_error("", $psprintf("Link is not operating in CXL mode"));
                return;
            end : CXL_MODE_ACTIVE
            
            //Note: Get Device mem ranges
            bfm.get_cxl_hdm_ranges(ranges);
            if (ranges.size == 0) begin : HDM_RANGE_CHECK
              `ifdef QHIP_MIRROR_CFG
                `uvm_info("CXL_REPORT", $psprintf("There are no CXL HDM ranges"), UVM_NONE);
              `else
                `uvm_error("CXL_REPORT", $psprintf("There are no CXL HDM ranges"));
              `endif
                return;
            end : HDM_RANGE_CHECK
            
            //Note: Define the M2S Request count, if not passed from cmd-line.
            if(!$value$plusargs("num_m2s_req=%0d",num_m2s_req))
                num_m2s_req = 30;
            
            `ifdef OOO_SUPPORT
                begin : CFG_OOO_RESP
                    bfm.collect_devices(-1, mgrs);
                    
                    foreach (mgrs[i])
                    begin : MGRS
                        if (mgrs[i].dev_type inside {APCI_DEVICE_ep, APCI_DEVICE_legacy_ep})
                        begin : DEV_EP_T
                            apci_func_info f = mgrs[i].finfs[0];
                            mbar = f.mem_ranges[0];
                            pf_bar_base[i][0][0]= mbar.base;
                            bbs_dfccfg_addr = mbar.base + 'h1048;
                            `uvm_info("CXL_REPORT", $psprintf("Selected Address = %x", bbs_dfccfg_addr), UVM_NONE)
                        end : DEV_EP_T
                    end : MGRS

                    `uvm_create(tr)
                    ok = tr.randomize() with {
                        addr        == (mgrs[1].finfs[0].mem_ranges[0].base + 'h1048);
                        length      == 1;
                        proc_hint   == 0;
                        tc          == 0;
                        is_write    == 0;
                        kind        == APCI_TRANS_mem;
                    };
                    assert(ok) else `uvm_fatal("CXL_REPORT", "randomization failed");
                    `uvm_send(tr);
                    all_trs.push_back(tr);
                    
                    //Note: Wait for RD done
                    `uvm_info("CXL_REPORT", $psprintf("MEM RD TLP issued for ADDR:0x%0h; Waiting for TXN Completion", (mgrs[1].finfs[0].mem_ranges[0].base + 'h1048)), UVM_NONE)
                    tr.wait_done(1e9);
                    if (tr.err_code != apci_transaction::OK)
                        `uvm_error("CXL_REPORT", $psprintf("Transaction failed with %s", tr.err_code.name))
                    else
                    begin
                        `uvm_info("CXL_REPORT", $psprintf("Transaction succeeded with %s", tr.err_code.name), UVM_NONE)
                        foreach(tr.payload[m])
                        begin
                            rdata = tr.payload[m];
                            `uvm_info("CXL_REPORT", $psprintf("ADDRESS:0x%0h, RDATA:0x%0h",(mgrs[1].finfs[0].mem_ranges[0].base + 'h1048),rdata), UVM_NONE)
                        end
                    end

                    //Note: Initiate WR Op
                    `uvm_create(tr)
                    ok = tr.randomize() with {
                        addr        == (mgrs[1].finfs[0].mem_ranges[0].base + 'h1048);
                        length      == 1;
                        proc_hint   == 0;
                        tc          == 0;
                        is_write    == 1;
                        kind        == APCI_TRANS_mem;
                    };
                    assert(ok) else `uvm_fatal("CXL_REPORT", "randomization failed");
                    wdata = rdata | 7'b100_0000;
                    tr.payload.push_back(wdata);
                    `uvm_send(tr);
                    all_trs.push_back(tr);  
                    
                    //Note: wait for WR done
                    `uvm_info("CXL_REPORT", $psprintf("MEM WR TLP issued for ADDR:0x%0h; Waiting for TXN Completion", (mgrs[1].finfs[0].mem_ranges[0].base + 'h1048)), UVM_NONE)
                    tr.wait_done(1e9);
                    if (tr.err_code != apci_transaction::OK)
                        `uvm_error("CXL_REPORT", $psprintf("Transaction failed with %s", tr.err_code.name))

                end : CFG_OOO_RESP
            `endif

            //Note: Pick an address
            for (int m = 0; m < num_m2s_req; m++) begin : ADDRESS_SELECTION
                address_obtained = 0;
                
                while(address_obtained == 0) begin : ADDRESS_GRABBER
                    //Note: Address selection - Incremental or Random
                    if($test$plusargs("TEST_INCR_ADDR")) begin
                        if(m==0)
                            address  = ranges[0].base;
                        else
                            address  = address + 1024;
                    end else if($test$plusargs("TEST_MC0_MC1_INCR_ADDR")) begin
                        if(m==0)
                            address  = ranges[0].base;
                        else
                            address  = address + 64;
                    end else if($test$plusargs("TEST_MC0_INCR_ADDR")) begin
                        if(m==0)
                            address  = ranges[0].base;
                        else
                            address  = address + 128;
                    end else if($test$plusargs("TEST_MC1_INCR_ADDR")) begin
                        if(m==0)
                            address  = ranges[0].base + 64;
                        else
                            address  = address + 128;
                    end else begin
                        std::randomize(address) with { address  >= ranges[0].base; address <= ranges[0].base+ ranges[0].len -1;};
                    end
                    
                    address[5:0] = '0;
                    num_element = address_q.find_index with (item == address);
                    if(num_element.size() == 0) begin : ADDRESS_Q
                        address_q[m] = address;
                        address_obtained = 1;
                        `uvm_info("CXL_REPORT", $psprintf("Address = %x Address_51_6 = %x Address_51_5 = %x is for %0d", address, address[51:6], address[51:5], m), UVM_MEDIUM);
                    end : ADDRESS_Q 
                end : ADDRESS_GRABBER
            end : ADDRESS_SELECTION
            
            //Note: M2S write
            begin : M2S_WRITE_STARTS
                int         wr_random_val;
                bit [51:0]  wr_address;
                acxl_msg    m_wr_da[];
    
                m_wr_da = new [num_m2s_req];
    
                for (int n=0; n < num_m2s_req; n++) begin : M2S_WRITE_REQ_NUM 
                    m_wr_da[n] = new();
                    wr_address = address_q[n];
                    m_wr_da[n].kind = ACXL_MSG_m2s_reqdata;
                    wr_random_val = $urandom_range(1,2);
    
                    if(wr_random_val == 1)
                        m_wr_da[n].u.m2s_reqdata.opcode = ACXL_M2S_MemWr;
                    else 
                        m_wr_da[n].u.m2s_reqdata.opcode = ACXL_M2S_MemWrPtl;
    
                    //Note: For TYPE3, Only supported SnpType is SnpNoOp. Refer CXL2.0/Appendix B/Table315
                    //      So, set the target type for the acxl msg
                    m_wr_da[n].target_type3 = 1;
    
                    m_wr_da[n].bytes = new[64];
                    foreach (m_wr_da[n].bytes[i])
                        m_wr_da[n].bytes[i] = $urandom;

                    if(m_wr_da[n].u.m2s_reqdata.opcode == ACXL_M2S_MemWrPtl)
                        m_wr_da[n].be = $urandom;
                    else
                        m_wr_da[n].be = -1;
                    m_wr_da[n].u.m2s_reqdata.addr51_6 = wr_address[51:6];
                    m_wr_da[n].u.m2s_reqdata.tag =  n;
                    bfm.inject_cxl_msg("tx_bypass_coh", m_wr_da[n], 0);
                    all_m2s_wr.push_back(m_wr_da[n]);
                end : M2S_WRITE_REQ_NUM
                `uvm_info("CXL_REPORT", $psprintf("At the end of Writes"), UVM_NONE);
            end : M2S_WRITE_STARTS
            
            //Note: Wait for Write threads to be done
            for(int t= 0; t < num_m2s_req; t++) begin : M2S_WRITE_THREAD_WAIT
                `uvm_info("CXL_REPORT", $psprintf("Waiting for Write transaction %0d", t), UVM_NONE);
                all_m2s_wr[t].wait_done(1e9, $psprintf("%m"));
            end : M2S_WRITE_THREAD_WAIT
            `uvm_info("CXL_REPORT", $psprintf("Write transactions wait done!"), UVM_LOW);
            
            //Note: M2S Read
            begin : M2S_READ_STARTS
                int         rd_random_val;
                bit [51:0]  rd_address;
                acxl_msg    m_rd_da[];
                int         read_tag;
    
                m_rd_da = new [num_m2s_req];
    
                #200ns;
    
                for(int p=0; p < num_m2s_req; p++) begin : M2S_READ_REQ_NUM
                    read_tag = p + 'h10000;
                    m_rd_da[p] = new();
                    rd_address = address_q[p];
                    m_rd_da[p].kind = ACXL_MSG_m2s_req;
                    rd_random_val = $urandom_range(1,2);
    
                    if(rd_random_val == 1)
                        m_rd_da[p].u.m2s_req.opcode = ACXL_M2S_MemRdData;
                    else 
                        m_rd_da[p].u.m2s_req.opcode = ACXL_M2S_MemRd;
    
                    //Note: For TYPE3, Only supported SnpType is SnpNoOp. Refer CXL2.0/Appendix B/Table313
                    m_rd_da[p].u.m2s_req.metaField = ACXL_META_FIELD_no_op;
                    m_rd_da[p].u.m2s_req.snpType = ACXL_M2S_SnpNoOp;

                    m_rd_da[p].u.m2s_req.addr51_5 = rd_address[51:5];
                    m_rd_da[p].u.m2s_req.tag = read_tag;
                    bfm.inject_cxl_msg("tx_bypass_coh", m_rd_da[p], 0);
                    all_m2s_rd.push_back(m_rd_da[p]);
                end : M2S_READ_REQ_NUM 
                `uvm_info("CXL_REPORT", $psprintf("At the end of Reads"), UVM_NONE);
            end : M2S_READ_STARTS
            
            //Note: Wait for Read threads to be done
            for(int t= 0; t < num_m2s_req; t++) begin : M2S_READ_THREAD_WAIT
                `uvm_info("CXL_REPORT", $psprintf("Waiting for Read transaction %0d", t), UVM_NONE);
                all_m2s_rd[t].wait_done(1e9, $psprintf("%m"));
                all_m2s_rd[t].bytes = new[64];
    
                for(int w=0; w < 32; w++) begin
                    all_m2s_rd[t].bytes[w] = all_m2s_rd[t].rspData_msgs[0].bytes[w];  
                    `uvm_info("CXL_REPORT", $psprintf("Read Data for Transaction %0d and Byte %0d is %0h",t,w,all_m2s_rd[t].rspData_msgs[0].bytes[w]), UVM_DEBUG);
                end
    
                if(all_m2s_rd[t].rspData_msgs.size() == 1) begin
                    for(int w=32; w < 64; w++) begin
                        all_m2s_rd[t].bytes[w] = all_m2s_rd[t].rspData_msgs[0].bytes[w];  
                        `uvm_info("CXL_REPORT", $psprintf("Read Data for Transaction %0d and Byte %0d is %0h",t,w,all_m2s_rd[t].rspData_msgs[0].bytes[w]), UVM_DEBUG);
                    end
                end
    
                if(all_m2s_rd[t].rspData_msgs.size() == 2) begin
                    for(int w=32; w < 64; w++) begin
                        all_m2s_rd[t].bytes[w] = all_m2s_rd[t].rspData_msgs[1].bytes[w-32];  
                        `uvm_info("CXL_REPORT", $psprintf("Read Data for Transaction %0d and Byte %0d is %0h",t,w,all_m2s_rd[t].rspData_msgs[1].bytes[w-32]), UVM_DEBUG);
                    end
                end
            end : M2S_READ_THREAD_WAIT
            `uvm_info("CXL_REPORT", $psprintf("Read transactions wait done!"), UVM_LOW);
            
            //Note: Do the Data integrity check between the write data and readback data
            for (int t =0; t < num_m2s_req; t++) begin : M2S_DATA_INTEGRITY_CHECK 
                `ifndef OOO_SUPPORT
                    for (int i =0; i < 64; i++) begin
                        if(all_m2s_wr[t].be[i] == 1) begin
                            if(all_m2s_wr[t].bytes[i] != all_m2s_rd[t].bytes[i] ) begin
                                `uvm_error("", $psprintf("Write Data at bytes %0d all_m2s_wr[%0d] = %0h rd_data = %0h", i,t, all_m2s_wr[t].bytes[i], all_m2s_rd[t].bytes[i]));
                            end else begin
                                `uvm_info("CXL_REPORT", $psprintf("Matching Read and Write for Transaction %0d and Byte %0d",t,i), UVM_MEDIUM);
                            end
                        end
                    end
                `else
                    //Note: ReadBack can be Out of Order. So verify using TAG 
                    c_mwr = all_m2s_wr.pop_front();
                    `uvm_info("CXL_REPORT", $sformatf("Got one MRwD MSG -> %p",c_mwr.u.m2s_reqdata), UVM_NONE)
                    indexes = all_m2s_rd.find_first_index with (item.u.s2m_drs.tag == c_mwr.u.m2s_reqdata.tag);
                    `uvm_info("CXL_REPORT", $sformatf("Got DRS MSG -> %p",all_m2s_rd[t].u.s2m_drs), UVM_NONE)
                    if(indexes.size() != 0)
                    begin : IDX0_PROCESS
                        idx0 = indexes.pop_front();
                        c_mrd = all_m2s_rd[idx0];
                        `uvm_info("CXL_REPORT", $sformatf("Got one DRS MSG -> %p",c_mrd.u.s2m_drs), UVM_NONE)
                        if(c_mwr.bytes != c_mrd.bytes) begin
                            `uvm_error("", $psprintf("Write Data all_m2s_wr[%0d] = %p rd_data = %p", t, all_m2s_wr[t].bytes, all_m2s_rd[t].bytes))
                        end else begin
                            `uvm_info("CXL_REPORT", $psprintf("Matching Read and Write for Transaction %0d",t), UVM_MEDIUM)
                        end
                    end : IDX0_PROCESS
                    else
                        `uvm_error("CXL_REPORT", $psprintf("Matching MRwD TAG:0x%0h not found in DRS responses", c_mwr.u.m2s_reqdata.tag))
                `endif

            end : M2S_DATA_INTEGRITY_CHECK
            
            `uvm_info("CXL_REPORT", $psprintf("M2S/S2M Traffic Self Check Sequence ends!"), UVM_NONE);
        
              #5us; //drain time
        endtask : body 
        
    endclass : cxl_m2s_self_check_seq

`endif//CXL_M2S_SELF_CHECK_SEQ__SVH

