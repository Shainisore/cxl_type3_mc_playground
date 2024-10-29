module testbench;

    // Testbench signals
    logic 				                       refclk;                      // input 
    logic 				                       refclk0;                     // input 
    logic 				                       ip2hdm_reset_n;              // input 
    mc_axi_if_pkg::t_to_mc_axi4                iafu2mc_to_mc_axi4;          // input 
    mc_axi_if_pkg::t_from_mc_axi4              mc2iafu_from_mc_axi4;        // output
    logic [cxlip_top_pkg::MEMSIZE_WIDTH-1:0]   mc2ip_memsize_s;             // output

    always begin : CLK_GEN0
        refclk0 = 0;
        forever #5ns refclk0 = ~refclk0;
    end : CLK_GEN0

    always begin : CLK_GEN
        refclk = 0;
        forever #15ns refclk = ~refclk;
    end : CLK_GEN

    playground (
        .refclk(refclk),
        .refclk0(refclk0),
        .ip2hdm_reset_n(ip2hdm_reset_n),
        .iafu2mc_to_mc_axi4(iafu2mc_to_mc_axi4),
        .mc2iafu_from_mc_axi4(mc2iafu_from_mc_axi4),
        .mc2ip_memsize_s(mc2ip_memsize_s)
    ); 

    initial begin
        $display("Test case");

        $finish;
    end
endmodule

