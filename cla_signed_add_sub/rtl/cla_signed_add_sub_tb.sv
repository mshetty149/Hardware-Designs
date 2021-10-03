`default_nettype none
`timescale 1ns/1ns
module cla_signed_add_sub_tb;

  localparam TIME_PERIOD = 10;
  localparam DATA_IN_W   = 16;
  
  reg                         clk;
  reg         [DATA_IN_W-1:0] inp_A;
  reg         [DATA_IN_W-1:0] inp_B;
  wire signed [DATA_IN_W-1:0] res;
  reg  signed [DATA_IN_W+1:0] act_res;
  reg                         carry;
  reg                         sub_nadd;
  int                         expected_res;

  always #(TIME_PERIOD/2) clk = ~clk;


  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,cla_signed_add_sub_tb);

    clk = 0 ;
    for (int k =0;k<=1;k++) begin
      sub_nadd = k;
      for (int i=-128;i<127;i++) begin
        for (int j=-128;j<127;j++)begin
          inp_A = i;
          inp_B = j;
          expected_res = (sub_nadd) ? (i-j)  : (i+j);
          @(posedge clk);
          act_res = (sub_nadd) ? res  : res;
          if (expected_res === act_res)
            $display("PASSED: CLA ADD_SUB OUTPUT MATCHED opr:%0d inp_A: %0d, inp_B: %0d,  EXPECTED: %0d, ACTUAL: %0d",sub_nadd,i,j,expected_res,act_res);
          else begin
            $display("FAILED: CLA ADD_SUB OUTPUT MISMATCHED opr:%0d inp_A: %0d, inp_B: %0d, EXPECTED: %0d, ACTUAL: %0d",sub_nadd,i,j,expected_res,act_res);
            $finish;
          end
        end
      end
    end
    $display("PASSED: CLA ADD_SUB TESTCASE COMPLETED SUCCESSFULLY");
    $finish;

  end

  cla_signed_add_sub #(
    .DATA_IN_W(DATA_IN_W)
  ) inst_cla_signed_add_sub (
      .sub_nadd(sub_nadd),
      .inp_A_i (inp_A   ),
      .inp_B_i (inp_B   ),
      .carry_o (carry   ),
      .out_o   (res     )
  );



endmodule

