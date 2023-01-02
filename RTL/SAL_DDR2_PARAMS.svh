// AXI parameters
`include "AXI_TYPEDEFS.svh"

// DRAM interfaces
`define DRAM_BA_WIDTH                           0
`define DRAM_RA_WIDTH                           13
`define DRAM_CA_WIDTH                           8


`define T_RCD_WIDTH                             3
`define T_RP_WIDTH                              3
`define T_RAS_WIDTH                             5
`define T_RFC_WIDTH                             8
`define T_RTP_WIDTH                             4
`define T_WTP_WIDTH                             4
`define T_RRD_WIDTH                             4
`define T_CCD_WIDTH                             4
`define T_WTR_WIDTH                             8
`define T_RTW_WIDTH                             8

// derived parameters
`define DRAM_BK_CNT                             1<<`DRAM_BA_WIDTH

function [`DRAM_BA_WIDTH-1:0] get_dram_ba(input [`AXI_ADDR_WIDTH-1:0] addr);
    return 'd0;
endfunction

function [`DRAM_RA_WIDTH-1:0] get_dram_ra(input [`AXI_ADDR_WIDTH-1:0] addr);
    return addr[`DRAM_CA_WIDTH+:`DRAM_RA_WIDTH];
endfunction

function [`DRAM_CA_WIDTH-1:0] get_dram_ca(input [`AXI_ADDR_WIDTH-1:0] addr);
    return addr[`DRAM_CA_WIDTH-1:0];
endfunction

