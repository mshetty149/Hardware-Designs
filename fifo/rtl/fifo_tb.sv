//Module: Generic FIFO
//Author: Manish Shetty
//Revision: 1.0
`default_nettype none
`timescale 1ns/1ns

module fifo_tb;

  parameter  TIME_PERIOD = 4 ;
  parameter  FIFO_DEPTH = 16;
  parameter  FIFO_DEPTHLOG2 = 5;
  parameter  DATA_W  = 8;



  reg              clk;
  reg              rst_n;
  reg              fifo_wr_en;
  reg              fifo_init;
  reg[DATA_W-1:0]  fifo_wr_data;
  reg              fifo_rd_en;
  wire[DATA_W-1:0] fifo_rd_data;
  int              sw_queue[$];
  wire             fifo_full;
  wire             fifo_empty;
  int              st;
  int              read_cntr;

  always #(TIME_PERIOD/2) clk = ~clk;

  initial begin
    int num_jobs ;
    $dumpfile("test.vcd");
    $dumpvars(0,fifo_tb);
    num_jobs = 20;
    clk = 0;
    read_cntr = 0;
    fifo_rd_en = 0;
    fifo_wr_en = 0;
    @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    repeat(5) @(posedge clk);
    fork 
      wr_master(num_jobs);
      rd_master();
    join
    $display("COMPLETED: FIFO RANDOM READ WRITE TESTCASE num_reads done = %0d and num_writes done = %0d",num_jobs,num_jobs);
    $finish;
  end

  fifo#(
    .DATA_W(DATA_W),
    .FIFO_DEPTH(FIFO_DEPTH),
    .FIFO_DEPTHLOG2(FIFO_DEPTHLOG2)
  ) inst_fifo
  (
    .clk           ( clk            ),
    .rst_n         ( rst_n          ),
    .fifo_init     ( fifo_init      ),
    .fifo_wr_en    ( fifo_wr_en     ),
    .fifo_wr_data  ( fifo_wr_data   ),
    .fifo_empty    ( fifo_empty     ),
    .fifo_full     ( fifo_full      ),
    .fifo_rd_en    ( fifo_rd_en     ),
    .fifo_rdata    ( fifo_rd_data   )
  );


  task wr_master(input int num_jobs=8);
    int wdata;
    for(int i=0;i<num_jobs;i++) begin
      while(fifo_full)
        @(posedge clk);
      wdata = $urandom_range(0,2**(DATA_W)-1);
      sw_queue.push_back(wdata);
      fifo_write(wdata);
      repeat(2) @(posedge clk);
    end
  endtask:wr_master

  task rd_master();
    int rdata,ref_data;
    repeat(2) @(posedge clk);
    while(sw_queue.size() != 0) begin
      while(fifo_empty)
        @(posedge clk);
      fifo_read(rdata);
      ref_data = sw_queue.pop_front();
      if(rdata !== ref_data) begin
        $display("FAILED: FIFO READ DATA MISMATCH, EXPECTED : %3d ACTUAL DATA: %3d",ref_data,rdata);
        $finish;
      end else begin
        $display("PASSED: FIFO READ DATA %2d MATCHED, EXPECTED : %3d ACTUAL DATA: %3d",read_cntr,ref_data,rdata);
        read_cntr++;
      end
      repeat(10) @(posedge clk);
    end
  endtask:rd_master

  task fifo_write (input int wdata);
    fifo_wr_en   <= 1'b1;
    fifo_wr_data <= wdata;
    @(posedge clk);
    fifo_wr_en   <= 1'b0;
  endtask: fifo_write


  task fifo_read (output int rdata);
    fifo_rd_en   <= 1'b1;
    rdata        <= fifo_rd_data;
    @(posedge clk);
    fifo_rd_en   <= 1'b0;
  endtask:fifo_read



endmodule
