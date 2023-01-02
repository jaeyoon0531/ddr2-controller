`include "TIME_SCALE.svh"
`include "SAL_DDR2_PARAMS.svh"

module SAL_TB_TOP;

    logic                       clk;
    logic                       rst_n;

    // clock generation
    initial begin
        clk                         = 1'b0;
        forever
            #(`CLK_PERIOD/2) clk         = ~clk;
    end

    // reset generation
    initial begin
        // activate the reset (active low)            
        rst_n                       = 1'b0;
        repeat (10) @(posedge clk);
        // release the reset after 10 cycles
        rst_n                       = 1'b1;
    end

    APB_IF                          apb_if      (.clk(clk), .rst_n(rst_n));
    AXI_A_IF                        axi_ar_if   (.clk(clk), .rst_n(rst_n));
    AXI_R_IF                        axi_r_if    (.clk(clk), .rst_n(rst_n));
    AXI_A_IF                        axi_aw_if   (.clk(clk), .rst_n(rst_n));
    AXI_W_IF                        axi_w_if    (.clk(clk), .rst_n(rst_n));
    AXI_B_IF                        axi_b_if    (.clk(clk), .rst_n(rst_n));

    DFI_CTRL_IF                     dfi_ctrl_if (.clk(clk), .rst_n(rst_n));
    DFI_WR_IF                       dfi_wr_if   (.clk(clk), .rst_n(rst_n));
    DFI_RD_IF                       dfi_rd_if   (.clk(clk), .rst_n(rst_n));

    wire                            ddr_ck;
    wire                            ddr_ck_n;
    wire                            ddr_cke;
    wire    [`DRAM_CS_WIDTH-1:0]    ddr_cs_n;
    wire                            ddr_ras_n;
    wire                            ddr_cas_n;
    wire                            ddr_we_n;
    wire    [`DRAM_BA_WIDTH-1:0]    ddr_ba;
    wire    [`DRAM_ADDR_WIDTH-1:0]  ddr_addr;
    wire                            ddr_odt;

    wire    [63:0]                  ddr_dq;
    wire    [7:0]                   ddr_dqs;
    wire    [7:0]                   ddr_dqs_n;
    wire    [7:0]                   ddr_dm_rdqs;
    wire    [7:0]                   ddr_rdqs_n;

    SAL_DDR2_CTRL                   u_mem_ctrl
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        // APB interface
        .apb_if                     (apb_if),

        // AXI interface
        .axi_ar_if                  (axi_ar_if),
        .axi_aw_if                  (axi_aw_if),
        .axi_w_if                   (axi_w_if),
        .axi_b_if                   (axi_b_if),
        .axi_r_if                   (axi_r_if),

        // DFI interface
        .dfi_ctrl_if                (dfi_ctrl_if),
        .dfi_wr_if                  (dfi_wr_if),
        .dfi_rd_if                  (dfi_rd_if)
    );

    DDRPHY
    #(
        .CLK_PERIOD                 (`CLK_PERIOD)
    )
    u_ddrphy
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .dfi_ctrl_if                (dfi_ctrl_if),
        .dfi_wr_if                  (dfi_wr_if),
        .dfi_rd_if                  (dfi_rd_if),

        // command and address
        .ck                         (ddr_ck),
        .ck_n                       (ddr_ck_n),
        .cke                        (ddr_cke),
        .cs_n                       (ddr_cs_n),
        .ras_n                      (ddr_ras_n),
        .cas_n                      (ddr_cas_n),
        .we_n                       (ddr_we_n),
        .ba                         (ddr_ba),
        .addr                       (ddr_addr),
        .odt                        (ddr_odt),

        // data
        .dq                         (ddr_dq),
        .dqs                        (ddr_dqs),
        .dqs_n                      (ddr_dqs_n),
        .dm_rdqs                    (ddr_dm_rdqs),
        .rdqs_n                     (ddr_rdqs_n)
    );

    ddr2_dimm                       u_rank0
    (
        // command and address
        .ck                         (ddr_ck),
        .ck_n                       (ddr_ck_n),
        .cke                        (ddr_cke),
        .cs_n                       (ddr_cs_n[0]),
        .ras_n                      (ddr_ras_n),
        .cas_n                      (ddr_cas_n),
        .we_n                       (ddr_we_n),
        .ba                         (ddr_ba),
        .addr                       (ddr_addr),
        .odt                        (ddr_odt),

        // data
        .dq                         (ddr_dq),
        .dqs                        (ddr_dqs),
        .dqs_n                      (ddr_dqs_n),
        .dm_rdqs                    (ddr_dm_rdqs),
        .rdqs_n                     (ddr_rdqs_n)
    );

    ddr2_dimm                       u_rank1
    (
        // command and address
        .ck                         (ddr_ck),
        .ck_n                       (ddr_ck_n),
        .cke                        (ddr_cke),
        .cs_n                       (ddr_cs_n[1]),
        .ras_n                      (ddr_ras_n),
        .cas_n                      (ddr_cas_n),
        .we_n                       (ddr_we_n),
        .ba                         (ddr_ba),
        .addr                       (ddr_addr),
        .odt                        (ddr_odt),

        // data
        .dq                         (ddr_dq),
        .dqs                        (ddr_dqs),
        .dqs_n                      (ddr_dqs_n),
        .dm_rdqs                    (ddr_dm_rdqs),
        .rdqs_n                     (ddr_rdqs_n)
    );


    initial begin
        axi_aw_if.reset();
        axi_ar_if.reset();

        @(posedge rst_n);       // wait for a reset release
        repeat (5) @(posedge clk);

        axi_ar_if.transfer('d0, 'd0, 'd0, 'd0, 'd0);

        repeat (100) @(posedge clk);
        $finish;
    end

endmodule // sim_tb_top
