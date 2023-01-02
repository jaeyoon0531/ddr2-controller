`include "TIME_SCALE.svh"
`include "SAL_DDR2_PARAMS.svh"

interface DFI_CTRL_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       cke;
    logic   [`DFI_CS_WIDTH-1:0] cs_n;
    logic                       ras_n;
    logic                       cas_n;
    logic                       we_n;
    logic   [`DFI_BA_WIDTH-1:0] ba;
    logic   [`DFI_ADDR_WIDTH-1:0]   addr;
    logic                       odt;

    // synthesizable, for design
    modport                     SRC (
        output                      cke, cs_n, ras_n, cas_n, we_n, ba, addr, odt
    );

    modport                     DST (
        input                       cke, cs_n, ras_n, cas_n, we_n, ba, addr, odt
    );

endinterface

interface DFI_WR_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       wrdata_en;
    logic   [63:0]              wrdata;
    logic   [7:0]               wrdata_mask;

    // synthesizable, for design
    modport                     SRC (
        output                      wrdata_en, wrdata, wrdata_mask
    );

    modport                     DST (
        input                       wrdata_en, wrdata, wrdata_mask
    );
endinterface

interface DFI_RD_IF
(
    input                       clk,
    input                       rst_n
);
    // synthesizable, for design
    modport                     SRC (
    );

    modport                     DST (
    );
endinterface

interface BK_REQ_IF
(
    input                       clk,
    input                       rst_n
);
    logic                       valid;
    logic                       ready;
    logic   [`AXI_ID_WIDTH-1:0] id;
    logic   [`DRAM_RA_WIDTH-1:0]ra;
    logic   [`DRAM_CA_WIDTH-1:0]ca;
    logic   [3:0]               len;
    logic                       wr;

endinterface

interface BK_TIMING_IF ();
    logic   [`T_RCD_WIDTH-1:0]  t_rcd;
    logic   [`T_RP_WIDTH-1:0]   t_rp;
    logic   [`T_RAS_WIDTH-1:0]  t_ras;
    logic   [`T_RFC_WIDTH-1:0]  t_rfc;
    logic   [`T_RTP_WIDTH-1:0]  t_rtp;
    logic   [`T_WTP_WIDTH-1:0]  t_wtp;

endinterface

interface SCHED_TIMING_IF ();
    logic   [`T_RRD_WIDTH-1:0]  t_rrd;
    logic   [`T_CCD_WIDTH-1:0]  t_ccd;
    logic   [`T_WTR_WIDTH-1:0]  t_wtr;
    logic   [`T_RTW_WIDTH-1:0]  t_rtw;

endinterface

interface BK_SCHED_IF
(
    input                       clk,
    input                       rst_n
);
    logic   [`DRAM_RA_WIDTH-1:0]ra;
    logic   [`DRAM_CA_WIDTH-1:0]ca;
    logic                       act_req;
    logic                       rd_req;
    logic                       wr_req;
    logic                       pre_req;
    logic                       ref_req;
    logic                       act_gnt;
    logic                       rd_gnt;
    logic                       wr_gnt;
    logic                       pre_gnt;
    logic                       ref_gnt;

endinterface

