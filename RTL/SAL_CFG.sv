`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_CFG
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // APB interface
    APB_IF.DST                  apb_if,

    // timing parameters
    BK_TIMING_IF.SRC            bk_timing_if,
    SCHED_TIMING_IF.SRC         sched_timing_if
);

    assign  bk_timing_if.t_rcd_m1   = `T_RCD_VALUE_M1;
    assign  bk_timing_if.t_rp_m1    = `T_RP_VALUE_M1;
    assign  bk_timing_if.t_ras_m1   = `T_RAS_VALUE_M1;
    assign  bk_timing_if.t_rfc_m1   = `T_RFC_VALUE_M1;
    assign  bk_timing_if.t_rtp_m1   = `T_RTP_VALUE_M1;
    assign  bk_timing_if.t_wtp_m1   = `T_WTP_VALUE_M1;

    assign  sched_timing_if.t_rrd_m1= `T_RRD_VALUE_M1;
    assign  sched_timing_if.t_ccd_m1= `T_CCD_VALUE_M1;
    assign  sched_timing_if.t_wtr_m1= `T_WTR_VALUE_M1;
    assign  sched_timing_if.t_rtw_m1= `T_RTW_VALUE_M1;
    assign  sched_timing_if.dfi_wren_lat = 4'd3;
    assign  sched_timing_if.dfi_rden_lat = 4'd6;

endmodule
