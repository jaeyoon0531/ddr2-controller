`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_WR_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // timing parameters
    TIMING_IF.MON               timing_if,

    // scheduling output
    SCHED_IF.MON                sched_if,

    // write data from AXI
    AXI_W_IF.DST                axi_w_if,
    AXI_B_IF.SRC                axi_b_if,
    // write data to DDR PHY
    DFI_WR_IF.SRC               dfi_wr_if
);

    //----------------------------------------------------------
    // buffer AXI write data
    //----------------------------------------------------------
    wire                                wdata_fifo_full;
    SAL_FIFO
    #(
        .DEPTH_LG2                      (3),
        .DATA_WIDTH                     (128+16)
    )
    wdata_fifo
    (
        .clk                            (clk),
        .rst_n                          (rst_n),
        .full_o                         (wdata_fifo_full),
        .afull_o                        (/* NC */),
        .wren_i                         (axi_w_if.wvalid & axi_w_if.wready),
        .wdata_i                        ({axi_w_if.wdata, ~axi_w_if.wstrb}),    // inversion to convert strobe to mask

        .empty_o                        (wdata_fifo_empty),
        .aempty_o                       (/* NC */),
        .rden_i                         (dfi_wr_if.wrdata_en),
        .rdata_o                        ({dfi_wr_if.wrdata, dfi_wr_if.wrdata_mask})
    );
    assign  axi_w_if.wready             = ~wdata_fifo_full;

    // write enable path
    reg     [15:0]              wren_shift_reg;

    always_ff @(posedge clk)
        if (~rst_n) begin
            wren_shift_reg              <= 16'h0;
        end
        else if (sched_if.wr_gnt) begin
            wren_shift_reg              <= {wren_shift_reg[14:1], 2'b11};
        end
        else begin
            wren_shift_reg              <= {wren_shift_reg[14:0], 1'b0};
        end

    assign  dfi_wr_if.wrdata_en         = wren_shift_reg[timing_if.dfi_wren_lat];

    //----------------------------------------------------------
    // write response path
    //----------------------------------------------------------
    // return a write response on receiving into the wdata FIFO
    // : it is okay because after the wdata FIFO, there's no reordering
    // in this implementation.
    wire                                bid_fifo_empty;
    SAL_FIFO
    #(
        .DEPTH_LG2                      (3),
        .DATA_WIDTH                     (`AXI_ID_WIDTH)
    )
    rid_fifo
    (
        .clk                            (clk),
        .rst_n                          (rst_n),
        .full_o                         (/* NC */),
        .afull_o                        (/* NC */),
        .wren_i                         (axi_w_if.wvalid & axi_w_if.wready & axi_w_if.wlast),
        .wdata_i                        (axi_w_if.wid),

        .empty_o                        (bid_fifo_empty),
        .aempty_o                       (/* NC */),
        .rden_i                         (axi_b_if.bvalid & axi_b_if.bready),
        .rdata_o                        (axi_b_if.bid)
    );

    assign  axi_b_if.bresp              = `AXI_RESP_OKAY;
    assign  axi_b_if.bvalid             = ~bid_fifo_empty;

endmodule
