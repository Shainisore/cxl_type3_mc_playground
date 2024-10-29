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
// Creation Date : Feb, 2023
// Description   : SBCNT/DBCNT 



module mc_devmem_top 
import mc_ecc_pkg::*; 
(
  input  logic                                    clk,
  input  logic                                    rst,

  input   mc_ecc_pkg::mc_devmem_if_t              mc_devmem_if,
  output  mc_ecc_pkg::mc_err_cnt_t                mc_err_cnt

    );


  logic [32:0]  mcRdDataDBECnt_Q;
  logic [3:0]   mcRdDataDBESum;
  logic         mcRdDataNewDBE_Q;
  logic         mcRdDataNewPoisonRtn_Q;
  logic         mcRdDataNewSBE_Q;
  logic [32:0]  mcRdDataPoisonRtnCnt_Q;
  logic [32:0]  mcRdDataSBECnt_Q;
  logic [3:0]   mcRdDataSBESum;
  logic         mcErrOnPartial_Q;

  // Generate sum of SBE[7:0] and DBE[7:0]
  always_comb begin
    mcRdDataSBESum = '0;
    mcRdDataDBESum = '0;

    for (int i=0; i<8; i++) begin
      mcRdDataSBESum += mc_devmem_if.RdDataECC.SBE[i];
      mcRdDataDBESum += mc_devmem_if.RdDataECC.DBE[i];
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      mcRdDataSBECnt_Q <= '0;
      mcRdDataNewSBE_Q <= 1'b0;
    end
    else if (mc_devmem_if.RdDataECC.Valid & (|mc_devmem_if.RdDataECC.SBE)) begin
      mcRdDataSBECnt_Q <= mcRdDataSBECnt_Q + mcRdDataSBESum;
      mcRdDataNewSBE_Q <= 1'b1;  // Update channel aggregated count
    end
    else if (mcRdDataNewSBE_Q) begin
      mcRdDataNewSBE_Q <= 1'b0;
    end
  end

  // - If all DBE instances report error, treat as data written to memory with poison=1
  //   - Not treated as a DBE error case
  //     - Increment "poison return" count
  //     - Do not increment DBE count
  //   - Note: Read data returned to host will have poison=1 (any DBE causes poison=1)
  // - If some (not all) DBE instances report error, treat as data written to memory with poison=0
  //   - Treated as a DBE error case
  //     - Increment DBE count
  //     - Increment "poison return" count
  //   - Note: Read data returned to host will have poison=1 (any DBE causes poison=1)

  //1-8 DBEs should increment poison counter
  always_ff @(posedge clk) begin
    if (rst) begin
      mcRdDataPoisonRtnCnt_Q <= '0;
      mcRdDataNewPoisonRtn_Q <= 1'b0;
    end
    else if (mc_devmem_if.RdDataValid & (|mc_devmem_if.RdDataECC.DBE)) begin
      mcRdDataPoisonRtnCnt_Q <= mcRdDataPoisonRtnCnt_Q + 'd1;
      mcRdDataNewPoisonRtn_Q <= 1'b1;  // Update channel aggregated count
    end
    else if (mcRdDataNewPoisonRtn_Q) begin
      mcRdDataNewPoisonRtn_Q <= 1'b0;
    end
  end

  //1-7 DBEs should increment DBE counter. Specifically, 8DBEs does not increment DBE counter
  always_ff @(posedge clk) begin
    if (rst) begin
      mcRdDataDBECnt_Q <= '0;
      mcRdDataNewDBE_Q <= 1'b0;
    end
    else if (mc_devmem_if.RdDataECC.Valid & (|mc_devmem_if.RdDataECC.DBE) & (~&mc_devmem_if.RdDataECC.DBE)) begin
      mcRdDataDBECnt_Q <= mcRdDataDBECnt_Q + mcRdDataDBESum;
      mcRdDataNewDBE_Q <= 1'b1;  // Update channel aggregated count
    end
    else if (mcRdDataNewDBE_Q) begin
      mcRdDataNewDBE_Q <= 1'b0;
    end
  end

  // Create indicator for mbox logic to know if Err indicator is for partial write
  //  From mc_channel_adapter:
  //      If both mc2iafu_readdatavalid_eclk == 1 and mc2iafu_ecc_err_valid_eclk == 1
  //        then *ecc_err_* are related to mc2iafu_readdata_eclk
  //      If mc2iafu_readdatavalid_eclk == 0 and mc2iafu_ecc_err_valid_eclk == 1
  //        then *ecc_err_* are related to partial write. "Partial write" functionality is realised as read-modify-write function.

  always_ff @(posedge clk) begin
    if (rst) begin
      mcErrOnPartial_Q <= '0;
    end
    else if (mc_devmem_if.RdDataECC.Valid & ~mc_devmem_if.RdDataValid) begin
      mcErrOnPartial_Q <= '1;
    end
    else begin
      mcErrOnPartial_Q <= '0;
    end
  end

  assign mc_err_cnt.SBECnt       = mcRdDataSBECnt_Q;
  assign mc_err_cnt.DBECnt       = mcRdDataDBECnt_Q;
  assign mc_err_cnt.PoisonRtnCnt = mcRdDataPoisonRtnCnt_Q;

  assign mc_err_cnt.NewSBE       = mcRdDataNewSBE_Q;
  assign mc_err_cnt.NewDBE       = mcRdDataNewDBE_Q;
  assign mc_err_cnt.NewPoisonRtn = mcRdDataNewPoisonRtn_Q;
  assign mc_err_cnt.NewPartialWr = mcErrOnPartial_Q;
  
  assign mc_err_cnt.DevAddr      = '1;



endmodule
                 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "0Z4gtymrRqkvvrdYaOSvdFTql+7FIwsI2jZJvE1KO3u7dqs1ZRaFzmO1jfFEc7znhwTAiO1KBSKrP987+SAzGd5SvXIQx6xI0AW8nwFvG6JF+1q0i0mnazpK1aymFzJFUNNl0aG5+UK6Rq82vQKPWNYiGGa9HAwpFBwP56gqubM1VmjZQDnsh8vHSOG8UUlus/z3DVPAFn39Q+wG6oF7rQvO7O2RFEn7+ZeC5J/0D0usBLJszpflz5FrS70gspvLHIPmT4QooBJP2GtYtfYp/BUPYnI3j7RGYOefupk85thqDb6PJ8gI6UaEV8Fq5eDE7/ggqw73R1stNY+6rYPrOJThmqWfle6bjWgk207RTYz3+FDW7EMUCACsbrp9OB1F2+199d78+FVZoxn8uZgMUdlmfh0EtsAOzauNJaHuCmcZ2XTcO+b2oF852GaAlYOT7TEIAj/WL/wFHXaWEQLq5hnF8HnsGA5O/0nH4L3w9U1iYTXySTNVEiX5+bbIj3YIRSEVedCRVaIhtFqVsT3WJyCrDuMLfwFrcfRwdeAWUMmgw6LGdxBABbGxChQE8WpuQhPsHQotxKunRYy+kALC3VsoaTBMsMGQX4j2ZEWCE6Bb2h/ZUXyWKEkLxgGGms9wUiV1sTkCMuSREZenzfKLh3loufaQoV67crWeWrO58M531eOv5zILnAyHslqykzwjAbiwCgBU5Q3n4RXCVsYo2t8s0yATnYyC5l/gsdAkdr2LPry/yR5j4ki/yeqnaatkJcFxJAyXS4hF9sGbUGz12pD6bQDDjsG22Lgz0VT/HoFDecFeOX7Z6JY5y24DV5KP1sSyfU5oFNWfZz/By3Aqr01H1LzWOUdjXLWVweh2MvhvRqTiu3oYEY1kI88MKRrzRnrYB4qROk3SUIGMonrNZf9DICNNpK9C8wqEz6TLi5Pp2FD3PCaqiy/Wvf1XgtssJ35+cUKwRH+uqDUx6u7jl4GXVmT4EqBATsFSzvfqm5fWBJgPSgaFtdOKx0kOKtvl"
`endif