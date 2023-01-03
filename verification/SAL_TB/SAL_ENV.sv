class environment;

     generator gen;

     virutal AXI_A_IF vif_axi_aw_if;
     virutal AXI_W_IF vif_axi_w_if;
     virutal AXI_B_IF vif_axi_b_if;
     virutal AXI_A_IF vif_axi_ar_if;
     virutal AXI_R_IF vif_axi_r_if;

     mailbox gen2driv;

     function new(
          virutal AXI_A_IF vif_axi_aw_if,
          virutal AXI_W_IF vif_axi_w_if,
          virutal AXI_B_IF vif_axi_b_if,
          virutal AXI_A_IF vif_axi_ar_if,
          virutal AXI_R_IF vif_axi_r_if     
     );
     this.vif_axi_aw_if  = vif_axi_aw_if;
     this.vif_axi_w_if   = vif_axi_w_if;
     this.vif_axi_b_if   = vif_axi_b_if;
     this.vif_axi_ar_if  = vif_axi_ar_if;
     this.vif_axi_r_if   = vif_axi_r_if;
     endfunction

     function void init();
          // Generator init
          gen            = new(gen2driv); // FIXME

          // Driver init
          this.vif_axi_aw_if.SRC_TB.init();  
          this.vif_axi_w_if.SRC_TB.init();  
          this.vif_axi_b_if.DST_TB.init();  
          this.vif_axi_ar_if.SRC_TB.init();  
          this.vif_axi_r_if.DST_TB.init();  

          // Monitor init 
          // FIXME          
     endfunction

     task driver_read();
          // loop 돌도록 하기.
          while(ar_queue.size()!=0) begin
               ar_addr = ar_queue.pop_front();
               this.vif_axi_ar_if.SRC_TB.transfer(ar_id,ar_addr,ar_len,ar_size,ar_burst); // id, addr, len, size, burst
               // tWTR delay 필요.
               this.vif_axi_r_if.SRC_TB.transfer(r_id,r_data,r_resp,r_last); // id, data, resp, last
          end
     endtask

     task driver_write();
          // loop 돌도록 하기.
          write_request_queue_empty_flag = (aw_queue.size()==0) & (w_queue.size()==0)
          while(!write_request_queue_empty_flag) begin
               aw_addr             = aw_queue.pop_front();
               {w_data,w_last}     = w_queue.pop_front();
               fork
                    this.vif_axi_aw_if.SRC_TB.transfer(aw_id,aw_addr,aw_len,aw_size,aw_burst); // id, addr, len, size, burst
                    this.vif_axi_w_if.SRC_TB.transfer(w_id, w_data, w_strb, w_last);           // id, data, strb, last
               join
               // tRTW delay 필요.
               this.vif_axi_b_if.SRC_TB.transfer(b_id,b_resp); // id, resp
          end
     endtask

     task driver();
          request_queue_empty_flag = (aw_queue.size()==0) & (w_queue.size()==0) & (ar_queue.size()==0)
          while(!request_queue_empty_flag)begin
               fork
                    driver_write();
                    driver_read();
               join
          end
     endtask


     bit [id,data,resp,last 합친거:0] answer_queue[$];      // FIXME
     bit [id:0] answer_id;                                  // FIXME
     bit [data:0] answer_data;                              // FIXME
     bit [resp:0] answer_resp;                              // FIXME
     bit          answer_last;                                  


     task monitor();
          // loop 돌도록 하기.
          while(answer_queue.size()!=0) begin
               this.vif_axi_r_if.DST_TB.receive(DUT_id,DUT_data,DUT_resp,DUT_last);
               {answer_id,answer_data,answer_resp,answer_last} = answer_queue.pop_front();
               if(answer_id == DUT_id) begin
                    $write("correct id || DUT_id[%b] answer_id[%b]",DUT_id,anwer_id);
                    if(answer_data == DUT_data) begin
                         $write("[correct data]");
                         $write("data       [0x%016h]        last[%b]        resp[%b]",DUT_data, DUT_last, DUT_resp);
                         $write("anwser_Data[0x%016h] answer_last[%b] answer_resp[%b]",answer_data, answer_last, answer_resp);
                         @(posedge clk);  
                    end
                    else begin
                         $write("[incorrect data]")
                         $write("data       [0x%016h]        last[%b]        resp[%b]",DUT_data, DUT_last, DUT_resp);
                         $write("anwser_Data[0x%016h] answer_last[%b] answer_resp[%b]",answer_data, answer_last, answer_resp);
                         $finish;
                    end
               end
               else begin
                    $write("incorrect id || DUT_id[%b] answer_id[%b]",DUT_id,anwer_id);
                    $finish;
               end
          end
     endtask

     task run();
          init();
          fork
               driver();
               monitor();
          join
     endtask

endclass