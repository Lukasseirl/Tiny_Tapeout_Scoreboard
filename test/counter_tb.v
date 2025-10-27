/*
      Simple text bench for counter.
      => tests counting up and counting down
      => tests the limits [0-99]
*/

`timescale 1ns / 1ns // 'timescale <time_unit> / <time_precision>
`include "../src/counter.v"

module counter_tb;
      // inputs
      reg rst_i = 1'b1;
      reg clk_up_i = 1'b0;
      reg clk_down_i = 1'b0;
      wire [6:0] = cnt_val;
      
  
