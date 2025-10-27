/*  
    Testbench for the simple scoreboard
*/  

`timescale 1ns / 1ns
`include "../test/tt_um_scoreboard_simple_top.v"
`include "../test/scoreboard_simple_controller.v"
`include "../test/display_simple_controller.v"
`include "../test/button_debouncer.v"
`include "../test/long_press_detector.v"
`include "../test/seven_segment_decoder.v"

module scoreboard_tb;

// Test parameters
parameter CLK_PERIOD = 10; // 10ns = 100MHz clock

// Inputs to DUT
reg clk = 1'b0;
reg rst_n = 1'b0;
reg [7:0] ui_in = 8'b0;
reg [7:0] uio_in = 8'b0;
reg ena = 1'b1;

// Outputs from DUT
wire [7:0] uo_out;
wire [7:0] uio_out;
wire [7:0] uio_oe;

// Instantiate Device Under Test (DUT)
tt_um_scoreboard_simple_top dut (
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
);

// Generate clock
always #(CLK_PERIOD/2) clk = ~clk;

// Test sequences
initial begin
    // Initialize VCD dump
    $dumpfile("scoreboard_tb.vcd");
    $dumpvars(0, scoreboard_tb);
    
    // Initialize inputs
    ui_in = 8'b00000000; // All buttons released
    rst_n = 1'b0;        // Assert reset
    
    // Release reset after some time
    #100;
    rst_n = 1'b1;
    
    $display("=== Starting Scoreboard Test ===");
    
    // Test 1: Short press Player 1 button
    $display("Test 1: Short press P1 button");
    #100;
    ui_in[0] = 1'b1;  // Press P1 button
    #1000000;         // Hold for debounce + short press
    ui_in[0] = 1'b0;  // Release
    
    #10000000;        // Wait for display cycle
    
    // Test 2: Short press Player 2 button
    $display("Test 2: Short press P2 button");
    ui_in[1] = 1'b1;  // Press P2 button
    #1000000;         // Hold for debounce + short press
    ui_in[1] = 1'b0;  // Release
    
    #10000000;        // Wait for display cycle
    
    // Test 3: Long press Player 1 button (decrement)
    $display("Test 3: Long press P1 button (decrement)");
    ui_in[0] = 1'b1;  // Press P1 button
    #250000000;       // Hold for >2 seconds (long press)
    ui_in[0] = 1'b0;  // Release
    
    #10000000;        // Wait for display cycle
    
    // Test 4: Multiple short presses
    $display("Test 4: Multiple short presses");
    repeat (5) begin
        ui_in[0] = 1'b1;  // Press P1 button
        #1000000;         // Short press
        ui_in[0] = 1'b0;  // Release
        #5000000;         // Wait between presses
    end
    
    #10000000;
    
    // Test 5: Reset test
    $display("Test 5: Reset");
    rst_n = 1'b0;     // Assert reset
    #100;
    rst_n = 1'b1;     // Release reset
    
    #50000000;
    
    $display("=== Test Complete ===");
    $finish;
end

// Monitor to display important signals
always @(posedge clk) begin
    if ($time > 100) begin // Skip initial reset period
        // Display scores periodically
        if ($time % 10000000 == 0) begin
            $display("Time: %0t ns | P1 Score: %d | P2 Score: %d | Display State: %d", 
                     $time, dut.scoreboard.p1_score_reg, dut.scoreboard.p2_score_reg, dut.display.current_state);
        end
        
        // Display button press events
        if (ui_in[0] && !$past(ui_in[0])) begin
            $display("Time: %0t ns | P1 button pressed", $time);
        end
        if (ui_in[1] && !$past(ui_in[1])) begin
            $display("Time: %0t ns | P2 button pressed", $time);
        end
    end
end

// Helper function to get past value (for edge detection)
reg [7:0] past_ui_in;
always @(posedge clk) begin
    past_ui_in <= ui_in;
end

endmodule
