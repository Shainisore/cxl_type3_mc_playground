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

module mc_rmw_shim #(
  parameter  ADDR_WIDTH         = 46,
  parameter  DATA_WIDTH         = 512,
  parameter  ALTECC_INST_NUMBER = 8,
  // == REG_ON_RMW_RD_DATA_INPUT_EN = 1 Improves timing with impact of additional
  // == 1 clk latency on RMW transactions (normal reads and writes are NOT affected)
  parameter  REG_ON_RMW_RD_DATA_INPUT_EN = 1, // 0 - OFF; 1 - ON

  localparam SYMBOL_WIDTH       = 8,
  localparam BE_WIDTH           = DATA_WIDTH / SYMBOL_WIDTH
)
(
input  logic                  mem_clk                   ,  // EMIF User Clock
input  logic                  mem_reset_n               ,  // EMIF reset

output logic                  mem_ready_ha_mclk         ,  //  width = 1,
input  logic                  mem_read_ha_mclk          ,  //  width = 1,
input  logic                  mem_write_ha_mclk         ,  //  width = 1,
input  logic                  mem_write_poison_ha_mclk  ,  //  width = 1,
input  logic                  mem_write_partial_ha_mclk ,  //  width = 1,
input  logic [ADDR_WIDTH-1:0] mem_address_ha_mclk       ,  //  width = 46,
input  logic [DATA_WIDTH-1:0] mem_writedata_ha_mclk     ,  //  width = 512,
input  logic [BE_WIDTH-1:0]   mem_byteenable_ha_mclk    ,  //  width = 64,
output logic [DATA_WIDTH-1:0] mem_readdata_ha_mclk      ,  //  width = 512,
output logic                  mem_read_poison_ha_mclk   ,  //  width = 1,
output logic                  mem_readdatavalid_ha_mclk ,  //  width = 1,
// Error Correction Code (ECC)
// Note *ecc_err_* are valid when mem_ecc_err_valid_ha_mclk == 1
// If both mem_readdatavalid_ha_mclk == 1 and mem_ecc_err_valid_ha_mclk == 1
//   then *ecc_err_* are related to mem_readdatavalid_ha_mclk
// If mem_readdatavalid_ha_mclk == 0 and mem_ecc_err_valid_ha_mclk == 1
//   then *ecc_err_* are related to partial write. "Partial write" functionality is realised as read-modify-write function.
//   Readdata for this read is kept internal (not visible on module output), but ECC statuses are provided.
output logic [ALTECC_INST_NUMBER-1:0] mem_ecc_err_corrected_ha_mclk ,
output logic [ALTECC_INST_NUMBER-1:0] mem_ecc_err_detected_ha_mclk  ,
output logic [ALTECC_INST_NUMBER-1:0] mem_ecc_err_fatal_ha_mclk     ,
output logic [ALTECC_INST_NUMBER-1:0] mem_ecc_err_syn_e_ha_mclk     ,
output logic                          mem_ecc_err_valid_ha_mclk     ,

input  logic                  mem_ready_mclk            ,  //  width = 1,
output logic                  mem_read_mclk             ,  //  width = 1,
output logic                  mem_write_mclk            ,  //  width = 1,
output logic                  mem_write_poison_mclk     ,  //  width = 1,
output logic [ADDR_WIDTH-1:0] mem_address_mclk          ,  //  width = 46,
output logic [DATA_WIDTH-1:0] mem_writedata_mclk        ,  //  width = 512,
output logic [BE_WIDTH-1:0]   mem_byteenable_mclk       ,  //  width = 64,
input  logic [DATA_WIDTH-1:0] mem_readdata_mclk         ,  //  width = 512,
input  logic                  mem_read_poison_mclk      ,  //  width = 1,
input  logic                  mem_readdatavalid_mclk    ,  //  width = 1,
input  logic [ALTECC_INST_NUMBER-1:0] mem_ecc_err_corrected_mclk ,
input  logic [ALTECC_INST_NUMBER-1:0] mem_ecc_err_detected_mclk  ,
input  logic [ALTECC_INST_NUMBER-1:0] mem_ecc_err_fatal_mclk     ,
input  logic [ALTECC_INST_NUMBER-1:0] mem_ecc_err_syn_e_mclk
);

logic [DATA_WIDTH-1:0] rmw_data;
logic [5:0]   rd_cntr;
logic         rmw_write;
logic         rmw_poison;
logic         rmw_pending;

logic [DATA_WIDTH-1:0] mem_readdata_mclk_internal     ;
logic                  mem_read_poison_mclk_internal  ;
logic                  mem_readdatavalid_mclk_internal;

int i;

generate
  if (REG_ON_RMW_RD_DATA_INPUT_EN == 1) begin : reg_on_rmw_rd_data_input_on

    logic [DATA_WIDTH-1:0] mem_readdata_mclk_reg     ;
    logic                  mem_read_poison_mclk_reg  ;
    logic                  mem_readdatavalid_mclk_reg;

    always_ff @(posedge mem_clk) begin
      mem_readdata_mclk_reg      <= mem_readdata_mclk     ;
      mem_read_poison_mclk_reg   <= mem_read_poison_mclk  ;
      mem_readdatavalid_mclk_reg <= mem_readdatavalid_mclk;

      if (~mem_reset_n) begin
        mem_readdatavalid_mclk_reg <= '0;
      end
    end

    always_comb begin
      mem_readdata_mclk_internal      <= mem_readdata_mclk_reg     ;
      mem_read_poison_mclk_internal   <= mem_read_poison_mclk_reg  ;
      mem_readdatavalid_mclk_internal <= mem_readdatavalid_mclk_reg;
    end

  end
  else begin : reg_on_rmw_rd_data_input_off

    always_comb begin
      mem_readdata_mclk_internal      = mem_readdata_mclk     ;
      mem_read_poison_mclk_internal   = mem_read_poison_mclk  ;
      mem_readdatavalid_mclk_internal = mem_readdatavalid_mclk;
    end

  end
endgenerate

assign mem_readdata_ha_mclk      = mem_readdata_mclk       ;
assign mem_read_poison_ha_mclk   = mem_read_poison_mclk    ;

assign mem_ecc_err_corrected_ha_mclk = mem_ecc_err_corrected_mclk ;
assign mem_ecc_err_detected_ha_mclk  = mem_ecc_err_detected_mclk  ;
assign mem_ecc_err_fatal_ha_mclk     = mem_ecc_err_fatal_mclk     ;
assign mem_ecc_err_syn_e_ha_mclk     = mem_ecc_err_syn_e_mclk     ;

assign mem_byteenable_mclk       = '1;
assign mem_address_mclk          = mem_address_ha_mclk     ;

assign mem_ready_ha_mclk = mem_write_partial_ha_mclk ? mem_ready_mclk & rmw_write : mem_ready_mclk;   // Pop reqfifo
assign mem_readdatavalid_ha_mclk = mem_readdatavalid_mclk & ~(rmw_pending & (rd_cntr == 6'h1));
assign mem_ecc_err_valid_ha_mclk = mem_readdatavalid_mclk;

assign mem_write_mclk        = mem_write_partial_ha_mclk ? rmw_write  : mem_write_ha_mclk;
assign mem_writedata_mclk    = mem_write_partial_ha_mclk ? rmw_data   : mem_writedata_ha_mclk;
assign mem_write_poison_mclk = mem_write_partial_ha_mclk ? rmw_poison : mem_write_poison_ha_mclk;

assign mem_read_mclk = mem_write_partial_ha_mclk ? (~rmw_pending & ~rmw_write)  & (rd_cntr == 6'h0): mem_read_ha_mclk;

always_ff @(posedge mem_clk) begin
  if (~mem_reset_n)
    rd_cntr <= 6'h0;
  else begin
    if      (mem_ready_mclk & mem_read_mclk & ~mem_readdatavalid_mclk_internal)    rd_cntr <= rd_cntr + 6'h1;
    else if (mem_readdatavalid_mclk_internal & ~(mem_ready_mclk & mem_read_mclk))  rd_cntr <= rd_cntr - 6'h1;
  end
end

always_ff @(posedge mem_clk) begin
  if (mem_readdatavalid_mclk_internal)
    for (i=0; i<=BE_WIDTH-1; i=i+1)
      if (mem_byteenable_ha_mclk[i])
        rmw_data[i*SYMBOL_WIDTH +:SYMBOL_WIDTH] <= mem_writedata_ha_mclk[i*SYMBOL_WIDTH +:SYMBOL_WIDTH];
      else
        rmw_data[i*SYMBOL_WIDTH +:SYMBOL_WIDTH] <= mem_readdata_mclk_internal[i*SYMBOL_WIDTH +:SYMBOL_WIDTH];
end

always_ff @(posedge mem_clk) begin
  if (mem_readdatavalid_mclk_internal)
    rmw_poison <= mem_write_poison_ha_mclk | mem_read_poison_mclk_internal;
end

always_ff @(posedge mem_clk) begin
  if (~mem_reset_n) begin
    rmw_write   <= 1'b0;
    rmw_pending <= 1'b0;
  end
  else begin
    if (rmw_pending & mem_readdatavalid_mclk_internal & (rd_cntr == 6'h1)) begin
      rmw_write   <= 1'b1;
      rmw_pending <= 1'b0;
    end
    else if (mem_ready_mclk & mem_write_mclk)
      rmw_write <= 1'b0;

    if (mem_write_partial_ha_mclk & ~rmw_pending & mem_ready_mclk & ~rmw_write & (rd_cntr == 6'h0))
      rmw_pending <= 1'b1;
  end
end

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "0Z4gtymrRqkvvrdYaOSvdFTql+7FIwsI2jZJvE1KO3u7dqs1ZRaFzmO1jfFEc7znhwTAiO1KBSKrP987+SAzGd5SvXIQx6xI0AW8nwFvG6JF+1q0i0mnazpK1aymFzJFUNNl0aG5+UK6Rq82vQKPWNYiGGa9HAwpFBwP56gqubM1VmjZQDnsh8vHSOG8UUlus/z3DVPAFn39Q+wG6oF7rQvO7O2RFEn7+ZeC5J/0D0vGgQ7qR+PLvDEgrosuTN/YxABplUvsaT/gYClEz9zuhTltqSOuwYNTJmRMd71yDmR++cjxQH5+E2/qCOZdeQXvQaG28LV3tW6UoLZeU5UnWMEyrs8bUXl0CY+eN23pmWan/cR8idnt9Eis4RhfJdKmFUBhCrXrjluKAD1voqS9AIeaML0FbwC6yBJvkLwDsLkc+pXQYxcj4bi6v0lCiYxGwvkFAkkbJVDdKintth2DI2AilbfFrqfqnOBYDgpG5H/c8lnkXnufRrzqTELLYaN993DF2S/k40vboW/vGHQ8I1ccbH9FfI8GRPfVasApmUtMS1NjLcjH3dX6OqtO3t2QDE0ykZ1/Xrpli3taS0RxTD6HdW7uoHyRWBYw4IHM+gCyw1QdS+zb8W1UyooVmCXUKydRlZW4VBp6watmLYbWP2MKai+ULikdO+uFQQX8cPKqQgyIkye+MQoiA/2GufwuLC1jPAgKYAi6HESLoIrrFk/MNaRmkKmSp4at4VXuD2KqIQULaNUjf+kR6Rm9f6D3oOnBZNeKa9RuNqQI0bOfRrW/wRcvK0Nj5sb+Ek4mEg9xSd15Kna/ug0xAkQ3dWPK0B8HybnoCrqbWB9lBs/iYbyDeIdhAee8uSfiuDzXD+EI9vpVr9fVADyFcgmTMZEW63v9j7612kmQxX95qT5/sAxk+rj0BJwPcEpIBx2toyGQp5eMV680xstWh5wJdbmCnQwzwERplvM6zJUwGi0EXZjr6Lz9KoejZ2CnSf4s/FrKI8CUOAF3ei2c4WGdvvEW"
`endif