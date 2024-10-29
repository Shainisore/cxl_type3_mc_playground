//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2022 - Present.
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_seq_lib.svh 
// Date Created    : Tue 07 March 2023
//--------------------------------------------------------------------------------
// Description  :
//     
//    Sequence Library to be used in the test execution
//
//--------------------------------------------------------------------------------
`ifndef _CXL_SEQ_LIB_SVH_
`define _CXL_SEQ_LIB_SVH_

    //--------------------------------------------------------------------------------
    // Base UVM Package
    //--------------------------------------------------------------------------------
    import uvm_pkg::*;
    import apci_pkg::*;
    `include "uvm_macros.svh"
    
    //----------------------------------------
    // List the sequences
    //----------------------------------------
    `include "cxl_io_seq.svh"
    `include "cxl_m2s_self_check_seq.svh"

`endif//_CXL_SEQ_LIB_SVH_
