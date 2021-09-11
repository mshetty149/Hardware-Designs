//Module: Booth Multiplier TB
//Author: Manish Shetty
//Revision: 1.0
`default_nettype none
`timescale 1ns/1ns 

module booth_mult_tb;

  parameter TIME_PERIOD = 10;
  parameter MUL_A_W = 8;
  parameter MUL_B_W = 8;
  parameter MUL_OUT_W = 16;

  reg   clk=0;                           
  reg   rst_n;                         
  reg   in_valid;                      
  wire  out_valid;                     
  reg   signed [MUL_A_W-1    :     0]  in_A;  
  reg   signed [MUL_B_W-1    :     0]  in_B;  
  wire  signed [MUL_OUT_W-1  :     0]  out_data;  
  reg   signed [MUL_OUT_W-1  :     0]  ref_data;  
  integer i,j;

  always clk = #TIME_PERIOD ~clk;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,booth_mult_tb);
    rst_n = 1'b1;
    repeat(2)@(posedge clk);
    rst_n = 1'b0;
    repeat(2)@(posedge clk);
    rst_n = 1'b1;
    for(i=-127;i<128;i++) begin
      for(j=-127;j<128;j++) begin
        in_valid = 1'b1;
        in_A = i;
        in_B = j;
        ref_data = in_A*in_B;
        repeat(2)@(posedge clk);
        in_valid = 1'b0;
        @(posedge clk);
        while (!out_valid) begin
          @(posedge clk);
        end
        if(out_data === ref_data) begin
          $display("DATA MATCHED  for inputs A:%4d B:%4d output: %6d",in_A,in_B,out_data,$time);
        end else begin
          $fatal(1,"DATA MISMATCH output_data expected: %0d, Actual: %0d",ref_data,out_data,$time);
        end
        @(posedge clk);
      end
    end
    $finish;
  end

//  initial $monitor("At time %0t in_valid: %0b in_A: %0d in_B: %0d ref_data: %0h out_valid:%0b out_data : %0h",$time,in_valid,in_A,in_B,ref_data,out_valid,out_data);


  booth_mult#(
    .MUL_A_W(MUL_A_W), 
    .MUL_B_W(MUL_B_W),
    .MUL_OUT_W(MUL_OUT_W)
  ) inst_booth_mul(
    .clk             (clk),
    .rst_n           (rst_n),
    .in_valid_i      (in_valid),
    .in_A_i          (in_A),
    .in_B_i          (in_B),
    .out_valid_o     (out_valid),
    .mult_out_o      (out_data)

  );

endmodule
