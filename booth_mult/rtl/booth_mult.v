//Module: Booth Multiplier 
//Author: Manish Shetty
//Revision: 1.0
`default_nettype none

module booth_mult#(
  parameter MUL_A_W =8, 
  parameter MUL_B_W =8,
  parameter MUL_OUT_W = 16
)(
  input wire clk,
  input wire rst_n,
  
  input wire in_valid_i,
  input wire signed [MUL_A_W-1 : 0]in_A_i,
  input wire signed [MUL_B_W-1 : 0]in_B_i,

  output reg                   out_valid_o,
  output reg signed [MUL_OUT_W-1 : 0] mult_out_o

);

  localparam MUL_A_W_LOG2 = 4;//$log2(MUL_A_W);

  //Internal wires and regs
  reg  multr_qn;            
  reg  signed [MUL_B_W-1       :  0]  part_prod_d;
  reg  signed [MUL_B_W-1       :  0]  part_prod;
  reg  signed [MUL_B_W-1       :  0]  multd;
  reg  signed [MUL_A_W-1       :  0]  multr;
  reg  [MUL_A_W_LOG2-1  :  0]  cntr;



  always@(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      part_prod_d   <= {(MUL_B_W){1'b0}};
      multr_qn <= 1'b0;
      cntr  <= MUL_A_W;
    end else begin
      if(in_valid_i) begin
        part_prod_d   <= {(MUL_B_W){1'b0}};
        multr_qn <= 1'b0;
        cntr  <= MUL_A_W;
      end else begin 
        if(cntr != {(MUL_A_W_LOG2){1'b0}}) begin
          cntr <= cntr - 1'b1;
          multr_qn <= multr[0];
          if(multr_qn^multr[0] == 1'b1) begin
            part_prod_d <= part_prod >>>1;
          end else begin
            part_prod_d <= part_prod_d >>>1;
          end
        end
      end
    end
  end

  always@(posedge clk) begin
    if (in_valid_i) begin
      multd <= in_B_i;
      multr <= in_A_i;
    end else begin
      if (cntr != {(MUL_A_W_LOG2){1'b0}}) begin
        if(multr_qn^multr[0] == 1'b1) begin
          multr <= {part_prod[0],multr[MUL_A_W-1:1]};
        end else  begin
          multr <= {part_prod_d[0],multr[MUL_A_W-1:1]};
        end
      end
    end
  end 
  
  always@(*) begin
    part_prod   = (multr[0]==1'b1) ? part_prod_d - multd : part_prod_d + multd;
    out_valid_o = (cntr=={(MUL_A_W_LOG2){1'b0}});
    mult_out_o  = {part_prod_d,multr};
  end


endmodule
