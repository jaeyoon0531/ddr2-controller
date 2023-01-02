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
        /*
        bk_sched_intf[0].act_gnt        = 1'b0;
        bk_sched_intf[0].rd_gnt         = 1'b0;
        bk_sched_intf[0].wr_gnt         = 1'b0;
        bk_sched_intf[0].pre_gnt        = 1'b0;
        bk_sched_intf[0].ref_gnt        = 1'b0;
        */

        bk_sched_intf[0].act_gnt        = bk_sched_intf[0].act_req;
        bk_sched_intf[0].rd_gnt         = bk_sched_intf[0].rd_req;
        bk_sched_intf[0].wr_gnt         = bk_sched_intf[0].wr_req;
        bk_sched_intf[0].pre_gnt        = bk_sched_intf[0].pre_req;
        bk_sched_intf[0].ref_gnt        = bk_sched_intf[0].ref_req;
        
        /*
        // priority 1: (row miss) precharge
        if (bk_sched_intf[0].pre_req) begin
            bk_sched_intf[0].pre_gnt        = 1'b1;
        end
        // priority 2: read/write
        else if (bk_sched_intf[0].rd_req) begin
            bk_sched_intf[0].rd_gnt         = 1'b1;
        end
        else if (bk_sched_intf[0].wr_req) begin
            bk_sched_intf[0].wr_gnt         = 1'b1;
        end
        else if (bk_sched_intf[0].rd_req) begin
            bk_sched_intf[0].pre_gnt        = 1'b1;
        end
        else if (bk_sched_intf[0].act_req) begin
            bk_sched_intf[0].act_gnt        = 1'b1;
        end
        else if (bk_sched_intf[0].ref_req) begin
            bk_sched_intf[0].ref_gnt        = 1'b1;
        end
        */
    end

endmodule
