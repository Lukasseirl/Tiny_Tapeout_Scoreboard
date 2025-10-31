`timescale 1ns / 1ns
`include "dual_7_seg.v"

module dual_7_seg_tb;

    // Inputs
    reg clk_i = 1'b0;
    reg rst_i = 1'b1;
    reg [3:0] tens_i = 4'd0;
    reg [3:0] ones_i = 4'd0;
    
    // Outputs
    wire [6:0] seg_tens_o;
    wire [6:0] seg_ones_o;
    
    // DUT
    dual_7_seg dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .tens_i(tens_i),
        .ones_i(ones_i),
        .seg_tens_o(seg_tens_o),
        .seg_ones_o(seg_ones_o)
    );

    // Generate main clock (100MHz)
    always #5 clk_i = ~clk_i;

    // Main test sequence
    initial begin
        $dumpfile("dual_7_seg_tb.vcd");
        $dumpvars(0, dual_7_seg_tb);
        
        // Release reset
        #20 rst_i = 1'b0;
        
        // Test various digit combinations
        // Test 00-09
        tens_i = 4'd0;
        ones_i = 4'd0; #20;
        ones_i = 4'd1; #20;
        ones_i = 4'd2; #20;
        ones_i = 4'd3; #20;
        ones_i = 4'd4; #20;
        ones_i = 4'd5; #20;
        ones_i = 4'd6; #20;
        ones_i = 4'd7; #20;
        ones_i = 4'd8; #20;
        ones_i = 4'd9; #20;
        
        // Test 10-19
        tens_i = 4'd1;
        ones_i = 4'd0; #20;
        ones_i = 4'd1; #20;
        ones_i = 4'd2; #20;
        ones_i = 4'd3; #20;
        ones_i = 4'd4; #20;
        ones_i = 4'd5; #20;
        ones_i = 4'd6; #20;
        ones_i = 4'd7; #20;
        ones_i = 4'd8; #20;
        ones_i = 4'd9; #20;
        
        // Test some specific numbers
        tens_i = 4'd4; ones_i = 4'd2; #20; // 42
        tens_i = 4'd7; ones_i = 4'd7; #20; // 77
        tens_i = 4'd9; ones_i = 4'd9; #20; // 99
        
        // Test invalid BCD values
        tens_i = 4'd10; ones_i = 4'd11; #20;
        tens_i = 4'd15; ones_i = 4'd12; #20;
        
        // Test reset
        rst_i = 1'b1; #20;
        rst_i = 1'b0; #20;
        
        // Final test
        tens_i = 4'd8; ones_i = 4'd1; #20; // 81
        
        #100 $finish;
    end

endmodule // dual_7_seg_tb
