`timescale 1ns/1ps

module tb_decade_counter;
    logic clk;
    logic rst;
    logic [3:0] count;
    decade_counter dut (
        .clk   (clk),
        .rst   (rst),
        .count (count)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_decade_counter);
        rst = 1;
        #12;
        rst = 0;
        repeat (25) @(posedge clk);
        rst = 1;
        #10;
        rst = 0;

        repeat (15) @(posedge clk);

        $finish;
    end
    initial begin
        $monitor("Time=%0t | rst=%b | count=%0d", $time, rst, count);
    end
    always @(posedge clk) begin
        if (!rst) begin
            assert (count <= 4'd9)
                else $error("Count exceeded 9 at time %0t", $time);
        end
    end

endmodule
