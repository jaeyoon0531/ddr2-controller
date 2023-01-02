`timescale 1ns/1ps

`include "SAL_DDR2_PARAMS.svh"

module SAL_ADDR_DECODER
(
    // clock & reset
    input                        clk,
    input                        rst_n,

    // request from the AXI side
    AXI_A_INTF                  icnt_axi_a_intf,
    // request to bank controller
    BK_REQ_INTF                 bk_req_intf_arr[`DRAM_BK_CNT]
);

    // SystemVerilog generate statement for banks
    genvar geni;

    generate
    for (geni=0; geni<`DRAM_BK_CNT; geni++) begin: bank_ctrl_signals
        always_comb begin
            bk_axi_a_intf[geni].id      = icnt_axi_a_intf.aid;
            bk_axi_a_intf[geni].ra      = get_dram_ra(icnt_axi_a_intf.aaddr);
            bk_axi_a_intf[geni].ca      = get_dram_ca(icnt_axi_a_intf.aaddr);
            bk_axi_a_intf[geni].len     = icnt_axi_a_intf.alen;
            bk_axi_a_intf[geni].wr      = 1'b0;
        end
    end
    endgenerate

    always_comb begin
        // get the target bank address form the request address
        logic   [`DRAM_BA_WIDTH-1:0]ba;
        ba                          = get_dram_ba(icnt_axi_a_intf.aaddr);

        // connect the target bank controller's signals to the input
        for (int i=0; i<BK_CNT; i++) begin
            bk_axi_a_intf[i].valid      = 1'b0;
        end
        bk_axi_a_intf[ba].valid     = icnt_axi_a_intf.avalid;
        icnt_axi_a_intf.aready      = bk_axi_a_intf[ba].ready;
    end

endmodule // SAL_ADDR_DECODER
