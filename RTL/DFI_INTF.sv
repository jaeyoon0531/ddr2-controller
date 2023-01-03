`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

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
    logic   [127:0]             wrdata;
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
    logic                       rddata_en;
    logic   [127:0]             rddata;
    logic                       rddata_valid;
    logic   [7:0]               rddata_dnv;


    // synthesizable, for design
    modport                     SRC (
        output                      rddata, rddata_valid, rddata_dnv,
        input                       rddata_en
    );

    modport                     DST (
        input                       rddata, rddata_valid, rddata_dnv,
        output                      rddata_en
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

    // synthesizable, for design
    modport SRC (
        output                  valid, id, ra, ca, len, wr,
        input                   ready
    );
    modport DST (
        input                   valid, id, ra, ca, len, wr,
        output                  ready
    );
endinterface

interface BK_TIMING_IF ();
    logic   [`T_RCD_WIDTH-1:0]  t_rcd_m1;
    logic   [`T_RP_WIDTH-1:0]   t_rp_m1;
    logic   [`T_RAS_WIDTH-1:0]  t_ras_m1;
    logic   [`T_RFC_WIDTH-1:0]  t_rfc_m1;
    logic   [`T_RTP_WIDTH-1:0]  t_rtp_m1;
    logic   [`T_WTP_WIDTH-1:0]  t_wtp_m1;

    // synthesizable, for design
    modport SRC (
        output                  t_rcd_m1, t_rp_m1, t_ras_m1, t_rfc_m1, t_rtp_m1, t_wtp_m1
    );
    modport MON (
        input                   t_rcd_m1, t_rp_m1, t_ras_m1, t_rfc_m1, t_rtp_m1, t_wtp_m1
    );
endinterface

interface SCHED_TIMING_IF ();
    logic   [`T_RRD_WIDTH-1:0]  t_rrd_m1;
    logic   [`T_CCD_WIDTH-1:0]  t_ccd_m1;
    logic   [`T_WTR_WIDTH-1:0]  t_wtr_m1;
    logic   [`T_RTW_WIDTH-1:0]  t_rtw_m1;
    logic   [3:0]               dfi_wren_lat;
    logic   [3:0]               dfi_rden_lat;

    // synthesizable, for design
    modport SRC (
        output                  t_rrd_m1, t_ccd_m1, t_wtr_m1, t_rtw_m1, dfi_wren_lat, dfi_rden_lat
    );
    modport MON (
        input                   t_rrd_m1, t_ccd_m1, t_wtr_m1, t_rtw_m1, dfi_wren_lat, dfi_rden_lat
    );
endinterface

interface SCHED_IF
(
    input                       clk,
    input                       rst_n
);
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
    logic   [`DRAM_BA_WIDTH-1:0]ba;
    logic   [`DRAM_RA_WIDTH-1:0]ra;
    logic   [`DRAM_CA_WIDTH-1:0]ca;
    logic   [`AXI_ID_WIDTH-1:0] id;

    // synthesizable, for design
    modport SRC (
        output                  act_req, rd_req, wr_req, pre_req, ref_req, ba, ra, ca, id,
        input                   act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
    modport DST (
        input                   act_req, rd_req, wr_req, pre_req, ref_req, ba, ra, ca, id,
        output                  act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
    modport MON (
        input                   act_req, rd_req, wr_req, pre_req, ref_req, ba, ra, ca, id,
        input                   act_gnt, rd_gnt, wr_gnt, pre_gnt, ref_gnt
    );
endinterface

