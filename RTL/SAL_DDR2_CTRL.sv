`timescale 1ns/1ps

`include "SAL_DDR2_PARAMS.svh"

module SAL_DDR2_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // APB interface
    APB_IF                      apb_if,

    // AXI interface
    AXI_A_IF                    axi_ar_if,
    AXI_A_IF                    axi_aw_if,
    AXI_W_IF                    axi_w_if,
    AXI_B_IF                    axi_b_if,
    AXI_R_IF                    axi_r_if,

    // DFI interface
    DFI_CTRL_IF                 dfi_ctrl_if,
    DFI_WR_IF                   dfi_wr_if,
    DFI_RD_IF                   dfi_rd_if
);

    BK_REQ_IF                   bk_req_if_arr[`DRAM_BK_CNT] (.*);
    BK_SCHED_IF                 bk_sched_if_arr[`DRAM_BK_CNT] (.*);
    BK_TIMING_IF                bk_timing_if (.*);
    SCHED_TIMING_IF             sched_timing_if (.*);

    SAL_CFG                         u_cfg
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .apb_if                     (apb_if),

        .bk_timing_if               (bk_timing_if),
        .sched_timing_if            (sched_timing_if)
    );

    SAL_ADDR_DECODER                u_decoder
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .icnt_axi_a_if              (axi_ar_if),
        .bk_req_if_arr              (bk_req_if_arr)
    );

    genvar geni;

    generate
    for (geni=0; geni<`DRAM_BK_CNT; geni=geni+1) begin: bk_ctrl
        SAL_BK_CTRL                 u_bank_ctrl
        (
            .clk                        (clk),
            .rst_n                      (rst_n),

            .bk_req_if                  (bk_req_if_arr[geni]),
            .bk_timing_if               (bk_timing_if),
            .bk_sched_if                (bk_sched_if_arr[geni]),

            .pb_ref_req_i               (1'b0),
            .pb_ref_gnt_o               ()
        );
    end
    endgenerate

    SAL_SCHED                   u_sched
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .bk_sched_if                (bk_sched_if_arr),
        .dfi_ctrl_if                (dfi_ctrl_if)
    );

endmodule // SAL_DDR2_CTRL
