/*
      Testbench for top_level (scaled timing)
      => Simulates real button timing (short vs long press)
      => Uses 1 MHz simulation clock instead of 1 kHz
      => Logic still detects 1.5 s long press correctly
*/

`timescale 1ns / 1ns
`include "../src/scoreboard_top.v"
`include "../src/pushbutton_processor.v"
`include "../src/counter_v2.v"
`include "../src/bin_to_decimal.v"
`include "../src/dual_7_seg.v"

module top_level_tb;

      // inputs
      reg clk_1mhz_i   = 1'b0;
      reg rst_i        = 1'b1;
      reg pushbutton_i = 1'b0;

      // outputs
      wire [6:0] seg_tens_o;
      wire [6:0] seg_ones_o;

      // DUT
      scoreboard_top top_dut (
            .clk_1khz_i   (clk_1mhz_i),   // simulated 1 MHz clock (scaled)
            .rst_i        (rst_i),
            .pushbutton_i (pushbutton_i),
            .seg_tens_o   (seg_tens_o),
            .seg_ones_o   (seg_ones_o)
      );

      //----------------------------------------------------------------------
      // Clock generation (1 MHz -> 1 µs period)
      //----------------------------------------------------------------------
      /* verilator lint_off STMTDLY */
      always #0.5 clk_1mhz_i = ~clk_1mhz_i; // 1 MHz clock -> 1 µs period
      /* verilator lint_on STMTDLY */

      //----------------------------------------------------------------------
      // Test sequence
      //----------------------------------------------------------------------
      initial begin
            $dumpfile("scoreboard_top_tb.vcd");
            $dumpvars;

            // initial reset
            #2000 rst_i = 1'b0; // 2 µs reset phase

            // Simulate short presses (≈0.1 s real time = 100 ms = 100 ticks at 1 kHz)
            // scaled down to 100 ticks at 1 MHz = 100 µs
            $display(">>> Simulate short presses (count up)");
            repeat (3) begin
                  pushbutton_press_short();
                  #5000; // wait 5 µs between presses
            end

            // Simulate long press (≈1.5 s real time = 1500 ticks at 1 kHz)
            // scaled down to 1500 ticks at 1 MHz = 1.5 ms
            $display(">>> Simulate long press (count down)");
            pushbutton_press_long();
            #10000;

            $display(">>> Test finished");
            #100000 $finish;
      end

      //----------------------------------------------------------------------
      // Helper tasks for button presses
      //----------------------------------------------------------------------
      // short press ~100 cycles (≈0.1s real)
      task pushbutton_press_short;
            begin
                  $display("Short press at time %t", $time);
                  pushbutton_i = 1'b1;
                  #100;        // 100 cycles @1MHz = 100 µs (≈100 ms real)
                  pushbutton_i = 1'b0;
            end
      endtask

      // long press ~1500 cycles (≈1.5s real)
      task pushbutton_press_long;
            begin
                  $display("Long press at time %t", $time);
                  pushbutton_i = 1'b1;
                  #1500;       // 1500 cycles @1MHz = 1.5 ms (≈1.5 s real)
                  pushbutton_i = 1'b0;
            end
      endtask

endmodule // top_level_tb
