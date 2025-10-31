module bin_to_decimal (
    input  [7:0] bin,        // Eingabe: Binärwert (0–99)
    output reg [3:0] tens,   // Zehnerstelle (0–9)
    output reg [3:0] ones    // Einerstelle (0–9)
);

    integer i;
    reg [19:0] shift; // genug Bits für 8-Bit binär + 2x4-Bit BCD = 16 Bit + Reserve

    always @(*) begin
        // Initialisierung
        shift = 0;
        shift[7:0] = bin;

        // Double Dabble (Shift-Add-3-Algorithmus)
        for (i = 0; i < 8; i = i + 1) begin
            // Wenn BCD-Nibble >= 5, +3 addieren
            if (shift[11:8] >= 5)
                shift[11:8] = shift[11:8] + 3;
            if (shift[15:12] >= 5)
                shift[15:12] = shift[15:12] + 3;
            // Alles um 1 nach links schieben
            shift = shift << 1;
        end

        // Ergebnis extrahieren
        tens = shift[15:12];
        ones = shift[11:8];
    end

endmodule

