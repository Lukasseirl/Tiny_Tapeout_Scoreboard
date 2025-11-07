/*
      Testbench for top_level (without scaled timing)
      => Simulates real button timing (short vs long press)
      => Uses 1 kHz
*/

`timescale 1ms / 1us
`include "../src/scoreboard_top.v"
`include "../src/pushbutton_processor.v"
`include "../src/counter_v2.v"
`include "../src/bin_to_decimal.v"
`include "../src/dual_7_seg.v"
`include "../src/display_controller.v"

module top_level_tb;

      // inputs
      reg clk_1khz_i   = 1'b0;
      reg rst_i        = 1'b1;
      reg pushbutton_p1_i = 1'b0;
      reg pushbutton_p2_i = 1'b0;

      // outputs
      wire [6:0] seg_tens_o;
      wire [6:0] seg_ones_o;

      // DUT
      scoreboard_top top_dut (
            .clk_1khz_i   (clk_1khz_i),   // simulated 1 MHz clock (scaled)
            .rst_i        (rst_i),
            .pushbutton_p1_i (pushbutton_p1_i),
            .pushbutton_p2_i (pushbutton_p2_i),
            .seg_tens_o   (seg_tens_o),
            .seg_ones_o   (seg_ones_o)
      );

      //----------------------------------------------------------------------
      // Clock generation (1 MHz -> 1 ms period)
      //----------------------------------------------------------------------
      /* verilator lint_off STMTDLY */
      always #0.5 clk_1khz_i = ~clk_1khz_i; // 1 kHz clock -> 1 ms period
      /* verilator lint_on STMTDLY */

      //----------------------------------------------------------------------
      // Test sequence
      //----------------------------------------------------------------------
      initial begin
            $dumpfile("scoreboard_top_2_tb.vcd");
            $dumpvars;

            // initial reset
            #2 rst_i = 1'b0; // 2 ms reset phase

            // Simulate long press (≈1.6 s real time )
            pushbutton_press_long();
            #500
            
            // Simulate short presses 
            repeat (10) begin
                  pushbutton_press_short();
                  #500; // wait .5 s between presses
            end

        // Simulate long press (≈1.6 s real time )
            pushbutton_press_long();
            #150 $finish;
      end

      //----------------------------------------------------------------------
      // Helper tasks for button presses
      //----------------------------------------------------------------------
      // short press with bouncing
      task pushbutton_press_short;
            begin
                  pushbutton_p1_i = 1'b1;
                  #1 pushbutton_p1_i = 1'b0;  //on bouncing 
                  #2 pushbutton_p1_i = 1'b1;
                  #1 pushbutton_p1_i = 1'b0;
                  #1 pushbutton_p1_i = 1'b1;  
                  #25 pushbutton_p1_i = 1'b0;
                  #2 pushbutton_p1_i = 1'b1;  // off bouncing
                  #1 pushbutton_p1_i = 1'b0;
                  #1 pushbutton_p1_i = 1'b1;
                  #1 pushbutton_p1_i = 1'b0;
            end
      endtask

      // long press
      task pushbutton_press_long;
            begin
                  $display("Long press at time %t", $time);
                  pushbutton_p1_i = 1'b1;
                  #1600;       //
                  pushbutton_p1_i = 1'b0;
            end
      endtask

endmodule // top_level_tb
