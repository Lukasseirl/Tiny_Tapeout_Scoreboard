`timescale 1ns / 1ns
`include "../src/display_controller.v"

module tb_display_controller;
    // Clock and Reset
    reg clk_1khz;
    reg rst_i;
    
    // Player inputs
    reg [3:0] p1_tens_i;
    reg [3:0] p1_ones_i;
    reg [3:0] p2_tens_i;
    reg [3:0] p2_ones_i;
    
    // Outputs
    wire [3:0] tens_o;
    wire [3:0] ones_o;
    
    // Instantiate DUT
    display_controller dut (
        .clk_1khz(clk_1khz),
        .rst_i(rst_i),
        .p1_tens_i(p1_tens_i),
        .p1_ones_i(p1_ones_i),
        .p2_tens_i(p2_tens_i),
        .p2_ones_i(p2_ones_i),
        .tens_o(tens_o),
        .ones_o(ones_o)
    );
    
    // Clock generation (1kHz = 1ms period)
    always #500000 clk_1khz = ~clk_1khz; // 500us half-period
    
    // Test sequence
    initial begin
        // Initialize signals
        clk_1khz = 0;
        rst_i = 1;
        
        // Set static player scores
        p1_tens_i = 4'd1;  // Player 1: 12
        p1_ones_i = 4'd2;
        p2_tens_i = 4'd0;  // Player 2: 7
        p2_ones_i = 4'd7;
        
        // Reset sequence
        #1000000; // 1ms wait
        rst_i = 0;
        
        // Run simulation for ~20 seconds real time
        #20000000000; // 20 seconds simulation time
        
        $display("Simulation finished");
        $finish;
    end

endmodule
