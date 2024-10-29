//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_io_seq.svh 
// Date Created    : Wed 24 November 2021
//--------------------------------------------------------------------------------
// Description  :
//     
//    CXL IO Traffic generation sequence and does Data integrity check. 
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
//    Version             : 1.0
//    Version Information : 
//       1. Initial Version.
//
//--------------------------------------------------------------------------------

`ifndef CXL_IO_SEQ__SVH
`define CXL_IO_SEQ__SVH

    //--------------------------------------------------------------------------------
    // Base UVM Package
    //--------------------------------------------------------------------------------
    import uvm_pkg::*;
    
    //--------------------------------------------------------------------------------
    // cxl_io_seq Class Definition 
    //--------------------------------------------------------------------------------
    class cxl_io_seq extends uvm_sequence #(apci_data_base);
    
        int                     num_io_req;

        `uvm_declare_p_sequencer(apci_uvm_seqr)
        
        `uvm_object_utils_begin(cxl_io_seq)
        `uvm_object_utils_end
        
        //--------------------------------------------------------------------------------
        // New 
        //--------------------------------------------------------------------------------
        function new (string name="cxl_io_seq");
            super.new(name);
        endfunction : new
        
        //--------------------------------------------------------------------------------
        // Body
        //--------------------------------------------------------------------------------
        virtual task body();
            int                 tr_length,tr_length_min,tr_length_max;
            apci_device         bfm;  
            apci_device_mgr     mgrs[$];
            bit                 ok;
            apci_bar_t          mbar = 0; // and to this Memory Bar range
            apci_transaction    tr;
            apci_transaction    all_trs[$];  
            
            apci_addr_range_t   ranges[$];
            
            bit                 address_obtained;
            bit [63:0]          address, address_q[$];
            bit [63:0]          address_ur,address_ur2,address_q_ur[$];
            int                 num_element[$];
            apci_bar_t          pf_bar_base[32][32][32];
            bit [3:0]           tr_first_be;
            bit [3:0]           tr_last_be;
            
            bfm = p_sequencer.bfm;   
            
            `uvm_info("CXL_REPORT", $psprintf("IO Traffic Sequence starts!"), UVM_NONE)
            
            //Note: Check that CXL mode was enabled through linkup process
            if (bfm.port_get(0, "cxl_mode_active") == 0) begin : CXL_MODE_ACTIVE
                `uvm_error("", $psprintf("Link is not operating in CXL mode"));
                return;
            end : CXL_MODE_ACTIVE
            
            if (bfm.get("dev_type") != APCI_DEVICE_rc) begin : BFM_MODE_CHECK
                `uvm_fatal("", $psprintf("apci_uvm_seq_basic: device type %0h is not APCI_DEVICE_rc", bfm.get("dev_type")));
            end : BFM_MODE_CHECK
            
            //Note: Get Device mem ranges
            bfm.get_cxl_hdm_ranges(ranges);
            
            if(!$value$plusargs("num_req=%0d",num_io_req))
                num_io_req = 20;
            
            //Note: collect device informations
            bfm.collect_devices(-1, mgrs);
            
            // Step 2: find a target memory to EP
            foreach (mgrs[i])
            begin : MGRS
                if (mgrs[i].dev_type inside {APCI_DEVICE_ep, APCI_DEVICE_legacy_ep})
                begin : DEV_EP_T
                    foreach (mgrs[i].finfs[k])
                    begin : FUNC_INFS
                        apci_func_info f = mgrs[i].finfs[k];
                        for (int j = 0; j < f.mem_ranges.size(); j++)
                        begin : MEM_RANGE_S
                            mbar = f.mem_ranges[j];
                            pf_bar_base[i][k][j]= mbar.base;
                            if(($test$plusargs("NO_TEST_PF1_BAR0"))&&((k==1)&&(j==0)))
                                `uvm_info("CXL_REPORT", $psprintf("Not selecting address from PF1 BAR0 base address %0h", mbar.base), UVM_MEDIUM)
                            else if(($test$plusargs("NO_TEST_PF1_BAR2"))&&((k==1)&&(j==1)))
                                `uvm_info("CXL_REPORT", $psprintf("Not selecting address from PF1 BAR2 base address %0h", mbar.base), UVM_MEDIUM)
                            else if(($test$plusargs("NO_TEST_PF0_BAR0"))&&((k==0)&&(j==0)))
                                `uvm_info("CXL_REPORT", $psprintf("Not selecting address from PF0 BAR0 base address %0h", mbar.base), UVM_MEDIUM)
                            else if(($test$plusargs("NO_TEST_PF0_BAR2"))&&((k==0)&&(j==1)))
                                `uvm_info("CXL_REPORT", $psprintf("Not selecting address from PF0 BAR2 base address %0h", mbar.base), UVM_MEDIUM)
                            else
                            begin : ADDRESS_DEF
                                //Note: for each valid range adding address 
                                for (int m = 0; m < num_io_req; m++) begin : ADDRESS_SELECTION
                                    `uvm_info("CXL_REPORT", $psprintf("Number of requests to access is %0d",num_io_req), UVM_MEDIUM)
                                    address_obtained = 0;
                                    
                                    //Note: Address selection -min,mid,max,random
                                    while(address_obtained == 0) begin : ADDRESS_GRABBER
                                        if(m==0)begin
                                            address  = mbar.base;
                                            address_ur = mbar.base -4;
                                            address_ur2 = mbar.base -8;
                                        end else if(m==1)begin
                                            address  = mbar.base + (mbar.len>>1);
                                        end else if(m==2) begin
                                            address  = mbar.base + (mbar.len-1);
                                            address_ur = mbar.base +mbar.len +4;
                                            address_ur2 = mbar.base +mbar.len +8;
                                        end else if(m==3)begin
                                            address  = mbar.base+4;
                                        end else if(m==4) begin
                                            address  = mbar.base + (mbar.len-8);
                                        end else
                                            std::randomize(address) with {address >= mbar.base ; address <= mbar.base + mbar.len-1;};
                                        
                                        address[1:0] = '0;
                                        
                                        num_element = address_q.find_index with (item == address);
                                        if(num_element.size() == 0) begin : ADDRESS_Q
                                            address_q[address_q.size()] = address;
                                        
                                            address_q_ur[address_q_ur.size()] = address_ur;
                                            address_q_ur[address_q_ur.size()] = address_ur2;
                                       
                                            address_obtained = 1;
                                            `uvm_info("CXL_REPORT", $psprintf("Selected Address = %x is for %0d (device:%0d,pf:%0d,bar:%0d)", address, (address_q.size()-1),i,k,j), UVM_MEDIUM)
                                        end : ADDRESS_Q 
                                    end : ADDRESS_GRABBER
                                end : ADDRESS_SELECTION
                            end : ADDRESS_DEF
                        end : MEM_RANGE_S
                    end : FUNC_INFS
                end : DEV_EP_T
            end : MGRS
            
            // Step 3: send some memory transactions
            if($test$plusargs("TEST_PIO_PARALLEL"))
            begin : PIO_P
                for (int n=0; n < address_q.size(); n++)
                begin : ADDRESS_Q1
                    `uvm_info("CXL_REPORT", $psprintf("tr Address = %x", address_q[n]), UVM_MEDIUM)
                    
                    if((($value$plusargs("LENGTH_MIN=%0d",tr_length_min))&&($value$plusargs("LENGTH_MAX=%0d",tr_length_max))))
                        std::randomize(tr_length) with {tr_length >= tr_length_min ; tr_length <= tr_length_max;}; 
                    else if($test$plusargs("LENGTH_REF"))
                        std::randomize(tr_length) with {tr_length inside {1,8,16,24,32,40,48,56,64,72,80,88};}; //for multi segment
                    else if(!$value$plusargs("LENGTH=%0d",tr_length))
                        tr_length = 1;
                    if(($test$plusargs("TEST_ADDR_UN_ALINE")))
                    begin : ADDR_UN_ALIGN
                        if(tr_length ==1)
                        begin
                            std::randomize(tr_first_be) with {tr_first_be inside {'hC,'hE,'hF,'h8,'h7,'h6,'h4,'h3,'h2,'h1,'h0};}; 
                            std::randomize(tr_last_be) with {tr_last_be inside {'h0};}; 
                        end
                        else
                        begin
                            std::randomize(tr_first_be) with {tr_first_be inside {'h8,'hC,'hE,'hF};}; 
                            std::randomize(tr_last_be) with {tr_last_be inside {'hF,'h7,'h3,'h1};}; 
                        end
                    end : ADDR_UN_ALIGN
                    else
                    begin : ADDR_ALIGN
                        std::randomize(tr_first_be) with {tr_first_be inside {'hF};}; 
                        if(tr_length ==1)
                            std::randomize(tr_last_be) with {tr_last_be inside {'h0};}; 
                        else
                            std::randomize(tr_last_be) with {tr_last_be inside {'hF};}; 
                    end : ADDR_ALIGN
                
                    //Note: WRITE Op
                    if(!($test$plusargs("DNOT_TEST_WR")))
                    begin : WR_OP
                        `uvm_create(tr)
                        ok = tr.randomize() with {
                            kind == APCI_TRANS_mem;
                            addr        ==      address_q[n];
                            length            == tr_length;
                            proc_hint         == 0;
                            tc                == 0;
                            is_write          == 1;
                            first_be ==  tr_first_be;
                            last_be == tr_last_be;
                        };
                        assert(ok) else `uvm_fatal("CXL_REPORT", "randomization failed");
                        if (tr.is_write)
                        begin
                            int k = $urandom;
                            repeat(tr.length)
                            tr.payload.push_back(k++);
                        end
                        `uvm_send(tr);
                        all_trs.push_back(tr);
                    end : WR_OP

                    //Note: READ Op
                    if(!($test$plusargs("DNOT_TEST_RD")))
                    begin : RD_OP
                        `uvm_create(tr)
                        ok = tr.randomize() with {
                            kind == APCI_TRANS_mem;
                            addr      ==        address_q[n];
                            length            == tr_length;
                            proc_hint         == 0;
                            tc                == 0;
                            is_write          == 0;
                            first_be ==  tr_first_be;
                            last_be == tr_last_be;
                        };
                        assert(ok) else `uvm_fatal("CXL_REPORT", "randomization failed");
                        if (tr.is_write)
                        begin
                            int k = $urandom;
                            repeat(tr.length)
                            tr.payload.push_back(k++);
                        end
                        `uvm_send(tr);
                        all_trs.push_back(tr);
                    end
                    
                    foreach(all_trs[i])
                    begin
                        tr = all_trs[i];
                        tr.wait_done(1e9);
                        if (tr.err_code != apci_transaction::OK)
                            `uvm_error("CXL_REPORT", $psprintf("Transaction failed with %s", tr.err_code.name))
                    end
                    
                end : ADDRESS_Q1
                `uvm_info("CXL_REPORT", $psprintf("IO Traffic Sequence ends!"), UVM_NONE)
            
            end : PIO_P
            else
            begin : SEQUENTIAL_ACCESS
            
                if(!$value$plusargs("LENGTH=%0d",tr_length))
                    tr_length = 1;
                    
                for (int n=0; n < address_q.size(); n++)
                begin : WR_OP_S
                    `uvm_info("CXL_REPORT", $psprintf("tr Address = %x is ", address_q[n]), UVM_MEDIUM)
                    
                    `uvm_create(tr)
                    ok = tr.randomize() with {
                        kind == APCI_TRANS_mem;
                        addr        ==      address_q[n];
                        length            == tr_length;
                        proc_hint         == 0;
                        tc                == 0;
                        is_write          == 1;
                    };
                    assert(ok) else `uvm_fatal("CXL_REPORT", "randomization failed");
                    if (tr.is_write)
                    begin
                        int k = $urandom;
                        repeat(tr.length)
                        tr.payload.push_back(k++);
                    end
                    `uvm_send(tr);
                    all_trs.push_back(tr);  
                    
                    //Note: wait for WR done
                    tr.wait_done(1e9);
                    if (tr.err_code != apci_transaction::OK)
                        `uvm_error("CXL_REPORT", $psprintf("Transaction failed with %s", tr.err_code.name))
                end : WR_OP_S
                    
                for (int n=0; n < address_q.size(); n++)
                begin : RD_OP_S
                    `uvm_info("CXL_REPORT", $psprintf("tr Address = %x is ", address_q[n]), UVM_MEDIUM)

                    `uvm_create(tr)
                    ok = tr.randomize() with {
                        kind == APCI_TRANS_mem;
                        addr      ==        address_q[n];
                        length            == tr_length;
                        proc_hint         == 0;
                        tc                == 0;
                        is_write          == 0;
                    };
                    assert(ok) else `uvm_fatal("CXL_REPORT", "randomization failed");
                    if (tr.is_write)
                    begin
                        int k = $urandom;
                        repeat(tr.length)
                        tr.payload.push_back(k++);
                    end
                    `uvm_send(tr);
                    all_trs.push_back(tr);
                    
                    //Note: Wait for RD done
                    tr.wait_done(1e9);
                    if (tr.err_code != apci_transaction::OK)
                        `uvm_error("CXL_REPORT", $psprintf("Transaction failed with %s", tr.err_code.name))
                end : RD_OP_S
                    
                `uvm_info("CXL_REPORT", $psprintf("IO Traffic Sequence ends!"), UVM_NONE)
                    
                // Note: out of boundary memory transactions    
                `uvm_info("CXL_REPORT", $psprintf("IO ofb Traffic Sequence starts!"), UVM_NONE)
                for (int n=0; n < address_q_ur.size(); n++)
                begin : OFB_WR_ACCESS
                    `uvm_info("CXL_REPORT", $psprintf("tr wr Address = %x is ", address_q_ur[n]), UVM_MEDIUM)
                    
                    `uvm_create(tr)
                    ok = tr.randomize() with {
                        kind == APCI_TRANS_mem;
                        addr        ==      address_q_ur[n];
                        length            == tr_length;
                        proc_hint         == 0;
                        tc                == 0;
                        is_write          == 1;
                    };
                    assert(ok) else `uvm_fatal("CXL_REPORT", "randomization failed");
                    tr.user_ctrl.is_ei = 1;
                    if (tr.is_write)
                    begin
                        int k = $urandom;
                        repeat(tr.length)
                        tr.payload.push_back(k++);
                    end
                    `uvm_send(tr);
                    all_trs.push_back(tr);  
                    
                    //Note: wait for WR done
                    tr.wait_done(1e9);
                    if (tr.err_code != apci_transaction::OK)
                    `uvm_info("CXL_REPORT", $psprintf("Transaction completed with expected error code as: %s", tr.err_code.name), UVM_HIGH)
                end : OFB_WR_ACCESS
                    
                for (int n=0; n < address_q_ur.size(); n++)
                begin : OFB_RD_ACCESS
                    `uvm_info("CXL_REPORT", $psprintf("tr rd Address = %x is ", address_q_ur[n]), UVM_MEDIUM)

                    `uvm_create(tr)
                    ok = tr.randomize() with {
                        kind == APCI_TRANS_mem;
                        addr      ==        address_q_ur[n];
                        length            == tr_length;
                        proc_hint         == 0;
                        tc                == 0;
                        is_write          == 0;
                    };
                    assert(ok) else `uvm_fatal("CXL_REPORT", "randomization failed");
                    tr.user_ctrl.is_ei = 1;
                    if (tr.is_write)
                    begin
                        int k = $urandom;
                        repeat(tr.length)
                        tr.payload.push_back(k++);
                    end
                    `uvm_send(tr);
                    all_trs.push_back(tr);
                    
                    tr.wait_done(1e9);
                    if (tr.err_code != apci_transaction::OK)
                        `uvm_info("CXL_REPORT", $psprintf("Transaction responded an expected UR"), UVM_HIGH)
                end : OFB_RD_ACCESS
                
                `uvm_info("CXL_REPORT", $psprintf("IO ofb Traffic Sequence ends!"), UVM_NONE)
            end : SEQUENTIAL_ACCESS 
            
            //Note: Drain time
            #50us;
        endtask : body 
    
    endclass : cxl_io_seq

`endif//CXL_IO_SEQ__SVH

