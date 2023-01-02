module DDRPHY
#(
    parameter real                  CLK_PERIOD  = 2.5
)
(
    input   wire                    clk,
    input   wire                    rst_n,

    // DFI interface (interface with the controller)
    DFI_CTRL_INTF                   dfi_ctrl_intf,
    DFI_WR_INTF                     dfi_wr_intf,
    DFI_RD_INTF                     dfi_rd_intf,

    // command and address
    output  logic                   ck,
    output  logic                   ck_n,
    output  logic                   cke,
    output  logic   [`DRAM_CS_WIDTH-1:0]    cs_n,
    output  logic                   ras_n,
    output  logic                   cas_n,
    output  logic                   we_n,
    output  logic   [`DRAM_BA_WIDTH-1:0]    ba,
    output  logic   [`DRAM_ADDR_WIDTH-1:0]  addr,
    output  logic                   odt,

    //data
    inout   logic   [63:0]          dq,
    inout   logic   [7:0]           dqs,
    inout   logic   [7:0]           dqs_n,
    inout   logic   [7:0]           dm_rdqs,
    input   logic   [7:0]           rdqs_n
);

    assign  ck                      = clk;
    assign  ck_n                    = ~clk;
    
    // delay control signals by a half cycle to align the signals
    always_ff @(negedge clk) begin
        cke                         <= dfi_ctrl_intf.cke;
        cs_n                        <= dfi_ctrl_intf.cs_n;
        ras_n                       <= dfi_ctrl_intf.ras_n;
        cas_n                       <= dfi_ctrl_intf.cas_n;
        we_n                        <= dfi_ctrl_intf.we_n;
        ba                          <= dfi_ctrl_intf.ba;
        addr                        <= dfi_ctrl_intf.addr;
        odt                         <= dfi_ctrl_intf.odt;
    end
endmodule
