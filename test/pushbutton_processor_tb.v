`timescale 1ns / 1ns // 'timescale <time_unit> / <time_precision>
`include "../src/pushbutton_processor.v"

module tb_pushbutton_processor;
    reg clk_1khz;
    reg rst_i = 1'b1;
    reg pushbutton_i;
    wire count_up = 1'b0;
    wire count_down = 1'b0;;
    
    // Instantiate unit under test
    pushbutton_processor uut (
        .clk_1khz(clk_1khz),
        .rst_i(rst_i),
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

        // initial reset
        #50 rst_i = 1'b0;
        #50 rst_i = 1'b1;
        #50 rst_i = 1'b0;

        /* verilator lint_off STMTDLY */
        // Test 1: Short press
        #10000000;  // Wait 1ms
        pushbutton_i = 1;
        #1000000 pushbutton_i = 0;  // bouncing
        #2000000 pushbutton_i = 1;
        #2000000 pushbutton_i = 0;
        #1000000 pushbutton_i = 1;
        #2000000 pushbutton_i = 0;
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
        #2000000 pushbutton_i = 1;  // bouncing
        #2000000 pushbutton_i = 0;
        #1000000 pushbutton_i = 1;
        #2000000 pushbutton_i = 0;
        #50000000;
        /* verilator lint_on STMTDLY */
        $display("Simulation finished at %t", $time);
        $finish;
        
    end
endmodule
