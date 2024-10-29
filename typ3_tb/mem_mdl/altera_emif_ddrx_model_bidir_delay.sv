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


module altera_emif_ddrx_model_bidir_delay
#(
   parameter DELAY = 2.0
) (
   inout porta,
   inout portb
);
   timeunit 1ps;
   timeprecision 1ps;

   reg porta_dly;
   reg portb_dly;

   initial begin
      porta_dly = 1'bz;
      portb_dly = 1'bz;
   end

   always @(porta) begin
      if (portb_dly === 1'bz || porta === 1'bz) begin
         porta_dly <= #DELAY porta;
      end
   end

   always @(portb) begin
      if (porta_dly === 1'bz || portb === 1'bz) begin
         portb_dly <= #DELAY portb;
      end
   end

   assign porta = portb_dly;
   assign portb = porta_dly;
endmodule
