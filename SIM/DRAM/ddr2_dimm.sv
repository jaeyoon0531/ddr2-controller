`timescale 1ps / 1ps

module ddr2_dimm (
    input   wire                ck,
    input   wire                ck_n,
    input   wire                cke,
    input   wire                cs_n,
    input   wire                ras_n,
    input   wire                cas_n,
    input   wire                we_n,
    input   wire    [1:0]       ba,
    input   wire    [14:0]      addr,
    input   wire                odt,
    inout   wire    [63:0]      dq,
    inout   wire    [7:0]       dqs,
    inout   wire    [7:0]       dqs_n,
    inout   wire    [7:0]       rdqs_n,
    inout   wire    [7:0]       dm_rdqs
);

    genvar gen_chip;

    for (gen_chip=0; gen_chip<16; gen_chip=gen_chip+1) begin: chip
        ddr2_model                      u_dram
        (
            // command and address
            .ck                         (ck),
            .ck_n                       (ck_n),
            .cke                        (cke),
            .cs_n                       (cs_n),
            .ras_n                      (ras_n),
            .cas_n                      (cas_n),
            .we_n                       (we_n),
            .ba                         (ba),
            .addr                       (addr),
            .odt                        (odt),

            // data
            .dq                         (ddr_dq[8*gen_chip+:8]),
            .dqs                        (ddr_dqs[gen_chip]),
            .dqs_n                      (ddr_dqs_n[gen_chip]),
            .dm_rdqs                    (ddr_dm_rdqs[gen_chip]),
            .rdqs_n                     (ddr_rdqs_n[gen_chip])
        );
    end

endmodule
