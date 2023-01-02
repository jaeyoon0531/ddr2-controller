module SAL_TB_TOP;

    parameter real              CLK_PERIOD  = 2.5;

    logic                       clk;
    logic                       rst_n;

    // clock generation
    initial begin
        clk                         = 1'b0;
        forever
            #(CLK_PERIOD/2) clk         = ~clk;
    end

    // reset generation
    initial begin
        // activate the reset (active low)            
        rst_n                       = 1'b0;
        repeat 10 @(posedge clk);
        // release the reset
        rst_n                       = 1'b1;
    end

   localparam DEVICE_WIDTH = 16; // Memory device data width
   localparam REG_ENABLE   = `REGISTERED; // registered addr/ctrl

   localparam real CLK_PERIOD_NS      = 4166.0 / 1000.0;
   localparam real TCYC_200           = 5.0;
   localparam real TPROP_DQS          = 0.01;  // Delay for DQS signal during Write Operation
   localparam real TPROP_DQS_RD       = 0.01;  // Delay for DQS signal during Read Operation
   localparam real TPROP_PCB_CTRL     = 0.01;  // Delay for Address and Ctrl signals
   localparam real TPROP_PCB_DATA     = 0.01;  // Delay for data signal during Write operation
   localparam real TPROP_PCB_DATA_RD  = 0.01;  // Delay for data signal during Read operation

   reg       sys_clk;
   wire      sys_clk_n;
   wire      sys_clk_p;
   reg       sys_clk200;
   wire      clk200_n;
   wire      clk200_p;
   reg       sys_rst_n;
   wire      sys_rst_out;

   wire [`DATA_WIDTH-1:0]         ddr2_dq_sdram;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_sdram;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_n_sdram;
   wire [`DATA_MASK_WIDTH-1:0]    ddr2_dm_sdram;
   reg [`DATA_MASK_WIDTH-1:0]     ddr2_dm_sdram_tmp;
   reg [`CLK_WIDTH-1:0]           ddr2_clk_sdram;
   reg [`CLK_WIDTH-1:0]           ddr2_clk_n_sdram;
   reg [`ROW_ADDRESS-1:0]         ddr2_address_sdram;
   reg [`BANK_ADDRESS-1:0]        ddr2_ba_sdram;
   reg                            ddr2_ras_n_sdram;
   reg                            ddr2_cas_n_sdram;
   reg                            ddr2_we_n_sdram;
   reg [`CS_WIDTH-1:0]            ddr2_cs_n_sdram;
   reg [`CKE_WIDTH-1:0]           ddr2_cke_sdram;
   reg [`ODT_WIDTH-1:0]           ddr2_odt_sdram;


   wire [`DATA_WIDTH-1:0]         ddr2_dq_fpga;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_fpga;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_n_fpga;
   wire [`DATA_MASK_WIDTH-1:0]    ddr2_dm_fpga;
   wire [`CLK_WIDTH-1:0]          ddr2_clk_fpga;
   wire [`CLK_WIDTH-1:0]          ddr2_clk_n_fpga;
   wire [`ROW_ADDRESS-1:0]        ddr2_address_fpga;
   wire [`BANK_ADDRESS-1:0]       ddr2_ba_fpga;
   wire                           ddr2_ras_n_fpga;
   wire                           ddr2_cas_n_fpga;
   wire                           ddr2_we_n_fpga;
   wire [`CS_WIDTH-1:0]           ddr2_cs_n_fpga;
   wire [`CKE_WIDTH-1:0]          ddr2_cke_fpga;
   wire [`ODT_WIDTH-1:0]          ddr2_odt_fpga;

   wire                          error;
   wire                          init_done;


   // Only RDIMM memory parts support the reset signal,
   // hence the ddr2_reset_n signal can be ignored for other memory parts
   wire                          ddr2_reset_n;
   reg  [`ROW_ADDRESS-1:0]       ddr2_address_reg;
   reg  [`BANK_ADDRESS-1:0]      ddr2_ba_reg;
   reg  [`CKE_WIDTH-1:0]         ddr2_cke_reg;
   reg                           ddr2_ras_n_reg;
   reg                           ddr2_cas_n_reg;
   reg                           ddr2_we_n_reg;
   reg  [`CS_WIDTH-1:0]          ddr2_cs_n_reg;
   reg  [`ODT_WIDTH-1:0]         ddr2_odt_reg;

   wire                          clk0_tb;
   wire                          rst0_tb;
   wire                          wdf_almost_full;
   wire                          af_almost_full;
   wire [2:0]                    burst_length_div2;
   wire                          read_data_valid;
   wire [(2*`DQ_WIDTH)-1:0]      read_data_fifo_out;
   wire [35:0]                   app_af_addr;
   wire                          app_af_wren;
   wire [(2*`DQ_WIDTH)-1:0]      app_wdf_data;
   wire [(2*`DM_WIDTH)-1:0]      app_mask_data;
   wire                          app_wdf_wren;

   //***************************************************************************
   // Clock generation and reset
   //***************************************************************************

// =============================================================================
//                             BOARD Parameters
// =============================================================================
// These parameter values can be changed to model varying board delays
// between the Virtex-4 device and the memory model

  always @( * ) begin
    ddr2_clk_sdram        <=  #(TPROP_PCB_CTRL) ddr2_clk_fpga;
    ddr2_clk_n_sdram      <=  #(TPROP_PCB_CTRL) ddr2_clk_n_fpga;
    ddr2_address_sdram    <=  #(TPROP_PCB_CTRL) ddr2_address_fpga;
    ddr2_ba_sdram         <=  #(TPROP_PCB_CTRL) ddr2_ba_fpga;
    ddr2_ras_n_sdram      <=  #(TPROP_PCB_CTRL) ddr2_ras_n_fpga;
    ddr2_cas_n_sdram      <=  #(TPROP_PCB_CTRL) ddr2_cas_n_fpga;
    ddr2_we_n_sdram       <=  #(TPROP_PCB_CTRL) ddr2_we_n_fpga;
    ddr2_cs_n_sdram       <=  #(TPROP_PCB_CTRL) ddr2_cs_n_fpga;
    ddr2_cke_sdram        <=  #(TPROP_PCB_CTRL) ddr2_cke_fpga;
    ddr2_odt_sdram        <=  #(TPROP_PCB_CTRL) ddr2_odt_fpga;
    ddr2_dm_sdram_tmp     <=  #(TPROP_PCB_DATA) ddr2_dm_fpga;//DM signal generation
  end

  assign ddr2_dm_sdram = ddr2_dm_sdram_tmp;

// Controlling the bi-directional BUS
  genvar dqwd;
  generate
    for (dqwd = 0;dqwd < `DATA_WIDTH;dqwd = dqwd+1) begin : dq_delay
      WireDelay #
       (
        .Delay_g     (TPROP_PCB_DATA),
        .Delay_rd    (TPROP_PCB_DATA_RD)
       )
      u_delay_dq
       (
        .A           (ddr2_dq_fpga[dqwd]),
        .B           (ddr2_dq_sdram[dqwd]),
        .reset       (sys_rst_n)
       );
    end
  endgenerate

  genvar dqswd;
  generate
    for (dqswd = 0;dqswd < `DATA_STROBE_WIDTH;dqswd = dqswd+1) begin : dqs_delay
      WireDelay #
       (
        .Delay_g     (TPROP_DQS),
        .Delay_rd    (TPROP_DQS_RD)
       )
      u_delay_dqs
       (
        .A           (ddr2_dqs_fpga[dqswd]),
        .B           (ddr2_dqs_sdram[dqswd]),
        .reset       (sys_rst_n)
       );

      WireDelay #
       (
        .Delay_g     (TPROP_DQS),
        .Delay_rd    (TPROP_DQS_RD)
       )
      u_delay_dqs_n
       (
        .A           (ddr2_dqs_n_fpga[dqswd]),
        .B           (ddr2_dqs_n_sdram[dqswd]),
        .reset       (sys_rst_n)
       );
    end
  endgenerate


   //***************************************************************************
   // FPGA memory controller
   //***************************************************************************

   DDR2 u_mem_controller
     (
      .sys_clk                   (sys_clk_p),
      .idly_clk_200              (clk200_p),
      .sys_reset_in_n            (sys_rst_out),
      .cntrl0_ddr2_ras_n         (ddr2_ras_n_fpga),
      .cntrl0_ddr2_cas_n         (ddr2_cas_n_fpga),
      .cntrl0_ddr2_we_n          (ddr2_we_n_fpga),
      .cntrl0_ddr2_cs_n          (ddr2_cs_n_fpga),
      .cntrl0_ddr2_cke           (ddr2_cke_fpga),
      .cntrl0_ddr2_odt           (ddr2_odt_fpga),
      .cntrl0_ddr2_dq            (ddr2_dq_fpga),
      .cntrl0_ddr2_dqs           (ddr2_dqs_fpga),
      .cntrl0_ddr2_dqs_n         (ddr2_dqs_n_fpga),
      .cntrl0_ddr2_ck            (ddr2_clk_fpga),
      .cntrl0_ddr2_ck_n          (ddr2_clk_n_fpga),
      .cntrl0_ddr2_ba            (ddr2_ba_fpga),
      .cntrl0_ddr2_a             (ddr2_address_fpga),
      
      .cntrl0_clk_tb             (clk0_tb),
      .cntrl0_reset_tb           (rst0_tb),
      .cntrl0_wdf_almost_full    (wdf_almost_full),
      .cntrl0_af_almost_full     (af_almost_full),
      .cntrl0_burst_length_div2  (burst_length_div2),
      .cntrl0_read_data_valid    (read_data_valid),
      .cntrl0_read_data_fifo_out (read_data_fifo_out),
      .cntrl0_app_af_addr        (app_af_addr),
      .cntrl0_app_af_wren        (app_af_wren),
      .cntrl0_app_wdf_data       (app_wdf_data),
      .cntrl0_app_wdf_wren       (app_wdf_wren),
      .cntrl0_init_done          (init_done)
      );

   // Extra one clock pipelining for RDIMM address and
   // control signals is implemented here (Implemented external to memory model)
   always @( posedge ddr2_clk_sdram[0] ) begin
      if ( ddr2_reset_n == 1'b0 ) begin
         ddr2_ras_n_reg    <= 1'b1;
         ddr2_cas_n_reg    <= 1'b1;
         ddr2_we_n_reg     <= 1'b1;
         ddr2_cs_n_reg     <= 1'b1;
         ddr2_odt_reg      <= 1'b0;
      end
      else begin
         ddr2_address_reg  <= #(CLK_PERIOD_NS/2) ddr2_address_sdram;
         ddr2_ba_reg       <= #(CLK_PERIOD_NS/2) ddr2_ba_sdram;
         ddr2_ras_n_reg    <= #(CLK_PERIOD_NS/2) ddr2_ras_n_sdram;
         ddr2_cas_n_reg    <= #(CLK_PERIOD_NS/2) ddr2_cas_n_sdram;
         ddr2_we_n_reg     <= #(CLK_PERIOD_NS/2) ddr2_we_n_sdram;
         ddr2_cs_n_reg     <= #(CLK_PERIOD_NS/2) ddr2_cs_n_sdram;
         ddr2_odt_reg      <= #(CLK_PERIOD_NS/2) ddr2_odt_sdram;
      end
   end

   // to avoid tIS violations on CKE when reset is deasserted
   always @( posedge ddr2_clk_n_sdram[0] )
      if ( ddr2_reset_n == 1'b0 )
         ddr2_cke_reg      <= 1'b0;
      else
         ddr2_cke_reg      <= #(CLK_PERIOD_NS) ddr2_cke_sdram;

   //***************************************************************************
   // Memory model instances
   //***************************************************************************
   assign ddr2_dm_fpga = 'b0;
   genvar i, j;
   generate
      if (DEVICE_WIDTH == 16) begin
         // if memory part is x16
         if ( REG_ENABLE ) begin
            // if the memory part is Registered DIMM
            for(j = 0; j < `CS_WIDTH; j = j+1) begin : gen_chips
               for(i = 0; i < `DATA_STROBE_WIDTH/2; i = i+1) begin : gen_bytes
                  ddr2_model u_mem0
                    (
                     .ck        (ddr2_clk_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                     .ck_n      (ddr2_clk_n_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                     .cke       (ddr2_cke_reg[j]),
                     .cs_n      (ddr2_cs_n_reg[j]),
                     .ras_n     (ddr2_ras_n_reg),
                     .cas_n     (ddr2_cas_n_reg),
                     .we_n      (ddr2_we_n_reg),
                     .dm_rdqs   (ddr2_dm_sdram[(2*(i+1))-1 : i*2]),
                     .ba        (ddr2_ba_reg),
                     .addr      (ddr2_address_reg),
                     .dq        (ddr2_dq_sdram[(16*(i+1))-1 : i*16]),
                     .dqs       (ddr2_dqs_sdram[(2*(i+1))-1 : i*2]),
                     .dqs_n     (ddr2_dqs_n_sdram[(2*(i+1))-1 : i*2]),
                     .rdqs_n    (),
                     .odt       (ddr2_odt_reg[j])
                     );
               end
            end
         end
         else begin
             // if the memory part is component or unbuffered DIMM
             if ( `DATA_WIDTH%16 ) begin
               // for the memory part x16, if the data width is not multiple
               // of 16, memory models are instantiated for all data with x16
               // memory model and except for MSB data. For the MSB data
               // of 8 bits, all memory data, strobe and mask data signals are
               // replicated to make it as x16 part. For example if the design
               // is generated for data width of 72, memory model x16 parts
               // instantiated for 4 times with data ranging from 0 to 63.
               // For MSB data ranging from 64 to 71, one x16 memory model
               // by replicating the 8-bit data twice and similarly
               // the case with data mask and strobe.
               for(j = 0; j < `CS_WIDTH; j = j+1) begin : gen_chips
                  for(i = 0; i < `DATA_WIDTH/16 ; i = i+1) begin : gen_bytes
                     ddr2_model u_mem0
                       (
                        .ck       (ddr2_clk_sdram[i]),
                        .ck_n      (ddr2_clk_n_sdram[i]),
                        .cke      (ddr2_cke_sdram[j]),
                        .cs_n     (ddr2_cs_n_sdram[j]),
                        .ras_n    (ddr2_ras_n_sdram),
                        .cas_n    (ddr2_cas_n_sdram),
                        .we_n     (ddr2_we_n_sdram),
                        .dm_rdqs  (ddr2_dm_sdram[(2*(i+1))-1 : i*2]),
                        .ba       (ddr2_ba_sdram),
                        .addr     (ddr2_address_sdram),
                        .dq       (ddr2_dq_sdram[(16*(i+1))-1 : i*16]),
                        .dqs      (ddr2_dqs_sdram[(2*(i+1))-1 : i*2]),
                        .dqs_n    (ddr2_dqs_n_sdram[(2*(i+1))-1 : i*2]),
                        .rdqs_n   (),
                        .odt      (ddr2_odt_sdram[j])
                        );
                  end

                  ddr2_model u_mem1
                    (
                     .ck        (ddr2_clk_sdram[`CLK_WIDTH-1]),
                     .ck_n      (ddr2_clk_n_sdram[`CLK_WIDTH-1]),
                     .cke       (ddr2_cke_sdram[j]),
                     .cs_n      (ddr2_cs_n_sdram[j]),
                     .ras_n     (ddr2_ras_n_sdram),
                     .cas_n     (ddr2_cas_n_sdram),
                     .we_n      (ddr2_we_n_sdram),
                     .dm_rdqs   ({ddr2_dm_sdram[`DATA_MASK_WIDTH - 1],
                                  ddr2_dm_sdram[`DATA_MASK_WIDTH - 1]}),
                     .ba        (ddr2_ba_sdram),
                     .addr      (ddr2_address_sdram),
                     .dq        ({ddr2_dq_sdram[`DATA_WIDTH - 1 : `DATA_WIDTH - 8],
                                  ddr2_dq_sdram[`DATA_WIDTH - 1 : `DATA_WIDTH - 8]}),
                     .dqs       ({ddr2_dqs_sdram[`DATA_STROBE_WIDTH - 1],
                                  ddr2_dqs_sdram[`DATA_STROBE_WIDTH - 1]}),
                     .dqs_n     ({ddr2_dqs_n_sdram[`DATA_STROBE_WIDTH - 1],
                                  ddr2_dqs_n_sdram[`DATA_STROBE_WIDTH - 1]}),
                     .rdqs_n    (),
                     .odt       (ddr2_odt_sdram[j])
                     );
               end
            end
            else begin
               // if the data width is multiple of 16
               for(j = 0; j < `CS_WIDTH; j = j+1) begin : gen_chips
                  for(i = 0; i < `DATA_STROBE_WIDTH/2; i = i+1) begin : gen_bytes
                     ddr2_model u_mem0
                       (
                        .ck       (ddr2_clk_sdram[i]),
                        .ck_n      (ddr2_clk_n_sdram[i]),
                        .cke      (ddr2_cke_sdram[j]),
                        .cs_n     (ddr2_cs_n_sdram[j]),
                        .ras_n    (ddr2_ras_n_sdram),
                        .cas_n    (ddr2_cas_n_sdram),
                        .we_n     (ddr2_we_n_sdram),
                        .dm_rdqs  (ddr2_dm_sdram[(2*(i+1))-1 : i*2]),
                        .ba       (ddr2_ba_sdram),
                        .addr     (ddr2_address_sdram),
                        .dq       (ddr2_dq_sdram[(16*(i+1))-1 : i*16]),
                        .dqs      (ddr2_dqs_sdram[(2*(i+1))-1 : i*2]),
                        .dqs_n    (ddr2_dqs_n_sdram[(2*(i+1))-1 : i*2]),
                        .rdqs_n   (),
                        .odt      (ddr2_odt_sdram[j])
                        );
                  end
               end
            end
         end

      end else
        if (DEVICE_WIDTH == 8) begin
           // if the memory part is x8
           if ( REG_ENABLE ) begin
              // if the memory part is Registered DIMM
              for(j = 0; j < `CS_WIDTH; j = j+1) begin : gen_chips
                 for(i = 0; i < `DATA_WIDTH/`DATABITSPERSTROBE; i = i+1) begin : gen_bytes
                    ddr2_model u_mem0
                      (
                       .ck        (ddr2_clk_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                       .ck_n      (ddr2_clk_n_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                       .cke       (ddr2_cke_reg[j]),
                       .cs_n      (ddr2_cs_n_reg[j]),
                       .ras_n     (ddr2_ras_n_reg),
                       .cas_n     (ddr2_cas_n_reg),
                       .we_n      (ddr2_we_n_reg),
                       .dm_rdqs   (ddr2_dm_sdram[i]),
                       .ba        (ddr2_ba_reg),
                       .addr      (ddr2_address_reg),
                       .dq        (ddr2_dq_sdram[(8*(i+1))-1 : i*8]),
                       .dqs       (ddr2_dqs_sdram[i]),
                       .dqs_n     (ddr2_dqs_n_sdram[i]),
                       .rdqs_n    (),
                       .odt       (ddr2_odt_reg[j])
                       );
                 end
              end
           end
           else begin
              // if the memory part is component or unbuffered DIMM
              for(j = 0; j < `CS_WIDTH; j = j+1) begin : gen_chips
                 for(i = 0; i < `DATA_STROBE_WIDTH; i = i+1) begin : gen_bytes
                    ddr2_model u_mem0
                      (
                       .ck        (ddr2_clk_sdram[i]),
                       .ck_n       (ddr2_clk_n_sdram[i]),
                       .cke       (ddr2_cke_sdram[j]),
                       .cs_n      (ddr2_cs_n_sdram[j]),
                       .ras_n     (ddr2_ras_n_sdram),
                       .cas_n     (ddr2_cas_n_sdram),
                       .we_n      (ddr2_we_n_sdram),
                       .dm_rdqs   (ddr2_dm_sdram[i]),
                       .ba        (ddr2_ba_sdram),
                       .addr      (ddr2_address_sdram),
                       .dq        (ddr2_dq_sdram[(8*(i+1))-1 : i*8]),
                       .dqs       (ddr2_dqs_sdram[i]),
                       .dqs_n     (ddr2_dqs_n_sdram[i]),
                       .rdqs_n    (),
                       .odt       (ddr2_odt_sdram[j])
                       );
                 end
              end
           end

        end else
          if (DEVICE_WIDTH == 4) begin
             // if the memory part is x4
             if ( REG_ENABLE ) begin
                // if the memory part is Registered DIMM
                for(j = 0; j < `CS_WIDTH; j = j+1) begin : gen_chips
                   for(i = 0; i < `DATA_STROBE_WIDTH; i = i+1) begin : gen_bytes
                      ddr2_model u_mem0
                        (
                         .ck      (ddr2_clk_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                         .ck_n    (ddr2_clk_n_sdram[`CLK_WIDTH*i/`DATA_STROBE_WIDTH]),
                         .cke     (ddr2_cke_reg[j]),
                         .cs_n    (ddr2_cs_n_reg[j]),
                         .ras_n   (ddr2_ras_n_reg),
                         .cas_n   (ddr2_cas_n_reg),
                         .we_n    (ddr2_we_n_reg),
                         .dm_rdqs (ddr2_dm_sdram[i/2]),
                         .ba      (ddr2_ba_reg),
                         .addr    (ddr2_address_reg),
                         .dq      (ddr2_dq_sdram[(4*(i+1))-1 : i*4]),
                         .dqs     (ddr2_dqs_sdram[i]),
                         .dqs_n   (ddr2_dqs_n_sdram[i]),
                         .rdqs_n  (),
                         .odt     (ddr2_odt_reg[j])
                         );
                   end
                end
             end
             else begin
                // if the memory part is component or unbuffered DIMM
                for(j = 0; j < `CS_WIDTH; j = j+1) begin : gen_chips
                   for(i = 0; i < `DATA_STROBE_WIDTH; i = i+1) begin : gen_bytes
                      ddr2_model u_mem0
                        (
                         .ck      (ddr2_clk_sdram[i]),
                         .ck_n     (ddr2_clk_n_sdram[i]),
                         .cke     (ddr2_cke_sdram[j]),
                         .cs_n    (ddr2_cs_n_sdram[j]),
                         .ras_n   (ddr2_ras_n_sdram),
                         .cas_n   (ddr2_cas_n_sdram),
                         .we_n    (ddr2_we_n_sdram),
                         .dm_rdqs (ddr2_dm_sdram[i/2]),
                         .ba      (ddr2_ba_sdram),
                         .addr    (ddr2_address_sdram),
                         .dq      (ddr2_dq_sdram[(4*(i+1))-1 : i*4]),
                         .dqs     (ddr2_dqs_sdram[i]),
                         .dqs_n   (ddr2_dqs_n_sdram[i]),
                         .rdqs_n  (),
                         .odt     (ddr2_odt_sdram[j])
                         );
                   end
                end
             end
          end
   endgenerate

// synthesizable test bench provided for wotb designs
   DDR2_test_bench_0 test_bench_00
     (
      .clk                (clk0_tb),
      .reset              (rst0_tb),
      .wdf_almost_full    (wdf_almost_full),
      .af_almost_full     (af_almost_full),
      .burst_length_div2  (burst_length_div2),
      .read_data_valid    (read_data_valid),
      .read_data_fifo_out (read_data_fifo_out),
      .init_done          (init_done),
      .app_af_addr        (app_af_addr),
      .app_af_wren        (app_af_wren),
      .app_wdf_data       (app_wdf_data),
      .app_mask_data      (app_mask_data),
      .app_wdf_wren       (app_wdf_wren),
      .error              (error)
      );

endmodule // sim_tb_top
