`timescale 1ns / 1ns // 'timescale <time_unit> / <time_precision>
`include "../src/pushbutton_processor.v"

module tb_pushbutton_processor;
    reg clk_1khz;
    reg pushbutton_i;
    wire count_up;
    wire count_down;
    
    // Instantiate unit under test
    pushbutton_processor uut (
        .clk_1khz(clk_1khz),
        .pushbutton_i(pushbutton_i),
        .count_up(count_up),
        .count_down(count_down)
    );
    
    // 1kHz Clock Generator (500,000ns high, 500,000ns low)
    always #500000 clk_1khz = ~clk_1khz;
    
    initial begin
        $dumpfile("pushbutton_processor_tb.vcd");
        $dumpvars;
        
        // Initialize signals
        clk_1khz = 0;
        pushbutton_i = 0;
        
        // Test 1: Short press
        #1000000;  // Wait 1ms
        pushbutton_i = 1;
        #30000000; // Hold for 30ms (longer than debounce time)
        pushbutton_i = 0;
        #50000000; // Wait 50ms
        
        // Test 2: Long press (>2s)
        #1000000;
        pushbutton_i = 1;
        #30000000;  // Wait for debounce
        #2100000000; // Hold for 2.1s (>2s)
        pushbutton_i = 0;
        #50000000;
        
        $display("Simulation finished at %t", $time);
        $finish;
        
    end
    
    // Monitor signals
    initial begin
        $monitor("Time: %t ms, Button: %b, Count_Up: %b, Count_Down: %b", 
                 $time/1000000.0, pushbutton_i, count_up, count_down);
    end
    
    // Pulse monitoring
    time up_pulse_start, down_pulse_start;
    
    always @(posedge count_up) begin
        up_pulse_start = $time;
        $display("Count Up pulse START at %t ms", $time/1000000.0);
    end
    
    always @(negedge count_up) begin
        $display("Count Up pulse END at %t ms, Duration: %t ms", 
                 $time/1000000.0, ($time - up_pulse_start)/1000000.0);
    end
    
    always @(posedge count_down) begin
        down_pulse_start = $time;
        $display("Count Down pulse START at %t ms", $time/1000000.0);
    end
    
    always @(negedge count_down) begin
        $display("Count Down pulse END at %t ms, Duration: %t ms", 
                 $time/1000000.0, ($time - down_pulse_start)/1000000.0);
    end
endmodule
