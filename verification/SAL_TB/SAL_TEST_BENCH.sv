`timescale 1ns/1ps

`include "DDR2_parameters_0.v"

program SAL_TEST_BENCH(
     AXI_A_IF master_axi_aw_if,
     AXI_W_IF master_axi_w_if,
     AXI_B_IF master_axi_b_if,
     AXI_A_IF master_axi_ar_if,
     AXI_R_IF master_axi_r_if,

     AXI_A_IF slave_axi_aw_if,
     AXI_W_IF slave_axi_w_if,
     AXI_B_IF slave_axi_b_if,
     AXI_A_IF slave_axi_ar_if,
     AXI_R_IF slave_axi_r_if

     );
     environment env;
     initial begin
          $display("Environment setup");
          env = new(
               AXI_A_IF master_axi_aw_if,
               AXI_W_IF master_axi_w_if,
               AXI_B_IF master_axi_b_if,
               AXI_A_IF master_axi_ar_if,
               AXI_R_IF master_axi_r_if,

               AXI_A_IF slave_axi_aw_if,
               AXI_W_IF slave_axi_w_if,
               AXI_B_IF slave_axi_b_if,
               AXI_A_IF slave_axi_ar_if,
               AXI_R_IF slave_axi_r_if
          );
          $display("Env Run");
          env.run();

          $display("Env Run");
          $finish();          
     end
endprogram


