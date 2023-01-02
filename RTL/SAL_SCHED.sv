`timescale 1ns/1ps

`include "SAL_DDR2_PARAMS.svh"

module SAL_SCHED
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // requests from banks
    BK_SCHED_INTF               bk_sched_intf[`DRAM_BK_CNT],

    DFI_CTRL_INTF               dfi_ctrl_intf
);

    always_comb begin
        // priority 1: (row miss) precharge
        // priority 2: read/write
    end

endmodule
