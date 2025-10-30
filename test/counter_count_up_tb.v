/*
      Simple text bench for counter.
      => tests counting up and counting down
      => tests the limits [0-99]
*/

`timescale 1ns / 1ns // 'timescale <time_unit> / <time_precision>
`include "../src/counter_v2.v"

module counter_tb;

      parameter BW = 7;
      
      // inputs
      reg rst_i = 1'b1;
      reg clk_up_i = 1'b0;
      reg clk_down_i = 1'b0;
      wire [BW-1:0] cnt_val;

      // DUT
      counter 
            #(BW)
      counter_dut (
            .clk_up_i(clk_up_i),          // counting up
            .clk_down_i(clk_down_i),      // counting down
            .rst_i(~rst_i),
            .counter_val_o(cnt_val)
      );

      // generate clock
      /* verilator lint_off STMTDLY */
      always #1 clk_up_i = ~clk_up_i;   // 5ns for up counter
      /* verilator lint_on STMTDLY */

      initial begin
            $dumpfile("counter_tb.vcd");
            $dumpvars;

            /* verilator lint_off STMTDLY */
            #20 rst_i = 1'b1;
            #20 rst_i = 1'b0;
            #20 rst_i = 1'b1;
            #300 $finish;
            /* verilator lint_on STMTDLY */
      end
endmodule // counter_tb
            
      
      
