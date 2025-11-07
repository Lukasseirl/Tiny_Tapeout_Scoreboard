//------------------------------------------------------------------------------
//  Top-Level Module
//  Funktion:
//  - Verarbeitet Pushbutton-Eingaben für zwei Spieler (kurzer/langer Druck)
//  - Zählt entsprechend hoch oder runter für beide Spieler
//  - Wandelt die Zählerstände in Dezimal (Zehner/Einer) um
//  - Zeigt die Werte abwechselnd auf zwei 7-Segment-Anzeigen an
//------------------------------------------------------------------------------

`default_nettype none
`timescale 1ns/1ps
`ifndef __SCOREBOARD_TOP__
`define __SCOREBOARD_TOP__

module scoreboard_top
(
    // define I/O's of the top module
    input  wire        clk_1khz_i,     // 1 kHz clock
    input  wire        rst_i,          // Reset (active high)
    input  wire        pushbutton_p1_i,// Raw pushbutton signal Spieler 1
    input  wire        pushbutton_p2_i,// Raw pushbutton signal Spieler 2
    output wire [6:0]  seg_tens_o,     // Tens 7-segment output
    output wire [6:0]  seg_ones_o      // Ones 7-segment output
);

    //--------------------------------------------------------------------------
    // Internal signals
    //--------------------------------------------------------------------------

    // Spieler 1
    wire count_up_p1_w;
    wire count_down_p1_w;
    wire [6:0] counter_val_p1_w;
    wire [3:0] tens_p1_w;
    wire [3:0] ones_p1_w;

    // Spieler 2
    wire count_up_p2_w;
    wire count_down_p2_w;
    wire [6:0] counter_val_p2_w;
    wire [3:0] tens_p2_w;
    wire [3:0] ones_p2_w;

    // Display Controller
    wire [3:0] display_tens_w;
    wire [3:0] display_ones_w;

    //--------------------------------------------------------------------------
    // Pushbutton Processor - Spieler 1
    //--------------------------------------------------------------------------
    pushbutton_processor pb_proc_p1_inst (
        .clk_1khz     (clk_1khz_i),
        .rst_i        (rst_i),
        .pushbutton_i (pushbutton_p1_i),
        .count_up     (count_up_p1_w),
        .count_down   (count_down_p1_w)
    );

    //--------------------------------------------------------------------------
    // Pushbutton Processor - Spieler 2
    //--------------------------------------------------------------------------
    pushbutton_processor pb_proc_p2_inst (
        .clk_1khz     (clk_1khz_i),
        .rst_i        (rst_i),
        .pushbutton_i (pushbutton_p2_i),
        .count_up     (count_up_p2_w),
        .count_down   (count_down_p2_w)
    );
    
    //--------------------------------------------------------------------------
    // Counter - Spieler 1
    //--------------------------------------------------------------------------
    counter_v2 #(
        .BW(7)    // 7-bit counter (0–127 for score of 00-99)
    ) counter_p1_inst (
        .clk_up_i     (count_up_p1_w),
        .clk_down_i   (count_down_p1_w),
        .rst_i        (rst_i),
        .clk_i        (clk_1khz_i),
        .counter_val_o(counter_val_p1_w)
    );

    //--------------------------------------------------------------------------
    // Counter - Spieler 2
    //--------------------------------------------------------------------------
    counter_v2 #(
        .BW(7)    // 7-bit counter (0–127 for score of 00-99)
    ) counter_p2_inst (
        .clk_up_i     (count_up_p2_w),
        .clk_down_i   (count_down_p2_w),
        .rst_i        (rst_i),
        .clk_i        (clk_1khz_i),
        .counter_val_o(counter_val_p2_w)
    );
    
    //--------------------------------------------------------------------------
    // Binary to Decimal Converter - Spieler 1
    //--------------------------------------------------------------------------
    bin_to_decimal bin2dec_p1_inst (
        .bin_i  (counter_val_p1_w),
        .tens_o (tens_p1_w),
        .ones_o (ones_p1_w)
    );

    //--------------------------------------------------------------------------
    // Binary to Decimal Converter - Spieler 2
    //--------------------------------------------------------------------------
    bin_to_decimal bin2dec_p2_inst (
        .bin_i  (counter_val_p2_w),
        .tens_o (tens_p2_w),
        .ones_o (ones_p2_w)
    );

    //--------------------------------------------------------------------------
    // Display Controller
    //--------------------------------------------------------------------------
    display_controller display_ctrl_inst (
        .clk_1khz  (clk_1khz_i),
        .rst_i     (rst_i),
        .p1_tens_i (tens_p1_w),
        .p1_ones_i (ones_p1_w),
        .p2_tens_i (tens_p2_w),
        .p2_ones_i (ones_p2_w),
        .tens_o    (display_tens_w),
        .ones_o    (display_ones_w)
    );

    //--------------------------------------------------------------------------
    // Dual 7-Segment Display Driver
    //--------------------------------------------------------------------------
    dual_7_seg display_inst (
        .clk_i       (clk_1khz_i),
        .rst_i       (rst_i),
        .tens_i      (display_tens_w),
        .ones_i      (display_ones_w),
        .seg_tens_o  (seg_tens_o),
        .seg_ones_o  (seg_ones_o)
    );

endmodule // scoreboard_top
`endif
`default_nettype wire
