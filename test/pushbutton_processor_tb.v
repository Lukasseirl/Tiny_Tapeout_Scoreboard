`timescale 1ns / 1ns // 'timescale <time_unit> / <time_precision>
`include "../src/pushbutton_processor.v"

module tb_pulse_check;
    reg clk_1mhz;
    reg pushbutton_i;
    wire count_up;
    wire count_down;
    
    pushbutton_processor uut (
        .clk_1mhz(clk_1mhz),
        .pushbutton_i(pushbutton_i),
        .count_up(count_up),
        .count_down(count_down)
    );
    
    // 1MHz Clock
    always #500 clk_1mhz = ~clk_1mhz;
    
    initial begin
        clk_1mhz = 0;
        pushbutton_i = 0;
        
        // Kurzer Druck testen
        #1000000;
        pushbutton_i = 1;
        #50000;  // 50ms gedrückt halten
        pushbutton_i = 0;
        
        // Warten und langen Druck testen
        #1000000;
        pushbutton_i = 1;
        #2100000; // 2.1s gedrückt halten (>2s)
        pushbutton_i = 0;
        
        #1000000;
        $finish;
    end
    
    // Puls-Länge überwachen
    integer up_pulse_start, down_pulse_start;
    
    always @(posedge count_up) begin
        up_pulse_start = $time;
        $display("Count Up Puls START bei %t", $time);
    end
    
    always @(negedge count_up) begin
        $display("Count Up Puls ENDE bei %t, Dauer: %t", $time, $time - up_pulse_start);
    end
    
    always @(posedge count_down) begin
        down_pulse_start = $time;
        $display("Count Down Puls START bei %t", $time);
    end
    
    always @(negedge count_down) begin
        $display("Count Down Puls ENDE bei %t, Dauer: %t", $time, $time - down_pulse_start);
    end
endmodule
