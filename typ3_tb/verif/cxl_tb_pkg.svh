//--------------------------------------------------------------------------------
// Copyright (c) Programmable Solutions Group (PSG),
// Intel Corporation 2023
// All rights reserved.
//--------------------------------------------------------------------------------
// File name       : cxl_tb_pkg.svh
// Date Created    : Fri 29 September 2023
//--------------------------------------------------------------------------------
// Description  :
//     
//    PKG Definition for TB components. 
//
//--------------------------------------------------------------------------------
`ifndef _CXL_TB_PKG_SVH_
`define _CXL_TB_PKG_SVH_

    package cxl_tb_pkg;

       //----------------------------------------
       // Packages Imports
       //----------------------------------------
       import uvm_pkg::*;
       import apci_pkg::*;
       `include "uvm_macros.svh"
       
       //----------------------------------------
       // Child package files to incrementally build and simulate
       //----------------------------------------
       `include "cxl_tb_env.sv"

    endpackage : cxl_tb_pkg

`endif//_CXL_TB_PKG_SVH_

