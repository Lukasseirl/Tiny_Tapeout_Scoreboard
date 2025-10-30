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

      // switch for turning on/off clock signals
      reg swi_up = 1'b1;     
      reg swi_down = 1'b0;
      
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
      always #1 begin
        if (swi_up) begin
          clk_up_i = ~clk_up_i;
        end
      end

      always #1 begin
        if (swi_down) begin
          clk_down_i = ~clk_down_i;
        end
      end
      /* verilator lint_on STMTDLY */

      initial begin
            $dumpfile("counter_count_up_tb.vcd");
            $dumpvars;

            /* verilator lint_off STMTDLY */
            #20 rst_i = 1'b1;
            #20 rst_i = 1'b0;
            #20 rst_i = 1'b1;

            #300 swi_down = 1'b1;
            #20 swi_up = 1'b0;
            #300 $finish;
            /* verilator lint_on STMTDLY */
      end
endmodule // counter_tb
            
      
      
