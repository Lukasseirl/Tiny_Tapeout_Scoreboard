

module pushbutton_processor (
    input wire clk_1mhz,      // 1 MHz Clock
    input wire pushbutton_i,  // Roh-Pushbutton Signal
    output reg count_up,      // Kurzer Druck -> High
    output reg count_down     // Langer Druck (>2s) -> High
);

// Parameter für Zeitberechnung
parameter DEBOUNCE_TIME = 20000;    // 20ms Entprellzeit (20.000 Ticks bei 1MHz)
parameter LONG_PRESS_TIME = 2000000; // 2s Langer Druck (2.000.000 Ticks bei 1MHz)

// Zustandsautomat
reg [1:0] state;
localparam IDLE      = 2'b00;
localparam DEBOUNCING = 2'b01;
localparam PRESSED    = 2'b10;
localparam LONG_PRESS = 2'b11;

// Zähler für Entprellung und langen Druck
reg [20:0] counter;
reg button_sync;

// Taster-Synchronisation (Metastabilität)
always @(posedge clk_1mhz) begin
    button_sync <= pushbutton_i;
end

// Haupt-Zustandsautomat
always @(posedge clk_1mhz) begin
    // Default Werte
    count_up <= 1'b0;
    count_down <= 1'b0;
    
    case (state)
        IDLE: begin
            counter <= 0;
            if (button_sync) begin
                state <= DEBOUNCING;
                counter <= 0;
            end
        end
        
        DEBOUNCING: begin
            if (button_sync) begin
                if (counter >= DEBOUNCE_TIME) begin
                    state <= PRESSED;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end else begin
                state <= IDLE;
            end
        end
        
        PRESSED: begin
            if (button_sync) begin
                if (counter >= LONG_PRESS_TIME) begin
                    state <= LONG_PRESS;
                    count_down <= 1'b1;  // Count Down Signal
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end else begin
                // Kurzer Druck erkannt
                state <= IDLE;
                count_up <= 1'b1;  // Count Up Signal
                counter <= 0;
            end
        end
        
        LONG_PRESS: begin
            count_down <= 1'b0;  // Nur ein Puls
            if (!button_sync) begin
                state <= IDLE;
                counter <= 0;
            end
        end
        
        default: state <= IDLE;
    endcase
end

endmodule
