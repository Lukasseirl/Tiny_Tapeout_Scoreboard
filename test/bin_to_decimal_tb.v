`timescale 1ns / 1ns // 'timescale <time_unit> / <time_precision>
`include "../src/bin_to_decimal.v"

module tb_bin_to_decimal;
    reg [6:0] bin_i;
    wire [3:0] tens_o, ones_o;
    
    // Instanziere das Modul
    bin_to_decimal dut (
        .bin_i(bin_i),
        .ones_o(ones_o),
        .tens_o(tens_o)
    );
    
    
    initial begin
        $dumpfile("bin_to_decimal_tb.vcd");
        $dumpvars;
        
        bin_i = 7'd0;
        
        
        // Testfälle
        bin_i = 7'd0;   #1500; // Sollte 0 und 0 ausgeben
        bin_i = 7'd5;   #1500; // Sollte 0 und 5 ausgeben
        bin_i = 7'd15;  #1500; // Sollte 1 und 5 ausgeben
        bin_i = 7'd42;  #1500; // Sollte 4 und 2 ausgeben
        
        // Weitere Tests nach Reset
        bin_i = 7'd73;  #1500; // Sollte 7 und 3 ausgeben
        bin_i = 7'd99;  #1500; // Sollte 9 und 9 ausgeben
        
        #10;
        $finish;
    end
    
endmodule

/* Test for OLD Bin to Dec

`timescale 1ns / 1ns // 'timescale <time_unit> / <time_precision>
`include "../src/bin_to_decimal.v"

module tb_bin_to_decimal;
    reg clk_i;
    reg rst_i = 1'b1;
    reg [6:0] bin_i;
    wire [3:0] tens_o, ones_o;
    
    // Instanziere das Modul
    bin_to_decimal dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .bin_i(bin_i),
        .ones_o(ones_o),
        .tens_o(tens_o)
    );
    
    // Taktgenerierung
    always #5 clk_i = ~clk_i;
    
    initial begin
        $dumpfile("bin_to_decimal_tb.vcd");
        $dumpvars;
        
        // Initialisierung
        clk_i = 0;
        rst_i = 1;
        bin_i = 7'd0;
        
        // Reset Phase
        #20 rst_i = 0;
        
        // Testfälle
        bin_i = 7'd0;   #1500; // Sollte 0 und 0 ausgeben
        bin_i = 7'd5;   #1500; // Sollte 0 und 5 ausgeben
        bin_i = 7'd15;  #1500; // Sollte 1 und 5 ausgeben
        bin_i = 7'd42;  #1500; // Sollte 4 und 2 ausgeben
  
        // Reset testen
        rst_i = 1;
        #1500;
        bin_i = 7'd99;  // Sollte ignoriert werden wegen Reset
        #1500;
        rst_i = 0;
        
        // Weitere Tests nach Reset
        bin_i = 7'd73;  #1500; // Sollte 7 und 3 ausgeben
        bin_i = 7'd99;  #1500; // Sollte 9 und 9 ausgeben
        
        #10;
        $finish;
    end
    
endmodule
*/
