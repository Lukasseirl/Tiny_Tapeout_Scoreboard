module tb_bin_to_decimal;
    reg clk_i;
    reg rst_i = 1'b1;
    reg [7:0] bin_input;
    wire [3:0] zehner, einer;
    
    // Instanziere das Modul
    bin_to_decimal uut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .bin_input(bin_input),
        .zehner(zehner),
        .einer(einer)
    );
    
    // Taktgenerierung
    always #5 clk_i = ~clk_i;
    
    initial begin
        // Initialisierung
        clk_i = 0;
        rst_i = 1;
        bin_input = 8'd0;
        
        // Reset Phase
        #20 rst_i = 0;
        
        // Testfälle
        bin_input = 8'd0;   #10; // Sollte 0 und 0 ausgeben
        bin_input = 8'd5;   #10; // Sollte 0 und 5 ausgeben
        bin_input = 8'd15;  #10; // Sollte 1 und 5 ausgeben
        bin_input = 8'd42;  #10; // Sollte 4 und 2 ausgeben
  
        // Reset testen
        rst_i = 1;
        #10;
        bin_input = 8'd99;  // Sollte ignoriert werden wegen Reset
        #10;
        rst_i = 0;
        
        // Weitere Tests nach Reset
        bin_input = 8'd73;  #10; // Sollte 7 und 3 ausgeben
        bin_input = 8'd99;  #10; // Sollte 9 und 9 ausgeben
        
        #10;
        $finish;
    end
    
endmodule
