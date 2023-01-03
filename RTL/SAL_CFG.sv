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

    assign  bk_timing_if.t_rcd      = `T_RCD_VALUE;
    assign  bk_timing_if.t_rp       = `T_RP_VALUE;
    assign  bk_timing_if.t_ras      = `T_RAS_VALUE;
    assign  bk_timing_if.t_rfc      = `T_RFC_VALUE;
    assign  bk_timing_if.t_rtp      = `T_RTP_VALUE;
    assign  bk_timing_if.t_wtp      = `T_WTP_VALUE;

    assign  sched_timing_if.t_rrd   = `T_RRD_VALUE;
    assign  sched_timing_if.t_ccd   = `T_CCD_VALUE;
    assign  sched_timing_if.t_wtr   = `T_WTR_VALUE;
    assign  sched_timing_if.t_rtw   = `T_RTW_VALUE;

endmodule
