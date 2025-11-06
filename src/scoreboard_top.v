//------------------------------------------------------------------------------
//  Top-Level Module
//  Funktion:
//  - Verarbeitet Pushbutton-Eingaben (kurzer/lang langer Druck)
//  - Zählt entsprechend hoch oder runter
//  - Wandelt den Zählerstand in Dezimal (Zehner/Einer) um
//  - Zeigt die Werte auf zwei 7-Segment-Anzeigen an
//------------------------------------------------------------------------------

`default_nettype none
`ifndef __SCOREBOARD_TOP__
`define __SCOREBOARD_TOP__

module scoreboard_top
(
    // define I/O's of the top module
    input  wire        clk_1khz_i,     // 1 kHz clock
    input  wire        rst_i,          // Reset (active high)
    input  wire        pushbutton_i,   // Raw pushbutton signal
    output wire [6:0]  seg_tens_o,     // Tens 7-segment output
    output wire [6:0]  seg_ones_o      // Ones 7-segment output
);

    //--------------------------------------------------------------------------
    // Internal signals
    //--------------------------------------------------------------------------

    wire count_up_w;          // short press pulse
    wire count_down_w;        // long press pulse
    wire [6:0] counter_val_w; // 7-bit counter value
    wire [3:0] tens_w;        // tens digit
    wire [3:0] ones_w;        // ones digit

    //--------------------------------------------------------------------------
    // Pushbutton Processor
    //--------------------------------------------------------------------------
    pushbutton_processor pb_proc_inst (
        .clk_1khz     (clk_1khz_i),
        .rst_i        (rst_i),
        .pushbutton_i (pushbutton_i),
        .count_up     (count_up_w),
        .count_down   (count_down_w)
    );

    //--------------------------------------------------------------------------
    // Counter
    //--------------------------------------------------------------------------
    counter_v2 #(
        .BW(7)    // 7-bit counter (0–127 for score of 00-99)
    ) counter_inst (
        .clk_up_i     (count_up_w),
        .clk_down_i   (count_down_w),
        .rst_i        (rst_i),
        .clk_i        (clk_1khz_i),
        .counter_val_o(counter_val_w)
    );

    //--------------------------------------------------------------------------
    // Binary to Decimal Converter
    //--------------------------------------------------------------------------
    bin_to_decimal bin2dec_inst (
        .bin_i  (counter_val_w),
        .tens_o (tens_w),
        .ones_o (ones_w)
    );

    //--------------------------------------------------------------------------
    // Dual 7-Segment Display Driver
    //--------------------------------------------------------------------------
    dual_7_seg display_inst (
        .clk_i       (clk_1khz_i),
        .rst_i       (rst_i),
        .tens_i      (tens_w),
        .ones_i      (ones_w),
        .seg_tens_o  (seg_tens_o),
        .seg_ones_o  (seg_ones_o)
    );

endmodule // top_level
`endif
`default_nettype wire

