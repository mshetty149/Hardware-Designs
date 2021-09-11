module dff(
  input wire clk,
  input wire rst_n,

  input wire d_i,
  output reg q_o
);

  always@(posedge clk or negedge rst_n) begin

    if(rst_n == 1'b0) begin
      q_o <= 1'b0;
    end else begin
      q_o <= d_i;
    end

  end

endmodule
