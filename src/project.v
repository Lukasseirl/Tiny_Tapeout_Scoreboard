/**
 * Copyright (c) 2025 Lukas Seirlehner
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_Lukasseirl (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Wire definitions
  wire [6:0] seg_tens;
  wire [6:0] seg_ones;
  
  // Instantiate the scoreboard module
  scoreboard_top scoreboard_inst (
    .clk_1khz_i     (clk),           // Using main clock as 1kHz clock
    .rst_i          (~rst_n),        // Convert active-low reset to active-high
    .pushbutton_p1_i(ui_in[0]),      // Spieler 1 Pushbutton
    .pushbutton_p2_i(ui_in[1]),      // Spieler 2 Pushbutton (neuer Input)
    .seg_tens_o     (seg_tens),      // Tens digit
    .seg_ones_o     (seg_ones)       // Ones digit
  );

  // Assign outputs - tens digit to uo_out, ones digit to uio_out
  assign uo_out = {1'b0, seg_tens};  // Pad with 0 to make 8 bits
  assign uio_out = {1'b0, seg_ones}; // Pad with 0 to make 8 bits
  
  // Set I/O enable: all uio pins as outputs
  assign uio_oe = 8'b11111111;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:2], uio_in, 1'b0};

endmodule
