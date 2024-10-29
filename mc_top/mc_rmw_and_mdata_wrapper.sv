// (C) 2001-2024 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// ***************************************************************************
//
//        Copyright (C) 2019 Intel Corporation All Rights Reserved.
//
//
// No license under any patent,  copyright, trade secret or other intellectual
// property  right  is  granted  to  or  conferred  upon  you by disclosure or
// delivery  of  the  Materials, either expressly, by implication, inducement,
// estoppel or otherwise.  Any license under such intellectual property rights
// must be express and approved by Intel in writing.
//
// You will not, and will not allow any third party to modify, adapt, enhance,
// disassemble, decompile, reverse engineer, change or create derivative works
// from the Software except and only to the extent as specifically required by
// mandatory applicable laws or any applicable third party license terms
// accompanying the Software.
// ***************************************************************************

// ***************************************************************************
//                         INTEL RESTRICTED SECRET
//
//        Copyright (C) 2008-2013 Intel Corporation All Rights Reserved.
//
//
// No license under any patent,  copyright, trade secret or other intellectual
// property  right  is  granted  to  or  conferred  upon  you by disclosure or
// delivery  of  the  Materials, either expressly, by implication, inducement,
// estoppel or otherwise.  Any license under such intellectual property rights
// must be express and approved by Intel in writing.
//
// Engineer:         Mike Werstlein
// Created Date :    Fri Aug 31 2012
// Module Name  :    mem_wrapper.sv
// Project      :    Memory Controller Top Level Module
// Description  :
// ****************************************************************************
//-----------------------------------------------------------------------------

module mc_rmw_and_mdata_wrapper #(
  parameter  int MC_ADDR_WIDTH      = 46,
  parameter  int MC_DATA_WIDTH      = 512,
  parameter  int MC_MDATA_WIDTH     = 18,
  localparam int MC_BITS_PER_SYMBOL = 8,
  localparam int MC_BE_WIDTH = MC_DATA_WIDTH / MC_BITS_PER_SYMBOL
)
(
input  logic                        emif_usr_clk            ,  // EMIF User Clock
input  logic                        emif_usr_reset_n        ,  // EMIF reset
input  logic                        emif_cal_success        ,

output logic                        mem_ready               ,  //  width = 1,
input  logic                        mem_read                ,  //  width = 1,
input  logic                        mem_write               ,  //  width = 1,
input  logic                        mem_write_poison        ,  //  width = 1,
input  logic                        mem_write_partial       ,  //  width = 1,
input  logic [MC_ADDR_WIDTH-1:0]    mem_address             ,  //  width = 46,
input  logic [MC_MDATA_WIDTH-1:0]   mem_req_mdata           ,  //  width = 46,
input  logic [MC_DATA_WIDTH-1:0]    mem_writedata           ,  //  width = 512,
input  logic [MC_BE_WIDTH-1:0]      mem_byteenable          ,  //  width = 64,
output logic [MC_DATA_WIDTH-1:0]    mem_readdata            ,  //  width = 512,
output logic [MC_MDATA_WIDTH-1:0]   mem_rsp_mdata           ,  //  width = 512,
output logic                        mem_read_poison         ,  //  width = 1,
output logic                        mem_readdatavalid       ,  //  width = 1,
output logic                        mem_rddata_error        ,  //  width = 1,
output logic                        mem_ecc_interrupt       ,  //  width = 1,

input  logic                        mem_ready_rmw           ,  //  width = 1,
output logic                        mem_read_rmw            ,  //  width = 1,
output logic                        mem_write_rmw           ,  //  width = 1,
output logic                        mem_write_poison_rmw    ,  //  width = 1,
output logic [MC_ADDR_WIDTH-1:0]    mem_address_rmw         ,  //  width = 46,
output logic [MC_DATA_WIDTH-1:0]    mem_writedata_rmw       ,  //  width = 512,
output logic [MC_BE_WIDTH-1:0]      mem_byteenable_rmw      ,  //  width = 64,
input  logic [MC_DATA_WIDTH-1:0]    mem_readdata_rmw        ,  //  width = 512,
input  logic                        mem_read_poison_rmw     ,  //  width = 1,
input  logic                        mem_readdatavalid_rmw   ,  //  width = 1,
input  logic                        mem_rddata_error_rmw    ,  //  width = 1,
input  logic                        mem_ecc_interrupt_rmw      //  width = 1,
);

//logic [MC_MDATA_WIDTH-1:0] mdata_q_din, mdata_q_dout;
//logic mdata_q_wen, mdata_q_ren, mdata_q_full;

//assign mdata_q_din = mem_req_mdata;
//assign mdata_q_wen = mem_read & mem_ready;
//assign mdata_q_ren = mem_readdatavalid;
//
//assign mem_rsp_mdata = mdata_q_dout;
assign mem_rsp_mdata = '0;

//mdata_sc_fifo mdata_scfifo (
//		.data        (mdata_q_din),        //   input,  width = 6,  fifo_input.datain
//		.wrreq       (mdata_q_wen),       //   input,  width = 1,            .wrreq
//		.rdreq       (mdata_q_ren),       //   input,  width = 1,            .rdreq
//		.clock       (emif_usr_clk),       //   input,  width = 1,            .clk
//		.q           (mdata_q_dout),           //  output,  width = 6, fifo_output.dataout
//		.full        (),        //  output,  width = 1,            .full
//		.empty       (),       //  output,  width = 1,            .empty
//		.almost_full (mdata_q_full)  //  output,  width = 1,            .almost_full
//	);

mc_rmw_shim #(
  .MC_HA_DP_ADDR_WIDTH (MC_ADDR_WIDTH),
  .MC_HA_DP_DATA_WIDTH (MC_DATA_WIDTH)
)
mc_rmw_shim_inst (
  .mem_clk                     ( emif_usr_clk               ),
  .mem_reset_n                 ( emif_usr_reset_n           ),
  .mem_ready_ha_mclk           ( mem_ready                  ),
  .mem_read_ha_mclk            ( mem_read                   ),
  .mem_write_ha_mclk           ( mem_write                  ),
  .mem_write_poison_ha_mclk    ( mem_write_poison           ),
  .mem_write_partial_ha_mclk   ( mem_write_partial          ),
  .mem_address_ha_mclk         ( mem_address                ),
  .mem_writedata_ha_mclk       ( mem_writedata              ),
  .mem_byteenable_ha_mclk      ( mem_byteenable             ),
  .mem_readdata_ha_mclk        ( mem_readdata               ),
  .mem_read_poison_ha_mclk     ( mem_read_poison            ),
  .mem_readdatavalid_ha_mclk   ( mem_readdatavalid          ),
  .mem_rddata_error_ha_mclk    ( mem_rddata_error           ),
  .mem_ecc_interrupt_ha_mclk   ( mem_ecc_interrupt          ),
  .mem_ready_mclk              ( mem_ready_rmw              ),
  .mem_read_mclk               ( mem_read_rmw               ),
  .mem_write_mclk              ( mem_write_rmw              ),
  .mem_write_poison_mclk       ( mem_write_poison_rmw       ),
  .mem_address_mclk            ( mem_address_rmw            ),
  .mem_writedata_mclk          ( mem_writedata_rmw          ),
  .mem_byteenable_mclk         ( mem_byteenable_rmw         ),
  .mem_readdata_mclk           ( mem_readdata_rmw           ),
  .mem_read_poison_mclk        ( mem_read_poison_rmw        ),
  .mem_readdatavalid_mclk      ( mem_readdatavalid_rmw      ),
  .mem_rddata_error_mclk       ( mem_rddata_error_rmw       ),
  .mem_ecc_interrupt_mclk      ( mem_ecc_interrupt_rmw      )
);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "0Z4gtymrRqkvvrdYaOSvdFTql+7FIwsI2jZJvE1KO3u7dqs1ZRaFzmO1jfFEc7znhwTAiO1KBSKrP987+SAzGd5SvXIQx6xI0AW8nwFvG6JF+1q0i0mnazpK1aymFzJFUNNl0aG5+UK6Rq82vQKPWNYiGGa9HAwpFBwP56gqubM1VmjZQDnsh8vHSOG8UUlus/z3DVPAFn39Q+wG6oF7rQvO7O2RFEn7+ZeC5J/0D0tQi46LSTIZ72mRRmFGHxR9/O1ZnOoPz9wgQDm3upCwHd+0NFXhoprE5/5aBbO1C5/h09gcPVWiN0nntNfhv9O1nTIqGsf3xtDmOr6NMhAqrDcJkpGKgQC6v4CbCHOu0KNNFuSkkaSD4zkUfOSJYk+MtUfagbvQDpJ6LiApuZfVUXG8+B6mdcLxJU80919Zxy/Jh7Epi4uamIIUt7EzLxz5PwouXUr6nvTcUzfV+3Z/iq3PYDUPd9aTeXw8BRiuHcjq0UKCqFlLS25wkPg6htzN6KyB1OAFT7OHJ+LqtVqyZcxaMHMnE6IMyyl+jIiDZGpU9+aFpY5UPv6RQp7ZM9CxYLPzqix2eeEgzg3Mzkp+LCCKvqk55x9GEwEPC7DU8/Jk0xAC9essWtDzKnMLK+lPzbTv030MLF9L7Ktvz5bO/6zGA3XD10rbbB2rmIkCoHTNR4dJ37HpTPwued4NuICunWGkopMFW+1gBQm64eqZrOIvrQ8+fNhMWKo0K4HLKI5NS82/UJ52LSofmCFgl8a1aCzqPFKLpgM9/rGRH1yus/peCqVhmadt2+Rm+Idn20Eu3yK9XA1jFXFeo/jyk5sVOyeC66ckh1hhRdsDkCJlE8O9n5XxkwSAlnpZGrwY7NV9rmnq+1gnbZE1D+hHyPgN2YNL8d8mKkcKHFOrmLMnsgPbdpjH/OVXd1Mnrd3E5lHQf3OiNd6Dfl9SVZchYEX6laJObdaS18MKJL6Gr4QDz0Yd9beizDNY63rwjoFvcHKWEjoi5U7SpXiDY4MGP+sl"
`endif