module bin_to_decimal (
    input clk_i,                // Takt
    input rst_i,                // Reset (aktiv high)
    input [7:0] bin_input,      // 8-bit Binäreingang (0-99)
    output reg [3:0] zehner,    // Zehnerstelle (BCD)
    output reg [3:0] einer      // Einerstelle (BCD)
);

always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        // Reset-Zustand
        zehner <= 4'b0;
        einer <= 4'b0;
    end else begin
        // Berechne Zehnerstelle durch Division
        zehner <= bin_input / 10;
        
        // Berechne Einerstelle durch Modulo
        einer <= bin_input % 10;
    end
end

endmodule
