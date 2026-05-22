`timescale 1ns/1ps

module uart_tx_rx_fifo_tb;

  logic        clk_i;
  logic        rst_n_i;

  logic        tx_wr_en_i;
  logic [15:0] tx_wr_data_i;
  logic [15:0] tx_rd_data_o;
  logic        tx_full_o;
  logic        tx_empty_o;

  logic        rx_wr_en_i;
  logic [15:0] rx_wr_data_i;
  logic [15:0] rx_rd_data_o;
  logic        rx_full_o;
  logic        rx_empty_o;

  integer i;

  uart_tx_rx_fifo dut (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .tx_wr_en_i(tx_wr_en_i),
    .tx_wr_data_i(tx_wr_data_i),
    .tx_rd_data_o(tx_rd_data_o),
    .tx_full_o(tx_full_o),
    .tx_empty_o(tx_empty_o),

    .rx_wr_en_i(rx_wr_en_i),
    .rx_wr_data_i(rx_wr_data_i),
    .rx_rd_data_o(rx_rd_data_o),
    .rx_full_o(rx_full_o),
    .rx_empty_o(rx_empty_o)
  );

  // Clock
  always #5 clk_i = ~clk_i;

  initial begin
    clk_i        = 0;
    rst_n_i      = 0;

    tx_wr_en_i   = 0;
    tx_wr_data_i = 0;

    rx_wr_en_i   = 0;
    rx_wr_data_i = 0;

    #20;
    rst_n_i = 1;

    // Normal TX write
    @(posedge clk_i);
    tx_wr_en_i   = 1;
    tx_wr_data_i = 16'hA5A5;

    @(posedge clk_i);
    tx_wr_en_i = 0;

    // Normal RX write
    @(posedge clk_i);
    rx_wr_en_i   = 1;
    rx_wr_data_i = 16'h5A5A;

    @(posedge clk_i);
    rx_wr_en_i = 0;

    #20;

    $display("TX Data Read = %h", tx_rd_data_o);
    $display("RX Data Read = %h", rx_rd_data_o);

    // TX overflow test
    for (i = 0; i < 20; i = i + 1) begin
      @(posedge clk_i);
      tx_wr_en_i   = 1;
      tx_wr_data_i = i;

      if (tx_full_o)
        $display("TX FIFO FULL at count = %0d", i);
    end

    @(posedge clk_i);

    if (tx_full_o)
      $display("TX overflow detected");
    else
      $display("ERROR: TX overflow not detected");

    tx_wr_en_i = 0;

    // RX overflow test
    for (i = 0; i < 20; i = i + 1) begin
      @(posedge clk_i);
      rx_wr_en_i   = 1;
      rx_wr_data_i = i + 16'h1000;

      if (rx_full_o)
        $display("RX FIFO FULL at count = %0d", i);
    end

    @(posedge clk_i);

    if (rx_full_o)
      $display("RX overflow detected");
    else
      $display("ERROR: RX overflow not detected");

    rx_wr_en_i = 0;

    #50;
    $finish;
  end

endmodule
