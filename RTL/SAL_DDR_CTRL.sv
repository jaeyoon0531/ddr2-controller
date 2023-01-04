`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_DDR_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // APB interface
    APB_IF.DST                  apb_if,

    // AXI interface
    AXI_A_IF.DST                axi_ar_if,
    AXI_A_IF.DST                axi_aw_if,
    AXI_W_IF.DST                axi_w_if,
    AXI_B_IF.SRC                axi_b_if,
    AXI_R_IF.SRC                axi_r_if,

    // DFI interface
    DFI_CTRL_IF.SRC             dfi_ctrl_if,
    DFI_WR_IF.SRC               dfi_wr_if,
    DFI_RD_IF.DST               dfi_rd_if
);

    // timing parameters
    TIMING_IF                   timing_if();

    // request to a bank
    BK_REQ_IF                   bk_req_if();
    // scheduling output
    SCHED_IF                    sched_if();

    // Configurations
    SAL_CFG                         u_cfg
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .apb_if                     (apb_if),

        .timing_if                  (timing_if)
    );

    SAL_ADDR_DECODER                u_decoder
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .axi_ar_if                  (axi_ar_if),
        .axi_aw_if                  (axi_aw_if),
        .axi_w_if                   (axi_w_if),

        .bk_req_if                  (bk_req_if)
    );

    SAL_BK_CTRL                     u_bank_ctrl
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .timing_if                  (timing_if),

        .bk_req_if                  (bk_req_if),
        .sched_if                   (sched_if),

        .ref_req_i                  (1'b0),
        .ref_gnt_o                  ()
    );

    SAL_CTRL_ENCODER                u_encoder
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .sched_if                   (sched_if),
        .dfi_ctrl_if                (dfi_ctrl_if)
    );

    SAL_WR_CTRL                     u_wr_ctrl
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .timing_if                  (timing_if),
        .sched_if                   (sched_if),

        .axi_w_if                   (axi_w_if),
        .axi_b_if                   (axi_b_if),
        .dfi_wr_if                  (dfi_wr_if)
    );

    SAL_RD_CTRL                     u_rd_ctrl
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .timing_if                  (timing_if),
        .sched_if                   (sched_if),
        .dfi_rd_if                  (dfi_rd_if),
        .axi_r_if                   (axi_r_if)
    );
    /*
    genvar geni;

    generate
    for (geni=0; geni<`DRAM_BK_CNT; geni=geni+1) begin: bk_ctrl
        SAL_BK_CTRL                 u_bank_ctrl
        (
            .clk                        (clk),
            .rst_n                      (rst_n),

            .bk_req_if                  (bk_req_if_arr[geni]),
            .bk_timing_if               (bk_timing_if),
            .sched_timing_if            (sched_timing_if),
            .dfi_ctrl_if                (dfi_ctrl_if),

            .ref_req_i                  (1'b0),
            .ref_gnt_o                  ()
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
    */

endmodule // SAL_DDR_CTRL
