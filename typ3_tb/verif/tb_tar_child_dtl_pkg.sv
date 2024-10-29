//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2023
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : tb_tar_child_dtl_pkg.sv 
// Date Created    : Thu 13 April 2023
//--------------------------------------------------------------------------------
// Description  :
//     
//    Child Package to be used in the DTL Setup. This list will be built and
//    simulated incrementally, if DTL option is used.
//
//--------------------------------------------------------------------------------
`ifndef _TB_TAR_CHILD_DTL_PKG_SV_
`define _TB_TAR_CHILD_DTL_PKG_SV_

    package tb_tar_child_dtl_pkg;
    
       //----------------------------------------
       // Packages Imports
       //----------------------------------------
       import uvm_pkg::*;
       import apci_pkg::*;
       `include "uvm_macros.svh"
       
       //----------------------------------------
       // Child package files to incrementally build and simulate
       //----------------------------------------
       `include "cxl_seq_lib.svh"
    
    endpackage : tb_tar_child_dtl_pkg

`endif//_TB_TAR_CHILD_DTL_PKG_SV_
