`include "TIME_SCALE.svh"
`include "SAL_DDR2_PARAMS.svh"

module SAL_ADDR_DECODER
(
    // clock & reset
    input                        clk,
    input                        rst_n,

    // request from the AXI side
    AXI_A_IF                    icnt_axi_a_if,
    // request to bank controller
    BK_REQ_IF                   bk_req_if_arr[`DRAM_BK_CNT]
);

    // SystemVerilog generate statement for banks
    genvar geni;

    generate
    for (geni=0; geni<`DRAM_BK_CNT; geni++) begin: bank_ctrl_signals
        always_comb begin
            bk_req_if_arr[geni].id      = icnt_axi_a_if.aid;
            bk_req_if_arr[geni].ra      = get_dram_ra(icnt_axi_a_if.aaddr);
            bk_req_if_arr[geni].ca      = get_dram_ca(icnt_axi_a_if.aaddr);
            bk_req_if_arr[geni].len     = icnt_axi_a_if.alen;
            bk_req_if_arr[geni].wr      = 1'b0;
        end
    end
    endgenerate

    always_comb begin
        /*
        // get the target bank address form the request address
        logic   [`DRAM_BA_WIDTH-1:0]ba;
        ba                          = get_dram_ba(icnt_axi_a_if.aaddr);

        // connect the target bank controller's signals to the input
        for (int i=0; i<`DRAM_BK_CNT; i=i+1) begin
            bk_req_if_arr[i].valid      = 1'b0;
        end
        bk_req_if_arr[ba].valid     = icnt_axi_a_if.avalid;
        icnt_axi_a_if.aready        = bk_req_if_arr[ba].ready;
        */
        bk_req_if_arr[0].valid      = icnt_axi_a_if.avalid;
        icnt_axi_a_if.aready        = bk_req_if_arr[0].ready;
    end

endmodule // SAL_ADDR_DECODER
