module uart_tx_rx_fifo #(
  parameter int DATA_WIDTH = 16,
  parameter int DEPTH = 2
)(
  input  logic                  clk_i,
  input  logic                  rst_n_i,

  // TX Interface
  input  logic                  tx_wr_en_i,
  input  logic                  tx_rd_en_i,
  input  logic [DATA_WIDTH-1:0] tx_wr_data_i,
  output logic [DATA_WIDTH-1:0] tx_rd_data_o,
  output logic                  tx_full_o,
  output logic                  tx_empty_o,

  // RX Interface
  input  logic                  rx_wr_en_i,
  input  logic                  rx_rd_en_i,
  input  logic [DATA_WIDTH-1:0] rx_wr_data_i,
  output logic [DATA_WIDTH-1:0] rx_rd_data_o,
  output logic                  rx_full_o,
  output logic                  rx_empty_o
);

  logic [DATA_WIDTH-1:0] tx_mem_q [0:DEPTH-1];
  logic [DATA_WIDTH-1:0] rx_mem_q [0:DEPTH-1];

  logic [$clog2(DEPTH)-1:0] tx_wr_ptr_q, tx_rd_ptr_q;
  logic [$clog2(DEPTH)-1:0] rx_wr_ptr_q, rx_rd_ptr_q;

  logic [$clog2(DEPTH+1)-1:0] tx_count_q;
  logic [$clog2(DEPTH+1)-1:0] rx_count_q;

  assign tx_full_o  = (tx_count_q == DEPTH);
  assign tx_empty_o = (tx_count_q == 0);

  assign rx_full_o  = (rx_count_q == DEPTH);
  assign rx_empty_o = (rx_count_q == 0);

  // TX FIFO
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      tx_wr_ptr_q  <= '0;
      tx_rd_ptr_q  <= '0;
      tx_count_q   <= '0;
      tx_rd_data_o <= '0;
    end
    else begin

      if (tx_wr_en_i && !tx_full_o) begin
        tx_mem_q[tx_wr_ptr_q] <= tx_wr_data_i;
        tx_wr_ptr_q <= tx_wr_ptr_q + 1;
        tx_count_q  <= tx_count_q + 1;
      end

      if (tx_rd_en_i && !tx_empty_o) begin
        tx_rd_data_o <= tx_mem_q[tx_rd_ptr_q];
        tx_rd_ptr_q  <= tx_rd_ptr_q + 1;
        tx_count_q   <= tx_count_q - 1;
      end
    end
  end

  // RX FIFO
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      rx_wr_ptr_q  <= '0;
      rx_rd_ptr_q  <= '0;
      rx_count_q   <= '0;
      rx_rd_data_o <= '0;
    end
    else begin

      if (rx_wr_en_i && !rx_full_o) begin
        rx_mem_q[rx_wr_ptr_q] <= rx_wr_data_i;
        rx_wr_ptr_q <= rx_wr_ptr_q + 1;
        rx_count_q  <= rx_count_q + 1;
      end

      if (rx_rd_en_i && !rx_empty_o) begin
        rx_rd_data_o <= rx_mem_q[rx_rd_ptr_q];
        rx_rd_ptr_q  <= rx_rd_ptr_q + 1;
        rx_count_q   <= rx_count_q - 1;
      end
    end
  end

endmodule
