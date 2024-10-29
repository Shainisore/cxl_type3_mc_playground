// (C) 2001-2022 Intel Corporation. All rights reserved.
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


///////////////////////////////////////////////////////////////////////////////
// Basic simulation model of DDR4 Data Buffer used by LRDIMM
//
///////////////////////////////////////////////////////////////////////////////
module altera_emif_ddr4_model_db_chip (
   input       BCK_t,
   input       BCK_c,
   input       BCKE,
   input       BODT,
   input       BVrefCA,
   input [3:0] BCOM,

   inout [7:0] MDQ,
   inout       MDQS0_t,
   inout       MDQS0_c,
   inout       MDQS1_t,
   inout       MDQS1_c,

   inout [7:0] DQ,
   inout       DQS0_t,
   inout       DQS0_c,
   inout       DQS1_t,
   inout       DQS1_c,

   output      ALERT_n,

   input       VDD,
   input       VSS
);

   timeunit 1ps;
   timeprecision 1ps;

   genvar i;

   generate
      for (i = 0; i < 8; i = i + 1) begin : gen_dq_delay
         altera_emif_ddrx_model_bidir_delay #(
            .DELAY                         (1.0)
         ) inst_dq_bidir_dly (
            .porta                         (MDQ[i]),
            .portb                         (DQ[i])
         );
      end
   endgenerate

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_p_0 (
      .porta                         (MDQS0_t),
      .portb                         (DQS0_t)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_n_0 (
      .porta                         (MDQS0_c),
      .portb                         (DQS0_c)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_p_1 (
      .porta                         (MDQS1_t),
      .portb                         (DQS1_t)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_n_1 (
      .porta                         (MDQS1_c),
      .portb                         (DQS1_c)
   );

endmodule

