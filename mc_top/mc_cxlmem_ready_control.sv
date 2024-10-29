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


// Copyright 2022 Intel Corporation.
//
// THIS SOFTWARE MAY CONTAIN PREPRODUCTION CODE AND IS PROVIDED BY THE
// COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
///////////////////////////////////////////////////////////////////////

`include "cxl_typ3ddr_ed_defines.svh.iv"
`ifdef INCLUDE_CXLMEM_READY

module mc_cxlmem_ready_control
#(
    localparam REQFIFO_DEPTH_WIDTH         = 6,
    /*  
     * For adding cxlmem_ready flag from user defined MC/inline accelerator
     * Parameter for the number of pipeline stages in bbs for drainage out of dataflow controller
     * so that once a user deasserts cxlmem_ready, they still have room to collect the drainage
     * and headroom
     *
     * Width = 10 (used when  7 reqs from IP when ready de-asserts)
     * Width = 33 (used when 30 reqs from IP when ready de-asserts)
     */
    localparam BBS_DFC_DRAINAGE_WIDTH      = 33,
    /*
     * For adding cxlmem_ready flag from user defined MC/inline accelerator
     * Need a numerical exact width number from the addressing bit width in REQFIFO_DEPTH_WIDTH
     */
    localparam CXLMEM_READY_CUTOFF         = ((2**REQFIFO_DEPTH_WIDTH) - BBS_DFC_DRAINAGE_WIDTH)
)
(
    input clk,
    input reset_al,                    // active low
    
    // reqfifo
    input logic                            from_mc_ch_adpt_mc2iafu_ready_eclk,
    input logic                            from_mc_ch_adpt_reqfifo_full_eclk,
    input logic                            from_mc_ch_adpt_reqfifo_empty_eclk,
    input logic [REQFIFO_DEPTH_WIDTH-1:0]  from_mc_ch_adpt_reqfifo_fill_level_eclk,

    output logic                            to_bbs_cxlmem_ready
);
    

   always_ff @(posedge clk)
   begin
     if ( !reset_al ) begin
                                                                                  to_bbs_cxlmem_ready  <= 1'b0;
     end
     else if ( (!from_mc_ch_adpt_mc2iafu_ready_eclk)                                                              // MC initialize not done
             | (from_mc_ch_adpt_reqfifo_fill_level_eclk == CXLMEM_READY_CUTOFF)                                   // the cutoff threshold is reached
             | from_mc_ch_adpt_reqfifo_full_eclk
             ) begin                                                                                              // the fifo is full (don't get here)
                                                                                  to_bbs_cxlmem_ready  <= 1'b0;         
     end
     else if ( (from_mc_ch_adpt_mc2iafu_ready_eclk & from_mc_ch_adpt_reqfifo_empty_eclk)                          // MC initialize done & fifo is empty
             | ( (from_mc_ch_adpt_reqfifo_fill_level_eclk < CXLMEM_READY_CUTOFF)                                  // below the cutoff threshold
               & (from_mc_ch_adpt_reqfifo_fill_level_eclk != '0)                                                  // & not zero
               )
             ) begin
                                                                                  to_bbs_cxlmem_ready  <= 1'b1;         
     end
     else                                                                         to_bbs_cxlmem_ready  <= to_bbs_cxlmem_ready;
   end

/*
assign to_bbs_cxlmem_ready = ( !reset_al )                                                                ? 1'b0 :
                           ( ( !from_mc_ch_adpt_mc2iafu_ready_eclk )                                      ? 1'b0 :
                           ( ( from_mc_ch_adpt_reqfifo_fill_level_eclk == CXLMEM_READY_CUTOFF )           ? 1'b0 :
                           ( ( from_mc_ch_adpt_reqfifo_full_eclk )                                        ? 1'b0 :
                           ( ( from_mc_ch_adpt_mc2iafu_ready_eclk & from_mc_ch_adpt_reqfifo_empty_eclk )  ? 1'b1 :
                           ( ( from_mc_ch_adpt_reqfifo_fill_level_eclk < CXLMEM_READY_CUTOFF )
                             & ( from_mc_ch_adpt_reqfifo_fill_level_eclk != '0 )
                           )                                                                              ? 1'b1 : 1'b0 ))));
*/

endmodule

`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "0Z4gtymrRqkvvrdYaOSvdFTql+7FIwsI2jZJvE1KO3u7dqs1ZRaFzmO1jfFEc7znhwTAiO1KBSKrP987+SAzGd5SvXIQx6xI0AW8nwFvG6JF+1q0i0mnazpK1aymFzJFUNNl0aG5+UK6Rq82vQKPWNYiGGa9HAwpFBwP56gqubM1VmjZQDnsh8vHSOG8UUlus/z3DVPAFn39Q+wG6oF7rQvO7O2RFEn7+ZeC5J/0D0vesfZ5aoQASdZEgmS2C5A9T6Kb3y5C7dFjV8GQMis35AT+v0lc06wlpIMU7eYAr0UCNt5iqPJZoHetynmdLBE8k6Zm+4gVaeULIhM+SNCcPKiMXVFSavdvskLA0e/by3crcrfR40msh9U4aBTiTA3fKLf15izDVzv5DVRELku3CxsDtDY37UbLzG7Sjt92SRg+f4P4ukp/RpQ5JJ1H9fxPxBQcEaM3wdW6rhLNWoqfGzk3LpsZjFEopbsDMI2k4RI14ptiJMY6XoS5MA4oUMDyITdMicW77p69htGhBFoYZ/J0poEEto1UlROQhBoCLWfXS32BQdcdP/nQ2p3f+I4C9yKhoUO3hsk8cmWW70ZVAvyOYe0a9XKzSKWvY4daWCKb+mfcXOLsn0YOcVeuDf343geliHM4w4qnI4xSkLfuJhZP5AtStetbsbRbFX6wdhXBeohDZQML+y75r5rLa+vqjGNhoDykPuaZ0eNUUJjO3SGxi0aHWwMH2uSNvqvpg0r5X1ywDkcfBHlKP/pjFEQNQLUSxE3DzaYKvbH+4uM6WDIHYAWeKr1lAJdZsGsgfU5fnHMs/F3ZMGEJtbdXjJurEfvohtBIxL+04janrcY9Qsm8bnaPSQAtJ24+1hBBHtGd6rn0J/0WioSwXdl6ZRqgRLTiR+mRnYL1pJzbXNDKlJAJ0SyG4iW9Boesgv/ELJsxNm/7oFtVWYx6B9hh6b2vlr0BJvjghlxvUooMXRHEIZWCZ5cB09hCJqlxIqPWHYS8LM3ZCujdbdzqjc57cDIk"
`endif