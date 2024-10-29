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

package mc_ecc_pkg;

 
//-------------------------
//------ Dev Mem Interfaces
//-------------------------
typedef struct packed {
    logic [7:0]                      SBE;
    logic [7:0]                      DBE;
    logic                            Valid;
} mc_rddata_ecc_t;

localparam  CL_ADDR_MSB = 51;
localparam  CL_ADDR_LSB = 6;
typedef logic [CL_ADDR_MSB:CL_ADDR_LSB]        Cl_Addr_t;

typedef struct packed {
    logic [255:0]   Data1;
    logic [255:0]   Data0;
} DataCL_t;

typedef struct packed {
    mc_rddata_ecc_t                  RdDataECC;
    logic                            RdDataValid;
} mc_devmem_if_t;

typedef struct packed {
    Cl_Addr_t                        DevAddr;
    logic [32:0]                     SBECnt;
    logic [32:0]                     DBECnt;
    logic [32:0]                     PoisonRtnCnt;
    logic                            NewSBE;
    logic                            NewDBE;
    logic                            NewPoisonRtn;
    logic                            NewPartialWr;
} mc_err_cnt_t;

localparam MC_ERR_CNT_WIDTH = $bits(mc_err_cnt_t); //149;
  

endpackage : mc_ecc_pkg
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "0Z4gtymrRqkvvrdYaOSvdFTql+7FIwsI2jZJvE1KO3u7dqs1ZRaFzmO1jfFEc7znhwTAiO1KBSKrP987+SAzGd5SvXIQx6xI0AW8nwFvG6JF+1q0i0mnazpK1aymFzJFUNNl0aG5+UK6Rq82vQKPWNYiGGa9HAwpFBwP56gqubM1VmjZQDnsh8vHSOG8UUlus/z3DVPAFn39Q+wG6oF7rQvO7O2RFEn7+ZeC5J/0D0tKCkpLMZZY4XMV3E2+CWQE9o/myej8s6kXTtlnEfkmRvHv5fQY101dgsvsdA1Io66WM8mU9vvB4GGnRlVnU3kf6jKTkRr3B8gK7qk2l5+dNwRSMR7BxikYsTDEmjkYA4cs+4PUtwQZZGHKwr3uRoN68uiLq5NkSCc2VfNfzDXZrZNBAHvhnXTmbYnRqd2GYfD67a8WIidmL7Ij967BXFsMGLnQ91IgNMmVLty9neZy6IcdslLnhBt48SwZa4AmipgX0/aZzpLQ+ana5TZ+uLKgyepDk0N3nyDMWXTafHqfEAA/ckyfVnmJ/jrZBmZtAXZwxmhnvmiAGEn0NzCh6nHyByM+aUapzX5raWZyyl99WP24olzT81RLYqbchH6WlcMTjuplJhWUrIeJWe1PrMcAgtm/bzTG4/VU0+KPmt3hj0Eu5BSxjgI2lb0t9eufmUJae53RwooVT5UxLEu9zYVqKAghcsJgQxpiQoceiDdvJwdvf4LqraSuv3zofxX5veUupG73XqYt/dsiUJYUtztyqCkE9yC2ccaJekQlw+ZpjJDm3AjCMfcMWl24g6KMqVEAagjO3Iy7eT7tYubM3oMRIcox6WQ3mf0uurEorXGEZU5STAOTQGhwmBwoFPRlWoV2sh0ziVM81SIIpuCXjxKvAjbXA9PcUllf476FE2sxU9oPU6Rqsc3l5m57vNeLHTccD7P03s/VBjaZSbw8k9p5tC3CWy6ROzLvSs9WYpTrSY8V7wobL3tglQ1wGptoGX4m1DRYmhBjaxy7drVKJ/Ia"
`endif