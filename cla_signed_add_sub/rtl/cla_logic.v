`default_nettype none
module cla_logic #(
  parameter CARRY_OUT_SIZE = 16
)(
  input  wire                      carry_i,
  input  wire [CARRY_OUT_SIZE-1:0] carry_gen_i,
  input  wire [CARRY_OUT_SIZE-1:0] carry_prop_i,

  output wire                      gr_carry_gen_o,
  output wire                      gr_carry_prop_o,
  output wire [CARRY_OUT_SIZE:0]   carry_o 
);

  reg   [CARRY_OUT_SIZE-1:0]temp_carry_gen;
  genvar i;



  generate 
    for(i=0;i<=CARRY_OUT_SIZE;i=i+1) begin : CARRY_OUT_GEN
      if(i==0)
        assign carry_o[i]       = carry_i ;
      else
        assign carry_o[i]       = (carry_gen_i[i-1] | (carry_prop_i[i-1] & carry_o[i-1]));
    end
    for(i=0;i<CARRY_OUT_SIZE;i=i+1) begin : CARRY_GENERATE_GEN
      if (i==0)
        assign temp_carry_gen[i]  = carry_gen_i[i]; 
      else
        assign temp_carry_gen[i]  = (carry_gen_i[i] | (carry_prop_i[i] & (temp_carry_gen[i-1])));
    end
  endgenerate

  assign gr_carry_prop_o = (&carry_prop_i);
  assign gr_carry_gen_o  = temp_carry_gen[CARRY_OUT_SIZE-1];


endmodule
