/*
 * Simple Scoreboard for two players with 7-segment display
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_scoreboard_simple_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Signal definitions
    wire clk_i;
    wire rst_i;
    wire p1_button;
    wire p2_button;
    
    wire [7:0] p1_score;
    wire [7:0] p2_score;
    wire [3:0] display_digit;
    wire [2:0] display_state;
    
    // Input assignments
    assign clk_i = clk;
    assign rst_i = ~rst_n;
    assign p1_button = ui_in[0];  // Player 1 button
    assign p2_button = ui_in[1];  // Player 2 button
    
    // Instantiate scoreboard controller
    scoreboard_simple_controller scoreboard (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .p1_button_i(p1_button),
        .p2_button_i(p2_button),
        .p1_score_o(p1_score),
        .p2_score_o(p2_score)
    );
    
    // Instantiate display controller
    display_simple_controller display (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .p1_score_i(p1_score),
        .p2_score_i(p2_score),
        .digit_o(display_digit),
        .segment_select_o(uo_out[3:0]),
        .state_o(display_state)
    );
    
    // 7-segment decoder
    wire [6:0] segments;
    seven_segment_decoder seg_dec (
        .digit_i(display_digit),
        .segments_o(segments)
    );
    
    // Output assignments
    assign uo_out[7:4] = 4'b0000;
    assign uo_out[2:0] = segments[6:4];
    assign uio_out[7:0] = {1'b0, segments[3:0], display_state};
    assign uio_oe = 8'b11111111;
    
    // Unused inputs
    wire _unused = &{ui_in[7:2], uio_in, ena, 1'b0};

endmodule
