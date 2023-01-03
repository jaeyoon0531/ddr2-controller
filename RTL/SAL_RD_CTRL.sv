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
    // read data path
endmodule
