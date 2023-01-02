`timescale 1ns/1ps

`include "SAL_DDR2_PARAMS.svh"

module SAL_DDR2_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // APB interface
    APB_INTF                    apb_intf,

    // AXI interface
    AXI_A_INTF                  axi_ar_intf,
    AXI_A_INTF                  axi_aw_intf,
    AXI_W_INTF                  axi_w_intf,
    AXI_B_INTF                  axi_b_intf,
    AXI_R_INTF                  axi_r_intf,

    // DFI interface
    DFI_CTRL_INTF               dfi_ctrl_intf,
    DFI_RD_INTF                 dfi_rd_intf
);

    BK_REQ_INTF                 bk_req_intf_arr[`DRAM_BK_CNT];
    BK_SCHED_INTF               bk_sched_intf_arr[`DRAM_BK_CNT];

    SAL_ADDR_DECODER            u_decoder
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .icnt_axi_a_intf            (axi_ar_intf),
        .bk_req_intf_arr            (bk_req_intf_arr)
    );

    genvar geni;

    generate
    for (geni=0; geni<`DRAM_BK_CNT; geni=geni+1) begin: bk_ctrl
        SAL_BK_CTRL                 u_bank_ctrl
        (
            .clk                        (clk),
            .rst_n                      (rst_n),

            .bk_req_intf                (bk_req_intf_arr[geni]),
            .bk_sched_intf              (bk_sched_intf_arr[geni])
        );
    end
    endgenerate

    SAL_SCHED                   u_sched
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .sched_intf                 (bk_sched_intf_arr),
        .dfi_ctrl_intf              (dfi_ctrl_intf)
    );

endmodule // SAL_DDR2_CTRL
