class environment;

     generator gen;

     virutal AXI_A_IF.SRC_TB master_axi_aw_if;
     virutal AXI_W_IF.SRC_TB master_axi_w_if;
     virutal AXI_B_IF.SRC_TB master_axi_b_if;
     virutal AXI_A_IF.SRC_TB master_axi_ar_if;
     virutal AXI_R_IF.SRC_TB master_axi_r_if;

     virutal AXI_A_IF slave_axi_aw_if;
     virutal AXI_W_IF slave_axi_w_if;
     virutal AXI_B_IF slave_axi_b_if;
     virutal AXI_A_IF slave_axi_ar_if;
     virutal AXI_R_IF slave_axi_r_if;

     function new(
          virutal AXI_A_IF.SRC_TB master_axi_aw_if,
          virutal AXI_W_IF.SRC_TB master_axi_w_if,
          virutal AXI_B_IF.SRC_TB master_axi_b_if,
          virutal AXI_A_IF.SRC_TB master_axi_ar_if,
          virutal AXI_R_IF.SRC_TB master_axi_r_if,     

          virutal AXI_A_IF slave_axi_aw_if,
          virutal AXI_W_IF slave_axi_w_if,
          virutal AXI_B_IF slave_axi_b_if,
          virutal AXI_A_IF slave_axi_ar_if,
          virutal AXI_R_IF slave_axi_r_if     

     );
     this.master_axi_aw_if  = master_axi_aw_if;
     this.master_axi_w_if   = master_axi_w_if;
     this.master_axi_b_if   = master_axi_b_if;
     this.master_axi_ar_if  = master_axi_ar_if;
     this.master_axi_r_if   = master_axi_r_if;

     this.master_axi_aw_if  = slave_axi_aw_if;
     this.master_axi_w_if   = slave_axi_w_if;
     this.master_axi_b_if   = slave_axi_b_if;
     this.master_axi_ar_if  = slave_axi_ar_if;
     this.master_axi_r_if   = slave_axi_r_if;

     endfunction

     function void init();
          // Generator init
          gen            = new(gen2driv); // FIXME

          // Driver init
          this.master_axi_aw_if.init();  
          this.master_axi_w_if.init();  
          this.master_axi_b_if.init();  
          this.master_axi_ar_if.init();  
          this.master_axi_r_if.init();  

          // Monitor init 
          this.master_axi_r_if.DST_TB.init();
          // FIXME          
     endfunction
     
     logic [`AXI_ID_WIDTH-1+3:0]    answer_signal_queue[$];      
     reg   [127:0]                  answer_data_queue[$];
     
     logic [31:0]        aw_addr[8];
     logic [127:0]       w_data[8];
     logic [31:0]        ar_addr[8];        

     // control signal initialize 
     logic []  id = 0;
     logic [1:0] resp = `AXI_RESP_OKAY;

     task gen();
          int repeat_cnt = 100;
          int addr[8];

          addr = [32'h000230EC,32'h00023088,32'h00023198,32'h00023154,32'h0003C0EC,32'h0003C0EC,32'h0003C0EC,32'h0003C0EC];
          // 32bit 
          // 10987654321098765432109876543210
          // bank   31:24 = 8bit
          // row    23:11 = 13bit
          // cal    10:3  = 8bit
          // offset 2:0   = 3bit

          for (int bank=1; bank=<4; bank*=2) begin
               addr = addr + (32'h00010000 << bank);
               for (int row=1; row=<4; row*=2) begin
                    addr = addr + (32'h00000800 << row);
                    for (int index=0;index<8;index+=1) begin
                         aw_addr[index] = addr[index];
                         ar_addr[index] = addr[8-index];
                         data[index]    = $random;
                    end
               end
          end
          while (repeat_cnt != 0) begin
               for (int index=0; index<8; index+=1) begin
                    aw_queue.push_back(aw_addr[index]);
                    ar_queue.push_back(ar_addr[index]);
                    w_queue.push_back(data[index]);                                            // input data
                    answer_data_queue.push_back(ar_addr[index]) = w_data[index];	          // answer data
                    answer_signal_queue.push_back({this.slave_axi_r_if.rid,
                                                   this.slave_axi_r_if.rresp,
                                                   this.slave_axi_r_if.rlast});
		     end
               repeat_cnt -= 1;
          end
     endtask

     task driver_read();

          while(ar_queue.size()!=0) begin
               ar_addr = ar_queue.pop_front();
               this.master_axi_ar_if.SRC_TB.transfer(this.slave_axi_ar_if.aid,
                                                     this.slave_axi_ar_if.aaddr,
                                                     this.slave_axi_ar_if.alen,
                                                     this.slave_axi_ar_if.asize,
                                                     this.slave_axi_ar_if.aburst); // id, addr, len, size, burst
               // tWTR delay 필요.
               this.master_axi_r_if.SRC_TB.transfer(this.slave_axi_r_if.rid,
                                                    this.slave_axi_r_if.rdata,
                                                    this.slave_axi_r_if.rresp,
                                                    this.slave_axi_r_if.rlast); // id, data, resp, last
          end
     endtask

     task driver_write();
          this.slave_axi_aw_if.aid = id;

          write_request_queue_empty_flag = (aw_queue.size()==0) & (w_queue.size()==0);
          while(!write_request_queue_empty_flag) begin
               aw_addr             = aw_queue.pop_front();
               {w_data,w_last}     = w_queue.pop_front();
               fork
                    this.master_axi_aw_if.SRC_TB.transfer(this.slave_axi_aw_if.aid,
                                                          this.slave_axi_aw_if.aaddr,
                                                          this.slave_axi_aw_if.alen,
                                                          this.slave_axi_aw_if.asize,
                                                          this.slave_axi_aw_if.aburst); // id, addr, len, size, burst
                    this.master_axi_w_if.SRC_TB.transfer(this.slave_axi_w_if.wid, 
                                                         this.slave_axi_w_if.wdata, 
                                                         this.slave_axi_w_if.wstrb, 
                                                         this.slave_axi_w_if.wlast);           // id, data, strb, last
               join
               // tRTW delay 필요.
               this.master_axi_b_if.SRC_TB.transfer(this.slave_axi_b_if.bid,
                                                    this.slave_axi_b_if.bresp); // id, resp
          end
     endtask

     task driver();
          request_queue_empty_flag = (aw_queue.size()==0) & (w_queue.size()==0) & (ar_queue.size()==0);
          while(!request_queue_empty_flag)begin
               fork
                    driver_write();
                    driver_read();
               join
          end
     endtask




     task monitor();
          logic [`AXI_ID_WIDTH-1:0]     answer_id;                                  
          logic [`AXI_DATA_WIDTH-1:0]   answer_data;                              
          logic [1:0]                   answer_resp;                              
          logic                         answer_last;                                  

          // loop 돌도록 하기.
          while(answer_queue.size()!=0) begin
               this.master_axi_r_if.DST_TB.receive(DUT_id,DUT_data,DUT_resp,DUT_last);
               {answer_id,answer_resp,answer_last} = answer_signal_queue.pop_front();
               answer_data                         = answer_data_queue.pop_front();
               if(answer_id == DUT_id) begin
                    $write("correct id || DUT_id[%b] answer_id[%b]",DUT_id,answer_id);
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
                    $write("incorrect id || DUT_id[%b] answer_id[%b]",DUT_id,answer_id);
                    $finish;
               end
          end
     endtask

     task run();
          init();
          gen();
          fork
               driver();
               monitor();
          join
     endtask

endclass