`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_RD_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    SCHED_TIMING_IF.MON         sched_timing_if,
    SCHED_IF.MON                sched_if,

    DFI_RD_IF.DST               dfi_rd_if,
    AXI_R_IF.SRC                axi_r_if
);

    //----------------------------------------------------------
    // read enable path
    reg     [15:0]              rden_shift_reg;

    always_ff @(posedge clk)
        if (~rst_n) begin
            rden_shift_reg              <= 16'h0;
        end
        else if (sched_if.rd_gnt) begin
            rden_shift_reg              <= {rden_shift_reg[14:1], 2'b11};                
        end
        else begin
            rden_shift_reg              <= {rden_shift_reg[14:0], 1'b0};                
        end

    assign  dfi_rd_if.rddata_en         = rden_shift_reg[sched_timing_if.dfi_rden_lat];

    //----------------------------------------------------------
    // read ID path
    wire                                rid_fifo_empty;
    SAL_FIFO
    #(
        .DEPTH_LG2                      (4),
        .DATA_WIDTH                     (128)
    )
    rid_fifo
    (
        .clk                            (clk),
        .rst_n                          (rst_n),
        .full_o                         (/* NC */),
        .afull_o                        (/* NC */),
        .wren_i                         (sched_if.rd_gnt),
        .wdata_i                        (sched_if.id),

        .empty_o                        (/* NC */),
        .aempty_o                       (/* NC */),
        .rden_i                         (axi_r_if.rvalid & axi_r_if.rready),
        .rdata_o                        (axi_r_if.rid)
    );

    //
    //----------------------------------------------------------
    // read data path
    wire                                rdata_fifo_empty;
    SAL_FIFO
    #(
        .DEPTH_LG2                      (3),
        .DATA_WIDTH                     (128)
    )
    rdata_fifo
    (
        .clk                            (clk),
        .rst_n                          (rst_n),
        .full_o                         (/* NC */),
        .afull_o                        (/* NC */),
        .wren_i                         (dfi_rd_if.rddata_valid),
        .wdata_i                        (dfi_rd_if.rddata),

        .empty_o                        (rdata_fifo_empty),
        .aempty_o                       (/* NC */),
        .rden_i                         (axi_r_if.rvalid & axi_r_if.rready),
        .rdata_o                        (axi_r_if.rdata)
    );
    assign  axi_r_if.rresp              = 2'b00;        // OK
    assign  axi_r_if.rvalid             = ~rdata_fifo_empty;

endmodule
