`timescale 1ns/1ps

module tb_decade_counter;

    // Signals
    logic clk;
    logic rst;
    logic [3:0] count;

    // DUT instantiation
    decade_counter dut (
        .clk   (clk),
        .rst   (rst),
        .count (count)
    );

    // Clock generation (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Dump waveform
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_decade_counter);

        // Apply reset
        rst = 1;
        #12;
        rst = 0;

        // Run for multiple cycles
        repeat (25) @(posedge clk);

        // Apply reset again
        rst = 1;
        #10;
        rst = 0;

        repeat (15) @(posedge clk);

        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | rst=%b | count=%0d", $time, rst, count);
    end

    // Optional: Assertion to check MOD-10 behavior
    always @(posedge clk) begin
        if (!rst) begin
            assert (count <= 4'd9)
                else $error("Count exceeded 9 at time %0t", $time);
        end
    end

endmodule
