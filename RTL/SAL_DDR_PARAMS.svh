`ifndef __SAL_DDR_TYPEDEF_SVH__
`define __SAL_DDR_TYPEDEF_SVH__

// for simulation only
`define CLK_PERIOD                              2.5

// AXI interface
`define AXI_ADDR_WIDTH                          32
`define AXI_DATA_WIDTH                          128
`define AXI_ID_WIDTH                            4

// DFI interface
`define DFI_CS_WIDTH                            2
`define DFI_BA_WIDTH                            2
`define DFI_ADDR_WIDTH                          14

// DRAM interface
`define DRAM_RA_WIDTH                           13
`define DRAM_CA_WIDTH                           8

`define DRAM_CS_WIDTH                           `DFI_CS_WIDTH
`define DRAM_BA_WIDTH                           `DFI_BA_WIDTH
`define DRAM_ADDR_WIDTH                         `DFI_ADDR_WIDTH

// DRAM timing
`define T_RCD_WIDTH                             3
`define T_RCD_VALUE                             3'b011
`define T_RP_WIDTH                              3
`define T_RP_VALUE                              3'b011
`define T_RAS_WIDTH                             5
`define T_RAS_VALUE                             5'b01001
`define T_RFC_WIDTH                             8
`define T_RFC_VALUE                             8'b00011001
`define T_RTP_WIDTH                             3
`define T_RTP_VALUE                             3'b001
`define T_WTP_WIDTH                             4
`define T_WTP_VALUE                             4'b1000     // FIXME
`define T_RRD_WIDTH                             4
`define T_RRD_VALUE                             4'b011
`define T_CCD_WIDTH                             2
`define T_CCD_VALUE                             2'b01
`define T_WTR_WIDTH                             8
`define T_WTR_VALUE                             8'd1
`define T_RTW_WIDTH                             8
`define T_RTW_VALUE                             8'd1

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

`endif /* __SAL_DDR_TYPEDEF_SVH__ */
