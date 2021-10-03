//Developer    : Manish Shetty
//Dedscription : This block can perform signed addition(A+B) or
//               subtraction(A-B) based on sub_nadd signal, For increased
//               performance carry lookahead logic is used instead of simple
//               ripple adder
`default_nettype none
module cla_signed_add_sub #(
  parameter DATA_IN_W = 16
)(

  input  wire                        sub_nadd,
  input  wire signed [DATA_IN_W-1:0] inp_A_i,
  input  wire signed [DATA_IN_W-1:0] inp_B_i,

  output wire                        carry_o,
  output wire signed [DATA_IN_W-1:0] out_o
);

  localparam CLA_DATA_IN_W = 4;
  localparam NUM_CLA_UNITS = DATA_IN_W/CLA_DATA_IN_W;
  wire [NUM_CLA_UNITS-1:0] carry_prop;
  wire [NUM_CLA_UNITS-1:0] carry_gen;
  wire [NUM_CLA_UNITS-1:0] carry;
  wire [DATA_IN_W-1:0]     inp_B;
  genvar i;

  assign inp_B = inp_B_i ^ {(DATA_IN_W){sub_nadd}} ;
  //CARRY_LOOKAHEAD_UNIT_ADDER
  generate
    for(i=0;i<NUM_CLA_UNITS;i=i+1) begin : CLA_UNIT
      carry_lookahead_unit_adder #(
        .DATA_IN_W(CLA_DATA_IN_W)
      ) inst_cla_unit_adder (
          .carry_in_i       (carry[i]                                     ),
          .inp_A_i          (inp_A_i[i*CLA_DATA_IN_W+:CLA_DATA_IN_W]      ),
          .inp_B_i          (inp_B[i*CLA_DATA_IN_W+:CLA_DATA_IN_W]      ),
          .gr_carry_prop_o  (carry_prop[i]                                ),
          .gr_carry_gen_o   (carry_gen[i]                                 ),
          .carry_o          (                                             ),//OPEN
          .sum_o            (out_o[i*CLA_DATA_IN_W+:CLA_DATA_IN_W]      )
      );
    end
  endgenerate

  cla_logic #(
    .CARRY_OUT_SIZE(NUM_CLA_UNITS)
  ) inst_cla_logic(
    .carry_i         (sub_nadd),
    .carry_prop_i    (carry_prop),
    .carry_gen_i     (carry_gen ),
    .carry_o         ({carry_o,carry}),
    .gr_carry_prop_o (),//OPEN
    .gr_carry_gen_o  () //OPEN
  );

endmodule

