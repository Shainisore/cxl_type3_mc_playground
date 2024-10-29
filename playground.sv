module playground (
    input  logic 				                       refclk;
    input  logic 				                       refclk0;
    input  logic 				                       ip2hdm_reset_n;        // SIP RST 
    input  mc_axi_if_pkg::t_to_mc_axi4                 iafu2mc_to_mc_axi4;   
    output mc_axi_if_pkg::t_from_mc_axi4               mc2iafu_from_mc_axi4; 
    output logic [cxlip_top_pkg::MEMSIZE_WIDTH-1:0]    mc2ip_memsize_s     // total memory size from mc_top
);

logic                ip2hdm_clk;             // SIP clk       mctop use this clk
assign               ip2hdm_clk = refclk0;
always_ff@(posedge ip2hdm_clk) ip2hdm_reset_n_f <= ip2hdm_reset_n ;
always_ff@(posedge ip2hdm_clk) ip2hdm_reset_n_ff <= ip2hdm_reset_n_f ;      //mctop use this for reset_n_eclk

logic [cxlip_top_pkg::MC_CHANNEL-1:0]                                                  mem_refclk     ;                                    
logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_CK_WIDTH-1:0]          mem_ck         ; 
logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_CK_WIDTH-1:0]          mem_ck_n       ;
logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_ADDR_WIDTH-1:0]        mem_a          ;
logic [cxlip_top_pkg::MC_CHANNEL-1:0]                                                  mem_act_n      ;                                   
logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_BA_WIDTH-1:0]          mem_ba         ;
logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_BG_WIDTH-1:0]          mem_bg         ;
logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_CKE_WIDTH-1:0]         mem_cke        ;
logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_CS_WIDTH-1:0]          mem_cs_n       ;
logic [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_ODT_WIDTH-1:0]         mem_odt        ;
logic [cxlip_top_pkg::MC_CHANNEL-1:0]                                                  mem_reset_n    ;                                 
logic [cxlip_top_pkg::MC_CHANNEL-1:0]                                                  mem_par        ;                                     
logic [cxlip_top_pkg::MC_CHANNEL-1:0]                                                  mem_oct_rzqin  ;                               
logic [cxlip_top_pkg::MC_CHANNEL-1:0]                                                  mem_alert_n    ;                                 
wire  [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_DQS_WIDTH-1:0]         mem_dqs        ;
wire  [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_DQS_WIDTH-1:0]         mem_dqs_n      ;
wire  [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_DQ_WIDTH-1:0]          mem_dq         ;
`ifdef ENABLE_DDR_DBI_PINS
    wire  [cxlip_top_pkg::MC_CHANNEL-1:0][cxlip_top_pkg::MC_HA_DDR4_DBI_WIDTH-1:0]     mem_dbi_n      ;
`endif//ENABLE_DDR_DBI_PINS

assign mem_oct_rzqin  = '0;
assign mem_refclk = refclk;

// ddr memory
ed_sim_mem ed_sim_mem_0 (
    .mem_ck        (mem_ck),
    .mem_ck_n      (mem_ck_n),
    .mem_a         (mem_a),
    .mem_act_n     (mem_act_n),
    .mem_ba        (mem_ba),
    .mem_bg        (mem_bg),
    .mem_cke       (mem_cke),
    .mem_cs_n      (mem_cs_n),
    .mem_odt       (mem_odt),
    .mem_reset_n   (mem_reset_n),
    .mem_par       (mem_par),
    .mem_alert_n   (mem_alert_n),
    .mem_dqs       (mem_dqs),
    .mem_dqs_n     (mem_dqs_n),
    .mem_dq        (mem_dq)
    `ifdef ENABLE_DDR_DBI_PINS
        ,.mem_dbi_n     (mem_dbi_n)
    `endif//ENABLE_DDR_DBI_PINS
);

mc_top #(
    .MC_CHANNEL               (cxlip_top_pkg::DDR_CHANNEL             ),
    .MC_HA_DDR4_ADDR_WIDTH    (cxlip_top_pkg::MC_HA_DDR4_ADDR_WIDTH   ),
    .MC_HA_DDR4_BA_WIDTH      (cxlip_top_pkg::MC_HA_DDR4_BA_WIDTH     ),
    .MC_HA_DDR4_BG_WIDTH      (cxlip_top_pkg::MC_HA_DDR4_BG_WIDTH     ),
    .MC_HA_DDR4_CK_WIDTH      (cxlip_top_pkg::MC_HA_DDR4_CK_WIDTH     ),
    .MC_HA_DDR4_CKE_WIDTH     (cxlip_top_pkg::MC_HA_DDR4_CKE_WIDTH    ),
    .MC_HA_DDR4_CS_WIDTH      (cxlip_top_pkg::MC_HA_DDR4_CS_WIDTH     ),
    .MC_HA_DDR4_ODT_WIDTH     (cxlip_top_pkg::MC_HA_DDR4_ODT_WIDTH    ),
    .MC_HA_DDR4_DQS_WIDTH     (cxlip_top_pkg::MC_HA_DDR4_DQS_WIDTH    ),
    .MC_HA_DDR4_DQ_WIDTH      (cxlip_top_pkg::MC_HA_DDR4_DQ_WIDTH     ),
    `ifdef ENABLE_DDR_DBI_PINS
    .MC_HA_DDR4_DBI_WIDTH     (cxlip_top_pkg::MC_HA_DDR4_DBI_WIDTH    ),
    `endif  
    .EMIF_AMM_ADDR_WIDTH      (cxlip_top_pkg::EMIF_AMM_ADDR_WIDTH     ),
    .EMIF_AMM_DATA_WIDTH      (cxlip_top_pkg::EMIF_AMM_DATA_WIDTH     ),
    .EMIF_AMM_BURST_WIDTH     (cxlip_top_pkg::EMIF_AMM_BURST_WIDTH    ),
    .EMIF_AMM_BE_WIDTH        (cxlip_top_pkg::EMIF_AMM_BE_WIDTH       ),
    .REG_ON_REQFIFO_INPUT_EN  (cxlip_top_pkg::REG_ON_REQFIFO_INPUT_EN ),
    .REG_ON_REQFIFO_OUTPUT_EN (cxlip_top_pkg::REG_ON_REQFIFO_OUTPUT_EN),
    .REG_ON_RSPFIFO_OUTPUT_EN (cxlip_top_pkg::REG_ON_RSPFIFO_OUTPUT_EN),
    .MC_HA_DP_ADDR_WIDTH      (cxlip_top_pkg::MC_HA_DP_ADDR_WIDTH     ),
    .MC_HA_DP_DATA_WIDTH      (cxlip_top_pkg::MC_HA_DP_DATA_WIDTH     ),
    .MC_ECC_EN                (cxlip_top_pkg::MC_ECC_EN               ),
    .MC_ECC_ENC_LATENCY       (cxlip_top_pkg::MC_ECC_ENC_LATENCY      ),
    .MC_ECC_DEC_LATENCY       (cxlip_top_pkg::MC_ECC_DEC_LATENCY      ),
    .MC_RAM_INIT_W_ZERO_EN    (cxlip_top_pkg::MC_RAM_INIT_W_ZERO_EN   ),
    .MEMSIZE_WIDTH            (cxlip_top_pkg::MEMSIZE_WIDTH           ),
    .FULL_ADDR_MSB            (cxlip_top_pkg::CXLIP_FULL_ADDR_MSB     ),
    .FULL_ADDR_LSB            (cxlip_top_pkg::CXLIP_FULL_ADDR_LSB     ),
    .CHAN_ADDR_MSB            (cxlip_top_pkg::CXLIP_CHAN_ADDR_MSB     ),
    .CHAN_ADDR_LSB            (cxlip_top_pkg::CXLIP_CHAN_ADDR_LSB     )
)
mc_top (
    .eclk                            (ip2hdm_clk),                        // input,  CXL-IP Slice clock
    .reset_n_eclk                    (ip2hdm_reset_n_ff),                    // input,  CXL-IP Slice reset_n
    .mc2ha_memsize                   (mc2ip_memsize_s),                        // output, Size (in bytes) of memory exposed to BIOS
    // .mc_sr_status_eclk               (mc_sr_status_eclk),     // output, Memory Controller Status 

    // `ifdef OOORSP_MC_NOCDCFIFOS
    //   .o_emif_usr_clk   ( emif_usr_clk ),
    //   .o_emif_usr_rst_n ( emif_usr_rst_n ),
    // `endif

    .iafu2mc_to_mc_axi4              ( iafu2mc_to_mc_axi4            ),
    .mc2iafu_from_mc_axi4            ( mc2iafu_from_mc_axi4          ),

    .mc_err_cnt                      (                               ), // output, SBE/DBE CNT

    // == DDR4 Interface ==
    .mem_refclk                      (mem_refclk                     ), // input,  EMIF PLL reference clock
    .mem_ck                          (mem_ck                         ), // output, DDR4 interface signals
    .mem_ck_n                        (mem_ck_n                       ), // output
    .mem_a                           (mem_a                          ), // output
    .mem_act_n                       (mem_act_n                      ), // output
    .mem_ba                          (mem_ba                         ), // output
    .mem_bg                          (mem_bg                         ), // output
    .mem_cke                         (mem_cke                        ), // output
    .mem_cs_n                        (mem_cs_n                       ), // output
    .mem_odt                         (mem_odt                        ), // output
    .mem_reset_n                     (mem_reset_n                    ), // output
    .mem_par                         (mem_par                        ), // output
    .mem_oct_rzqin                   (mem_oct_rzqin                  ), // input
    .mem_alert_n                     (mem_alert_n                    ), // input
    .mem_dqs                         (mem_dqs                        ), // inout
    .mem_dqs_n                       (mem_dqs_n                      ), // inout
    .mem_dq                          (mem_dq                         )  // inout
    `ifdef ENABLE_DDR_DBI_PINS
    ,.mem_dbi_n                      (mem_dbi_n                      )  // inout
    `endif
);  

endmodule
