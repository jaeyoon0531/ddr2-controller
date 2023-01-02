`include "TIME_SCALE.svh"
`include "SAL_DDR_PARAMS.svh"

module SAL_BK_CTRL
(
    // clock & reset
    input                       clk,
    input                       rst_n,

    // request from the address decoder
    BK_REQ_IF                   bk_req_if,
    // timing parameters
    BK_TIMING_IF                bk_timing_if,
    // request to the scheduler
    BK_SCHED_IF                 bk_sched_if,

    // per-bank auto-refresh requests
    input   wire                pb_ref_req_i,
    output  logic               pb_ref_gnt_o
);

    localparam                  S_CLOSED    = 1'b0,
                                S_OPEN      = 1'b1;

    // current state
    logic                       state,              state_n;                        
    // current row address                                            
    logic   [`DRAM_RA_WIDTH-1:0]cur_ra,             cur_ra_n;

    wire                        is_t_rcd_met,
                                is_t_rp_met,
                                is_t_ras_met,
                                is_t_rfc_met,
                                is_t_rtp_met,
                                is_t_wtp_met;

    always_ff @(posedge clk)
        if (~rst_n) begin
            state                   <= S_CLOSED;
            cur_ra                  <= 'h0;
        end
        else begin
            state                   <= state_n;
            cur_ra                  <= cur_ra_n;
        end

    always_comb begin
        cur_ra_n                    = cur_ra;
        state_n                     = state;

        pb_ref_gnt_o                = 1'b0;
        bk_req_if.ready             = 1'b0;

        bk_sched_if.ra              = bk_req_if.ra;
        bk_sched_if.ca              = bk_req_if.ca;

        bk_sched_if.act_req         = 1'b0;
        bk_sched_if.rd_req          = 1'b0;
        bk_sched_if.wr_req          = 1'b0;
        bk_sched_if.pre_req         = 1'b0;
        bk_sched_if.ref_req         = 1'b0;

        case (state)
            S_CLOSED: begin     // the bank is closed
                if (is_t_rp_met & is_t_rfc_met) begin
                    if (pb_ref_req_i) begin
                        bk_sched_if.ref_req       = 1'b1;
                        if (bk_sched_if.ref_gnt) begin
                            pb_ref_gnt_o                = 1'b1;
                        end
                    end
                    else if (bk_req_if.valid) begin    // a new request comes
                    // we need to activate a new row
                        bk_sched_if.act_req       = 1'b1;
                        if (bk_sched_if.act_gnt) begin
                            cur_ra_n                    = bk_req_if.ra;
                            state_n                     = S_OPEN;
                        end
                    end
                end
            end
            S_OPEN: begin
                if (bk_req_if.valid) begin
                    if (cur_ra == bk_req_if.ra) begin // bank hit
                        if (is_t_rcd_met) begin
                            bk_sched_if.rd_req          = !bk_req_if.wr;
                            bk_sched_if.wr_req          = bk_req_if.wr;
                        end

                        if (bk_sched_if.rd_gnt) begin
                            bk_req_if.ready             = 1'b1;
                        end
                        if (bk_sched_if.wr_gnt) begin
                            bk_req_if.ready             = 1'b1;
                        end
                    end
                    else begin  // bank miss
                        if (is_t_ras_met & is_t_rtp_met & is_t_wtp_met) begin
                            bk_sched_if.pre_req         = 1'b1;
                        end

                        if (bk_sched_if.pre_gnt) begin
                            state_n                     = S_CLOSED;
                        end
                    end
                end
            end
        endcase
    end

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RCD_WIDTH)) u_rcd_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_if.act_gnt),
        .reset_value_i              (bk_timing_if.t_rcd),
        .is_zero_o                  (is_t_rcd_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RP_WIDTH)) u_rp_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_if.pre_gnt),
        .reset_value_i              (bk_timing_if.t_rp),
        .is_zero_o                  (is_t_rp_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RAS_WIDTH)) u_ras_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_if.act_gnt),
        .reset_value_i              (bk_timing_if.t_ras),
        .is_zero_o                  (is_t_ras_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RFC_WIDTH)) u_rfc_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_if.ref_gnt),
        .reset_value_i              (bk_timing_if.t_rfc),
        .is_zero_o                  (is_t_rfc_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_RTP_WIDTH)) u_rtp_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_if.rd_gnt),
        .reset_value_i              (bk_timing_if.t_rtp),
        .is_zero_o                  (is_t_rtp_met)
    );

    SAL_TIMING_CNTR  #(.CNTR_WIDTH(`T_WTP_WIDTH)) u_wtp_cnt
    (
        .clk                        (clk),
        .rst_n                      (rst_n),

        .reset_cmd_i                (bk_sched_if.wr_gnt),
        .reset_value_i              (bk_timing_if.t_wtp),
        .is_zero_o                  (is_t_wtp_met)
    );

endmodule // SAL_BK_CTRL
