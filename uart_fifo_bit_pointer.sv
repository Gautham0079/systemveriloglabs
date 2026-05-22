module uart_tx_rx_fifo (
  input  logic        clk_i,
  input  logic        rst_n_i,

  // TX Interface
  input  logic        tx_wr_en_i,
  input  logic [15:0] tx_wr_data_i,
  output logic [15:0] tx_rd_data_o,
  output logic        tx_full_o,
  output logic        tx_empty_o,

  // RX Interface
  input  logic        rx_wr_en_i,
  input  logic [15:0] rx_wr_data_i,
  output logic [15:0] rx_rd_data_o,
  output logic        rx_full_o,
  output logic        rx_empty_o
);

  logic [15:0] tx_mem_q;
  logic        tx_valid_q;

  logic [15:0] rx_mem_q;
  logic        rx_valid_q;

  assign tx_full_o  = tx_valid_q;
  assign tx_empty_o = ~tx_valid_q;

  assign rx_full_o  = rx_valid_q;
  assign rx_empty_o = ~rx_valid_q;

  // TX storage
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      tx_mem_q     <= 16'b0;
      tx_rd_data_o <= 16'b0;
      tx_valid_q   <= 1'b0;
    end
    else begin
      if (tx_wr_en_i && !tx_full_o) begin
        tx_mem_q   <= tx_wr_data_i;
        tx_valid_q <= 1'b1;
      end

      if (!tx_empty_o) begin
        tx_rd_data_o <= tx_mem_q;
        tx_valid_q   <= 1'b0;
      end
    end
  end

  // RX storage
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      rx_mem_q     <= 16'b0;
      rx_rd_data_o <= 16'b0;
      rx_valid_q   <= 1'b0;
    end
    else begin
      if (rx_wr_en_i && !rx_full_o) begin
        rx_mem_q   <= rx_wr_data_i;
        rx_valid_q <= 1'b1;
      end

      if (!rx_empty_o) begin
        rx_rd_data_o <= rx_mem_q;
        rx_valid_q   <= 1'b0;
      end
    end
  end

endmodule
