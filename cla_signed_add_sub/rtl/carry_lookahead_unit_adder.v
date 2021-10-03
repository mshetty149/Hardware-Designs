`default_nettype none
module carry_lookahead_unit_adder#(
  parameter DATA_IN_W = 4
)(
  input  wire                 carry_in_i,
  input  wire [DATA_IN_W-1:0] inp_A_i,
  input  wire [DATA_IN_W-1:0] inp_B_i,

  output wire                 gr_carry_prop_o,
  output wire                 gr_carry_gen_o,
  output wire                 carry_o,
  output wire [DATA_IN_W-1:0] sum_o
);

//Internal wires and regs  
  wire [DATA_IN_W  :0] carry;
  wire [DATA_IN_W-1:0] carry_gen;
  wire [DATA_IN_W-1:0] carry_prop;
  genvar i;

  //FULL ADDER
  assign carry_gen  = inp_A_i & inp_B_i ;
  assign carry_prop = inp_A_i ^ inp_B_i ;
  assign sum_o      = carry_prop ^ (carry[DATA_IN_W-1:0]) ;

  //CARRY_LOOK_AHEAD_LOGIC
  cla_logic#( 
    .CARRY_OUT_SIZE(DATA_IN_W)
  ) inst_cla_logic(
    .carry_i         (carry_in_i),
    .carry_prop_i    (carry_prop),
    .carry_gen_i     (carry_gen),
    .carry_o         (carry),
    .gr_carry_prop_o (gr_carry_prop_o),
    .gr_carry_gen_o  (gr_carry_gen_o)
  );

  assign carry_o = carry[DATA_IN_W];

endmodule
