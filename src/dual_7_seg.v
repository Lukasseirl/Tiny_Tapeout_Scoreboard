//------------------------------------------------------------------------------
//  7-Segment Display Driver for Two Digits
//  Converts two 4-bit BCD digits (tens and ones) into 7-segment outputs.
//  Each output is a 7-bit vector (segments a–g).
//------------------------------------------------------------------------------
//  Segment bit mapping (common cathode example):
//      seg[6:0] = {a, b, c, d, e, f, g}
//------------------------------------------------------------------------------

`default_nettype none
`ifndef __DUAL_7_SEG__
`define __DUAL_7_SEG__

module dual_7_seg
(
    // define I/O's of the module
    input  wire        clk_i,       // clock
    input  wire        rst_i,       // reset (active high)
    input  wire [3:0]  tens_i,      // BCD tens digit
    input  wire [3:0]  ones_i,      // BCD ones digit
    output reg  [6:0]  seg_tens_o,  // 7-segment output for tens
    output reg  [6:0]  seg_ones_o   // 7-segment output for ones
);

    // combinational logic for 7-segment encoding
    function [6:0] bcd_to_7seg;
        input [3:0] bcd;
        begin
            case (bcd)
                4'd0: bcd_to_7seg = 7'b1111110; // 0
                4'd1: bcd_to_7seg = 7'b0110000; // 1
                4'd2: bcd_to_7seg = 7'b1101101; // 2
                4'd3: bcd_to_7seg = 7'b1111001; // 3
                4'd4: bcd_to_7seg = 7'b0110011; // 4
                4'd5: bcd_to_7seg = 7'b1011011; // 5
                4'd6: bcd_to_7seg = 7'b1011111; // 6
                4'd7: bcd_to_7seg = 7'b1110000; // 7
                4'd8: bcd_to_7seg = 7'b1111111; // 8
                4'd9: bcd_to_7seg = 7'b1111011; // 9
                default: bcd_to_7seg = 7'b0000001; // "-" (Error)
            endcase
        end
    endfunction

    // synchronous process for stable outputs
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            seg_tens_o <= 7'b0000000;
            seg_ones_o <= 7'b0000000;
        end else begin
            seg_tens_o <= bcd_to_7seg(tens_i);
            seg_ones_o <= bcd_to_7seg(ones_i);
        end
    end

endmodule // dual7seg
`endif
`default_nettype wire
