`timescale 1ns/1ps

`include "DDR2_parameters_0.v"

program SAL_TEST_BENCH(
     AXI_A_IF axi_aw_if,
     AXI_W_IF axi_w_if,
     AXI_B_IF axi_b_if,
     AXI_A_IF axi_ar_if,
     AXI_R_IF axi_r_if
     );
     environment env;
     initial begin
          $display("Environment setup");
          env = new(
               AXI_A_IF axi_aw_if,
               AXI_W_IF axi_w_if,
               AXI_B_IF axi_b_if,
               AXI_A_IF axi_ar_if,
               AXI_R_IF axi_r_if
          );
          $display("Env Run");
          env.run();

          $display("Env Run");
          $finish();          
     end
endprogram


