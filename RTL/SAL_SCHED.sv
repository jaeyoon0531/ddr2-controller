`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_SCHED
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // requests from banks
    BK_SCHED_IF                 bk_sched_if[`DRAM_BK_CNT],

    DFI_CTRL_IF.SRC             dfi_ctrl_if
);

    always_comb begin
        bk_sched_if[0].act_gnt          = bk_sched_if[0].act_req;
        bk_sched_if[0].rd_gnt           = bk_sched_if[0].rd_req;
        bk_sched_if[0].wr_gnt           = bk_sched_if[0].wr_req;
        bk_sched_if[0].pre_gnt          = bk_sched_if[0].pre_req;
        bk_sched_if[0].ref_gnt          = bk_sched_if[0].ref_req;

       /*
        bk_sched_if[0].act_gnt          = 1'b0;
        bk_sched_if[0].rd_gnt           = 1'b0;
        bk_sched_if[0].wr_gnt           = 1'b0;
        bk_sched_if[0].pre_gnt          = 1'b0;
        bk_sched_if[0].ref_gnt          = 1'b0;

        // priority 1: (row miss) precharge
        if (bk_sched_if[0].pre_req) begin
            bk_sched_if[0].pre_gnt        = 1'b1;
        end
        // priority 2: read/write
        else if (bk_sched_if[0].rd_req) begin
            bk_sched_if[0].rd_gnt         = 1'b1;
        end
        else if (bk_sched_if[0].wr_req) begin
            bk_sched_if[0].wr_gnt         = 1'b1;
        end
        else if (bk_sched_if[0].rd_req) begin
            bk_sched_if[0].pre_gnt        = 1'b1;
        end
        else if (bk_sched_if[0].act_req) begin
            bk_sched_if[0].act_gnt        = 1'b1;
        end
        else if (bk_sched_if[0].ref_req) begin
            bk_sched_if[0].ref_gnt        = 1'b1;
        end
        */
    end

endmodule
