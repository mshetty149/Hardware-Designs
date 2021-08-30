//Module: Generic FIFO
//Author: Manish Shetty
//Revision: 1.0
`default_nettype none

module fifo#(
  parameter DATA_W = 8,
  parameter FIFO_DEPTH = 16,
  parameter FIFO_DEPTHLOG2 = 5
)
(
  input  wire                 clk,
  input  wire                 rst_n,

  input  wire                 fifo_init,

  input  wire                 fifo_wr_en,
  input  wire [DATA_W-1:0]    fifo_wr_data,

  output wire                 fifo_empty,
  output wire                 fifo_full,
  input  wire                 fifo_rd_en,
  output wire [DATA_W-1:0]    fifo_rdata

);

  reg [FIFO_DEPTHLOG2-1:0] reg_wr_ptr;
  reg [FIFO_DEPTHLOG2-1:0] reg_rd_ptr;
  reg [FIFO_DEPTHLOG2-1:0] reg_fifo_space_used;
  reg [DATA_W-1:0]         reg_fifo_bank[0:FIFO_DEPTH-1];



  always@(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      reg_wr_ptr <= {(FIFO_DEPTHLOG2){1'b0}}; 
      reg_rd_ptr <= {(FIFO_DEPTHLOG2){1'b0}}; 
      reg_fifo_space_used <= {(FIFO_DEPTHLOG2){1'b0}}; 
    end else begin
      if(fifo_wr_en) begin
        if(reg_wr_ptr == FIFO_DEPTH - 1)
          reg_wr_ptr <= {(FIFO_DEPTHLOG2){1'b0}}; 
        else
          reg_wr_ptr <= reg_wr_ptr + 1'b1;
        reg_fifo_space_used <= reg_fifo_space_used + 1'b1 ;
      end
      if(fifo_rd_en) begin
        if(reg_rd_ptr == FIFO_DEPTH - 1 )
          reg_rd_ptr <= {(FIFO_DEPTHLOG2){1'b0}}; 
        else
          reg_rd_ptr <= reg_rd_ptr + 1'b1;
        reg_fifo_space_used <= reg_fifo_space_used - 1'b1 ;
      end
      if(fifo_rd_en && fifo_wr_en) begin
        reg_fifo_space_used <= reg_fifo_space_used;
      end
      if(fifo_init) begin
        reg_wr_ptr <= {(FIFO_DEPTHLOG2){1'b0}}; 
        reg_rd_ptr <= {(FIFO_DEPTHLOG2){1'b0}}; 
        reg_fifo_space_used <= {(FIFO_DEPTHLOG2){1'b0}}; 
      end
    end
  end

  always@(posedge clk) begin
    if(fifo_wr_en)
      reg_fifo_bank[reg_wr_ptr] <= fifo_wr_data;
  end


  assign fifo_rdata   = reg_fifo_bank[reg_rd_ptr];
  assign fifo_full    = (reg_fifo_space_used == FIFO_DEPTH);
  assign fifo_empty   = (reg_fifo_space_used == 'd0);

endmodule
