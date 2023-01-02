`timescale 1ns/1ps

`include "SAL_DDR2_PARAMS.svh"

module SAL_BK_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst,

    // request from the address decoder
    BK_REQ_INTF                 bk_req_intf,
    // timing parameters
    BK_TIMING_INTF              bk_timing_intf,
    // request to the scheduler
    BK_SCHED_INTF               bk_sched_intf,

    // per-bank auto-refresh requests
    input   wire                pb_aref_req_i,
    output  logic               pb_aref_gnt_o
);

    localparam                  S_CLOSED    = 1'b0,
                                S_OPEN      = 1'b1;

    // current state
    logic                       state,              state_n;                        
    // current row address                                            
    logic   [`DRAM_RA_WIDTH-1:0]cur_ra,         cur_ra_n;

    wire                        is_t_rcd_met,
                                is_t_rp_met,
                                is_t_ras_met,
                                is_t_rfc_met,
                                is_t_rtp_met,
                                is_t_wtp_met;

    always_comb begin
        cur_ra_n                    = cur_ra;
        state_n                     = state;

        pb_aref_gnt_o               = 1'b0;
        bk_req_intf.ready           = 1'b0;

        bk_sched_intf.ra            = bk_req_intf.ra;
        bk_sched_intf.ca            = bk_req_intf.ca;

        bk_sched_intf.act_req       = 1'b0;
        bk_sched_intf.rd_req        = 1'b0;
        bk_sched_intf.wr_req        = 1'b0;
        bk_sched_intf.pre_req       = 1'b0;
        bk_sched_intf.ref_req       = 1'b0;

        case (state)
            S_CLOSED: begin     // the bank is closed
                if (is_t_rp_met & is_t_rfc_met) begin
                    if (pb_aref_req_i) begin
                        bk_sched_intf.ref_req       = 1'b1;
                        if (bk_sched_intf.ref_gnt) begin
                            pb_aref_gnt_o               = 1'b1;
                        end
                    end
                    else if (bk_req_intf.valid) begin    // a new request comes
                    // we need to activate a new row
                        bk_sched_intf.act_req       = 1'b1;
                        if (bk_sched_intf.act_gnt) begin
                            cur_ra_n                    = bk_req_intf.ra;
                            state_n                     = S_OPEN;
                        end
                    end
                end
            end
            S_OPEN: begin
                if (bk_req_intf.valid) begin
                    if (cur_ra == bk_req_intf.ra) begin // bank hit
                        if (is_t_rcd_met) begin
                            bk_sched_intf.rd_req        = !bk_req_intf.wr;
                            bk_sched_intf.wr_req        = bk_req_intf.wr;
                        end

                        if (bk_sched_intf.rd_gnt) begin
                            bk_req_intf.ready           = 1'b1;
                        end
                        if (bk_sched_intf.wr_gnt) begin
                            bk_req_intf.ready           = 1'b1;
                        end
                    end
                    else begin  // bank miss
                        if (is_t_ras_met & is_t_rtp_met & is_t_wtp_met) begin
                            bk_sched_intf.pre_req       = 1'b1;
                        end

                        if (bk_sched_intf.pre_gnt) begin
                            state_n                     = S_CLOSED;
                        end
                    end
                end
            end
        endcase
    end

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(T_RCD_WIDTH)) u_rcd_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_intf.act_gnt),
        .reset_value_i              (bk_timing_intf.t_rcd),
        .is_zero_o                  (is_t_rcd_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(T_RP_WIDTH)) u_rp_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_intf.pre_gnt),
        .reset_value_i              (bk_timing_intf.t_rp),
        .is_zero_o                  (is_t_rp_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(T_RAS_WIDTH)) u_ras_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_intf.act_gnt),
        .reset_value_i              (bk_timing_intf.t_ras),
        .is_zero_o                  (is_t_ras_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(T_RFC_WIDTH)) u_rfc_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_intf.ref_gnt),
        .reset_value_i              (bk_timing_intf.t_rfc),
        .is_zero_o                  (is_t_rfc_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(T_RTP_WIDTH)) u_rtp_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_intf.rd_gnt),
        .reset_value_i              (bk_timing_intf.t_rtp),
        .is_zero_o                  (is_t_rtp_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(T_WTP_WIDTH)) u_wtp_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_intf.wr_gnt),
        .reset_value_i              (bk_timing_intf.t_wtp),
        .is_zero_o                  (is_t_wtp_met)
    );

endmodule // SAL_BK_CTRL
