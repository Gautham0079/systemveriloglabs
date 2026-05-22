module tb_uart_rx;

  logic clk_i;
  logic rst_n_i;
  logic baud_tick_i;
  logic rx_i;
  logic start;
  logic [2:0] parity_i;
  logic [1:0] data_bits_i;
  logic [7:0] data_o;
  logic data_valid_o;
  logic rx_busy_o;

  // Instantiate the DUT
  uart_rx dut (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .baud_tick_i(baud_tick_i),
    .rx_i(rx_i),
    .start(start),
    .parity_i(parity_i),
    .data_bits_i(data_bits_i),
    .data_o(data_o),
    .data_valid_o(data_valid_o),
    .rx_busy_o(rx_busy_o)
  );

  initial clk_i = 0;
  always #5 clk_i = ~clk_i;

  // Reset sequence

  initial begin
    rst_n_i = 0;
    rx_i = 1;
    #5rst_n_i = 1;
    start=1'b1;
    data_bits_i = 2'b11;
    #5 start=0;
	parity_i = 3'b000;
    send_serial(8'b10110111); 
  end

  // Generate baud tick
  	  initial baud_tick_i = 0;
      always #5 baud_tick_i =~baud_tick_i;



  // Send serial data on rx_i

  task send_serial(input [7:0] data);
    integer i;
    begin
      for (i = 0; i < 8; i = i + 1) begin
        @(posedge baud_tick_i);
        rx_i = data[i];
      end
    end
  endtask


  always @(posedge clk_i)
	begin
      $display("time=%0t data: %b | shift reg=%b | rx_i=%b bit_cnt_q=%b | data_bit_mx=%b | rst_n_I=%b",$time, data_o,dut.rx_shift_reg_q,rx_i,dut.bit_cnt_q,dut.data_bit_max,rst_n_i);

    /*#100;
    $display("Sending 0x3C serially");
    send_serial(8'h3C); // 00111100
    @(posedge data_valid_o);
    $display("Received parallel data: %h", data_o);

    #100;
    $finish;*/
  end

  initial begin
    $dumpfile("uart_rx_tb.vcd");
    $dumpvars(0, tb_uart_rx);
    #400$finish;
  end

endmodule
