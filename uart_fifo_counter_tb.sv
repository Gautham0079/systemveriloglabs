`timescale 1ns/1ps

module tb_uart_tx_rx_fifo;

    parameter int DATA_WIDTH = 16;
    parameter int DEPTH = 2;

    logic clk_i;
    logic rst_n_i;

    logic tx_wr_en_i;
    logic tx_rd_en_i;
    logic [DATA_WIDTH-1:0] tx_wr_data_i;
    logic [DATA_WIDTH-1:0] tx_rd_data_o;
    logic tx_full_o;
    logic tx_empty_o;

    logic rx_wr_en_i;
    logic rx_rd_en_i;
    logic [DATA_WIDTH-1:0] rx_wr_data_i;
    logic [DATA_WIDTH-1:0] rx_rd_data_o;
    logic rx_full_o;
    logic rx_empty_o;

    uart_tx_rx_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (.*);

    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    task automatic reset();
        rst_n_i = 0;
        tx_wr_en_i = 0;
        tx_rd_en_i = 0;
        tx_wr_data_i = '0;
        rx_wr_en_i = 0;
        rx_rd_en_i = 0;
        rx_wr_data_i = '0;
        repeat(5) @(posedge clk_i);
        rst_n_i = 1;
        repeat(2) @(posedge clk_i);
        $display("[%0t] Reset done", $time);
    endtask

    task automatic tx_write(input [DATA_WIDTH-1:0] data);
        @(negedge clk_i);
        tx_wr_en_i = 1;
        tx_wr_data_i = data;
        @(posedge clk_i);
        @(negedge clk_i);
        tx_wr_en_i = 0;
        $display("[%0t] TX Write: 0x%0h | Full=%b Empty=%b Count=%0d",
                 $time, data, tx_full_o, tx_empty_o, dut.tx_count_q);
    endtask

    task automatic tx_read(output [DATA_WIDTH-1:0] rdata);
        @(negedge clk_i);
        tx_rd_en_i = 1;
        @(posedge clk_i);
        @(negedge clk_i);
        tx_rd_en_i = 0;
        rdata = tx_rd_data_o;
        $display("[%0t] TX Read : 0x%0h | Full=%b Empty=%b",
                 $time, tx_rd_data_o, tx_full_o, tx_empty_o);
    endtask

    task automatic rx_write(input [DATA_WIDTH-1:0] data);
        @(negedge clk_i);
        rx_wr_en_i = 1;
        rx_wr_data_i = data;
        @(posedge clk_i);
        @(negedge clk_i);
        rx_wr_en_i = 0;
        $display("[%0t] RX Write: 0x%0h | Full=%b Empty=%b Count=%0d",
                 $time, data, rx_full_o, rx_empty_o, dut.rx_count_q);
    endtask

    task automatic rx_read(output [DATA_WIDTH-1:0] rdata);
        @(negedge clk_i);
        rx_rd_en_i = 1;
        @(posedge clk_i);
        @(negedge clk_i);
        rx_rd_en_i = 0;
        rdata = rx_rd_data_o;
        $display("[%0t] RX Read : 0x%0h | Full=%b Empty=%b",
                 $time, rx_rd_data_o, rx_full_o, rx_empty_o);
    endtask

    initial begin
        logic [DATA_WIDTH-1:0] rdata;

        $display("=== UART TX/RX FIFO Testbench Started ===");
        reset();

        $display("\n--- TX FIFO Tests ---");
        tx_write(16'hAAAA);
        tx_write(16'h5555);
        @(posedge clk_i); #1;
        assert(tx_full_o) else $error("TX Full flag not asserted after filling FIFO");

        tx_write(16'hDEAD);

        tx_read(rdata);
        assert(rdata === 16'hAAAA) else $error("TX rd[0] expected 0xAAAA got 0x%0h", rdata);
        tx_read(rdata);
        assert(rdata === 16'h5555) else $error("TX rd[1] expected 0x5555 got 0x%0h", rdata);

        @(posedge clk_i); #1;
        assert(tx_empty_o) else $error("TX Empty flag not asserted");

        tx_read(rdata);

        $display("\n--- RX FIFO Tests ---");
        rx_write(16'h1234);
        rx_write(16'hABCD);
        @(posedge clk_i); #1;
        assert(rx_full_o) else $error("RX Full flag not asserted");

        rx_write(16'hBEEF);

        rx_read(rdata);
        assert(rdata === 16'h1234) else $error("RX rd[0] expected 0x1234 got 0x%0h", rdata);
        rx_read(rdata);
        assert(rdata === 16'hABCD) else $error("RX rd[1] expected 0xABCD got 0x%0h", rdata);

        @(posedge clk_i); #1;
        assert(rx_empty_o) else $error("RX Empty flag not asserted");

        $display("\n--- Simultaneous Read/Write Test (TX) ---");
        tx_write(16'h1111);
        tx_write(16'h2222);

        @(negedge clk_i);
        tx_rd_en_i = 1;
        tx_wr_en_i = 1;
        tx_wr_data_i = 16'h3333;
        @(posedge clk_i);
        @(negedge clk_i);
        tx_rd_en_i = 0;
        tx_wr_en_i = 0;
        $display("[%0t] TX Sim r+w: rd_data=0x%0h Full=%b Empty=%b",
                 $time, tx_rd_data_o, tx_full_o, tx_empty_o);

        tx_read(rdata);
        tx_read(rdata);

        $display("\n--- Simultaneous Read/Write Test (RX) ---");
        rx_write(16'h4444);
        rx_write(16'h5555);

        @(negedge clk_i);
        rx_rd_en_i = 1;
        rx_wr_en_i = 1;
        rx_wr_data_i = 16'h6666;
        @(posedge clk_i);
        @(negedge clk_i);
        rx_rd_en_i = 0;
        rx_wr_en_i = 0;
        $display("[%0t] RX Sim r+w: rd_data=0x%0h Full=%b Empty=%b",
                 $time, rx_rd_data_o, rx_full_o, rx_empty_o);

        rx_read(rdata);
        rx_read(rdata);

        $display("\n=== All tests completed successfully! ===");
        #50;
        $finish;
    end

    initial begin
        $dumpfile("uart_tx_rx_fifo_tb.vcd");
        $dumpvars(0, tb_uart_tx_rx_fifo);
    end

endmodule
