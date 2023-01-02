interface DFI_INTF
(
    input                       clk,
    input                       rst_n
);
endinterface

interface BK_REQ_INTF
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

interface BK_TIMING_INTF
(
    input                       clk,
    input                       rst_n
);
    logic   [`T_RCD_WIDTH-1:0]  t_rcd;
    logic   [`T_RP_WIDTH-1:0]   t_rp;
    logic   [`T_RAS_WIDTH-1:0]  t_ras;
    logic   [7:0]               t_rfc;
    //logic [3:0]               t_wtr;
    //logic [3:0]               t_rtw;
    logic   [3:0]               t_rtp;
    logic   [3:0]               t_wtp;

endinterface

interface BK_SCHED_INTF
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

endinterface

