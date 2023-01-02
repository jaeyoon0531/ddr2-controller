`include "TIME_SCALE.svh"
`include "SAL_DDR2_PARAMS.svh"

// DONE: merge AW and AR interfaces

interface AXI_A_IF
#(
    parameter   ADDR_WIDTH      = `AXI_ADDR_WIDTH,      // 32
    parameter   ID_WIDTH        = `AXI_ID_WIDTH,        // 4
    parameter   ADDR_LEN        = 4                               // question 04.07
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       avalid;
    logic                       aready;
    logic   [ID_WIDTH-1:0]      aid;
    logic   [ADDR_WIDTH-1:0]    aaddr;
    logic   [ADDR_LEN-1:0]      alen;
    logic   [2:0]               asize;
    logic   [1:0]               aburst;

    // synthesizable, for design
    modport                     SRC (
        output                      avalid,
        output                      aid,
        output                      aaddr,
        output                      alen,
        output                      asize,
        output                      aburst,
        input                       aready
    );

    modport                     DST (
        output                      avalid,
        output                      aid,
        output                      aaddr,
        output                      alen,
        output                      asize,
        output                      aburst,
        input                       aready
    );

    // for verification only
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge

        output                      avalid;
        output                      aid;
        output                      aaddr;
        output                      alen;
        output                      asize;
        output                      aburst;
        input                       aready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge

        input                       avalid;
        input                       aid;
        input                       aaddr;
        input                       alen;
        input                       asize;
        input                       aburst;
        output                      aready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge

        input                       avalid;
        input                       aid;
        input                       aaddr;
        input                       alen;
        input                       asize;
        input                       aburst;
        input                       aready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    function void init();   // does not consume timing
        avalid                      = 1'b0;
        aid                         = 'hx;
        aaddr                       = 'hx;
        alen                        = 'hx;
        asize                       = 'hx;
        aburst                      = 'hx;
    endfunction

    task transfer(  input   [ID_WIDTH-1:0]      id,
                    input   [ADDR_WIDTH-1:0]    addr,
                    input   [ADDR_LEN-1:0]      len,
                    input   [2:0]               size,
                    input   [1:0]               burst);
        SRC_CB.avalid               <= 1'b1;
        SRC_CB.aid                  <= id;
        SRC_CB.aaddr                <= addr;
        SRC_CB.alen                 <= len;
        SRC_CB.asize                <= size;
        SRC_CB.aburst               <= burst;
        while (SRC_CB.aready!=1'b1) begin
            $display("A", $time, SRC_CB.aready);
            @(posedge clk);
        end
        SRC_CB.avalid               <= 1'b0;
        SRC_CB.aid                  <= 'hx;
        SRC_CB.aaddr                <= 'hx;
        SRC_CB.alen                 <= 'hx;
        SRC_CB.asize                <= 'hx;
        SRC_CB.aburst               <= 'hx;
    endtask
    // synthesis translate_on
endinterface

interface AXI_W_IF
#(
    parameter   DATA_WIDTH      = `AXI_DATA_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       wvalid;
    logic                       wready;
    logic   [ID_WIDTH-1:0]      wid;
    logic   [DATA_WIDTH-1:0]    wdata;
    logic   [DATA_WIDTH/8-1:0]  wstrb;
    logic                       wlast;

    // synthesizable, for design
    modport                     SRC (
        output                      wvalid,
        output                      wid,
        output                      wdata,
        output                      wstrb,
        output                      wlast,
        input                       wready
    );

    modport                     DST (
        input                       wvalid,
        input                       wid,
        input                       wdata,
        input                       wstrb,
        input                       wlast,
        output                      wready
    );

    // for verification only
    // synthesis translate_off
    clocking SRC_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge

        output                      wvalid;
        output                      wid;
        output                      wdata;
        output                      wstrb;
        output                      wlast;
        input                       wready;
    endclocking

    clocking DST_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge

        input                       wvalid;
        input                       wid;
        input                       wdata;
        input                       wstrb;
        input                       wlast;
        output                      wready;
    endclocking

    clocking MON_CB @(posedge clk);
        default input #0.1 output #0.1; // sample -0.1ns before posedge
                                        // drive 0.1ns after posedge

        input                       wvalid;
        input                       wid;
        input                       wdata;
        input                       wstrb;
        input                       wlast;
        input                       wready;
    endclocking

    modport SRC_TB (clocking SRC_CB, input clk, rst_n);
    modport DST_TB (clocking DST_CB, input clk, rst_n);

    function void init();   // does not consume timing
        wvalid                      = 1'b0;
        wid                         = 'hx;
        wdata                       = 'hx;
        wstrb                       = 'hx;
        wlast                       = 'hx;
    endfunction
    // synthesis translate_on
endinterface

interface AXI_B_IF
#(
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       bvalid;
    logic                       bready;
    logic   [ID_WIDTH-1:0]      bid;
    logic   [1:0]               bresp;

    // synthesizable, for design
    modport                     SRC (
        output                      bvalid,
        output                      bid,
        output                      bresp,
        input                       bready
    );

    modport                     DST (
        input                       bvalid,
        input                       bid,
        input                       bresp,
        output                      bready
    );

endinterface



interface AXI_R_IF
#(
    parameter   DATA_WIDTH      = `AXI_DATA_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk,
    input                       rst_n
);
    logic                       rvalid;
    logic                       rready;
    logic   [ID_WIDTH-1:0]      rid;
    logic   [DATA_WIDTH-1:0]    rdata;
    logic   [1:0]               rresp;
    logic                       rlast;

    // synthesizable, for design
    modport                     SRC (
        output                      rvalid,
        output                      rid,
        output                      rdata,
        output                      rresp,
        output                      rlast,
        input                       rready
    );

    modport                     DST (
        input                       rvalid,
        input                       rid,
        input                       rdata,
        input                       rresp,
        input                       rlast,
        output                      rready
    );

    // For verification
    // synthesis translate_off
    clocking driver_cb_mc_r @(posedge clk);
    //default input #1 output #1;

        // on chip - r
        input               rready;
        // dram - r
        output              rid;
        output              rdata;
        output              rresp;
        output              rlast;
        output              rvalid;
    endclocking

    clocking driver_cb_icnt_r @(posedge clk);
    //    default input #1 output #1;

        // on chip - r
        output          rready;
        // dram - r
        input           rid;
        input           rdata;
        input           rresp;
        input           rlast;
        input           rvalid;
    endclocking

    clocking monitor_cb_icnt_r @(posedge clk);
        //default input #1 output #1;

        // on chip - r
        input           rid;
        input           rresp;
        input           rdata;
        input           rlast;
        input           rvalid;
        // dram - r
        input           rready;
    endclocking

    modport DRIVER_MC_R (clocking driver_cb_mc_r, input clk, rst_n);
    modport DRIVER_ICNT_R (clocking driver_cb_icnt_r, input clk, rst_n);

    //  modport MONITOR_MC_R (clocking monitor_cb_mc_r, input clk, rst_n);
    modport MONITOR_ICNT_R (clocking monitor_cb_icnt_r, input clk, rst_n);
    // synthesis translate_on
endinterface

interface APB_IF (
    input                       clk,
    input                       rst_n
);
    logic                       psel;
    logic                       penable;
    logic   [31:0]              paddr;
    logic                       pwrite;
    logic   [31:0]              pwdata;
    logic                       pready;
    logic   [31:0]              prdata;
    logic                       pslverr;

    modport master (
        input           clk,
        input           pready, prdata, pslverr,
        output          psel, penable, paddr, pwrite, pwdata
    );

    // synthesis translate_off
    task init();
        psel                    = 1'b0;
        penable                 = 1'b0;
        paddr                   = 32'd0;
        pwrite                  = 1'b0;
        pwdata                  = 32'd0;
    endtask

    task write(input int addr,
               input int data);
        #1
        psel                    = 1'b1;
        penable                 = 1'b0;
        paddr                   = addr;
        pwrite                  = 1'b1;
        pwdata                  = data;
        @(posedge clk);
        #1
        penable                 = 1'b1;
        @(posedge clk);

        while (pready==1'b0) begin
            @(posedge clk);
        end

        psel                    = 1'b0;
        penable                 = 1'b0;
        paddr                   = 'hX;
        pwrite                  = 1'bx;
        pwdata                  = 'hX;
    endtask

    task read(input int addr,
              output int data);
        #1
        psel                    = 1'b1;
        penable                 = 1'b0;
        paddr                   = addr;
        pwrite                  = 1'b0;
        pwdata                  = 'hX;
        @(posedge clk);
        #1
        penable                 = 1'b1;
        @(posedge clk);

        while (pready==1'b0) begin
            @(posedge clk);
        end
        data                    = prdata;

        psel                    = 1'b0;
        penable                 = 1'b0;
        paddr                   = 'hX;
        pwrite                  = 1'bx;
        pwdata                  = 'hX;
    endtask
    // synthesis translate_on

endinterface
