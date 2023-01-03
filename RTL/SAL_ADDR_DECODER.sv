`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_ADDR_DECODER
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // request from the AXI side
    AXI_A_IF.DST                axi_ar_if,
    AXI_A_IF.DST                axi_aw_if,
    AXI_W_IF                    axi_w_if,
    // request to bank controller
    BK_REQ_IF.SRC               bk_req_if_arr[`DRAM_BK_CNT]
);

    logic   [4:0]               wdata_trans_cnt,    wdata_trans_cnt_n;

    always_ff @(posedge clk)
        if (~rst_n) begin
            wdata_trans_cnt             <= 'd0;
        end
        else begin
            wdata_trans_cnt             <= wdata_trans_cnt_n;
        end

    logic                       aw_hs,      wlast_hs;
    always_comb begin
        aw_hs                   = axi_aw_if.avalid & axi_aw_if.aready;
        wlast_hs                = axi_w_if.wvalid & axi_w_if.wready & axi_w_if.wlast;

        if (~aw_hs & wlast_hs) begin
            wdata_trans_cnt_n           = wdata_trans_cnt + 'd1;
        end
        else if (aw_hs & ~wlast_hs) begin
            wdata_trans_cnt_n           = wdata_trans_cnt - 'd1;
        end
        else begin
            wdata_trans_cnt_n           = wdata_trans_cnt;
        end
    end

    always_comb begin
        // WR (addr/data) are ready
        if (axi_aw_if.avalid & (wdata_trans_cnt!='d0)) begin
            /*
            for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
                bk_req_if_arr[i].id     = axi_aw_if.aid;
                bk_req_if_arr[i].ra     = get_dram_ra(axi_aw_if.aaddr);
                bk_req_if_arr[i].ca     = get_dram_ca(axi_aw_if.aaddr);
                bk_req_if_arr[i].len    = axi_aw_if.alen;
                bk_req_if_arr[i].wr     = 1'b1;
            end
            */
            bk_req_if_arr[0].id     = axi_aw_if.aid;
            bk_req_if_arr[0].ra     = get_dram_ra(axi_aw_if.aaddr);
            bk_req_if_arr[0].ca     = get_dram_ca(axi_aw_if.aaddr);
            bk_req_if_arr[0].len    = axi_aw_if.alen;
            bk_req_if_arr[0].wr     = 1'b1;
            bk_req_if_arr[0].valid  = axi_aw_if.avalid;
            axi_aw_if.aready        = bk_req_if_arr[0].ready;
        end
        else
        begin
            /*
            for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
                bk_req_if_arr[i].id     = axi_ar_if.aid;
                bk_req_if_arr[i].ra     = get_dram_ra(axi_ar_if.aaddr);
                bk_req_if_arr[i].ca     = get_dram_ca(axi_ar_if.aaddr);
                bk_req_if_arr[i].len    = axi_ar_if.alen;
                bk_req_if_arr[i].wr     = 1'b0;
            end
            */
            bk_req_if_arr[0].id     = axi_ar_if.aid;
            bk_req_if_arr[0].ra     = get_dram_ra(axi_ar_if.aaddr);
            bk_req_if_arr[0].ca     = get_dram_ca(axi_ar_if.aaddr);
            bk_req_if_arr[0].len    = axi_ar_if.alen;
            bk_req_if_arr[0].wr     = 1'b0;
            bk_req_if_arr[0].valid  = axi_ar_if.avalid;
            axi_ar_if.aready        = bk_req_if_arr[0].ready;
        end
    end

    /*
    always_comb begin
        // get the target bank address form the request address
        logic   [`DRAM_BA_WIDTH-1:0]ba;
        ba                          = get_dram_ba(axi_ar_if.aaddr);

        // connect the target bank controller's signals to the input
        for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
            bk_req_if_arr[i].valid      = 1'b0;
        end
        bk_req_if_arr[ba].valid     = axi_ar_if.avalid;
        axi_ar_if.aready        = bk_req_if_arr[ba].ready;
    end
    */
endmodule // SAL_ADDR_DECODER
