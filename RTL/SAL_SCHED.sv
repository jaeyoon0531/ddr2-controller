`timescale 1ns/1ps

`include "SAL_DDR2_PARAMS.svh"

module SAL_SCHED
(
    // clock & reset
    input                       clk,
    input                       rst,

    // requests from banks
    BK_SCHED_INTF               bk_sched_intf[`BK_CNT]

    DFI_CTRL_INTF               dfi_ctrl_intf
);

endmodule
