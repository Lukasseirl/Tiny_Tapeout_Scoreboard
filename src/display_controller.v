`default_nettype none
`timescale 1ns/1ps
`ifndef __DISPLAY_CONTROLLER__
`define __DISPLAY_CONTROLLER__

module display_controller (
    input wire clk_1khz,        // 1 kHz Clock
    input wire rst_i,           // Reset
    // Spieler 1 Score
    input wire [3:0] p1_tens_i,
    input wire [3:0] p1_ones_i,
    // Spieler 2 Score  
    input wire [3:0] p2_tens_i,
    input wire [3:0] p2_ones_i,
    // Output zum Display
    output reg [3:0] tens_o,
    output reg [3:0] ones_o
);

    // Timing Parameter für 1kHz Clock
    parameter BLINK_TIME = 500;   // 500ms blinken (0.5s)
    parameter DISPLAY_TIME = 2000; // 2000ms anzeigen (2s)
    
    // States
    reg [2:0] state;
    localparam P1_BLINK    = 3'b000;
    localparam P1_DISPLAY  = 3'b001;
    localparam P2_BLINK    = 3'b010;
    localparam P2_DISPLAY  = 3'b011;
    
    // Display Zustände
    localparam DIGIT_OFF   = 4'd10;  // Display komplett aus
    localparam DIGIT_P     = 4'd11;  // Buchstabe 'P'
    
    // Counter und Control
    reg [10:0] timer;           // 11-bit Timer (max 2048ms)
    reg [2:0] blink_count;      // Blink-Zähler (0-4 für 3x Blinken)
    reg blink_state;            // Blink-Zustand (0=aus, 1=an)

    // Single always block für alles
    always @(posedge clk_1khz) begin
        if (rst_i) begin
            timer <= 0;
            blink_state <= 1;   // Start mit AN
            blink_count <= 0;
            state <= P1_BLINK;
            tens_o <= DIGIT_P;  // Start mit P1 angezeigt
            ones_o <= 4'd1;
        end else begin
            // Timer
            if (timer < (state[0] ? DISPLAY_TIME : BLINK_TIME)) begin
                timer <= timer + 1;
            end else begin
                timer <= 0;
                
                // State Machine
                case (state)
                    P1_BLINK: begin
                        if (blink_count < 4) begin  // 0,1,2,3,4 = 5 Zustände = 3x P1 sichtbar
                            blink_count <= blink_count + 1;
                        end else begin
                            blink_count <= 0;
                            state <= P1_DISPLAY;
                        end
                    end
                    
                    P1_DISPLAY: begin
                        state <= P2_BLINK;
                        blink_state <= 1; // Reset für P2 Blink (startet mit AN)
                    end
                    
                    P2_BLINK: begin
                        if (blink_count < 4) begin  // Gleiches Pattern für P2
                            blink_count <= blink_count + 1;
                        end else begin
                            blink_count <= 0;
                            state <= P2_DISPLAY;
                        end
                    end
                    
                    P2_DISPLAY: begin
                        state <= P1_BLINK;
                        blink_state <= 1; // Reset für P1 Blink (startet mit AN)
                    end
                    
                    default: state <= P1_BLINK;
                endcase
            end
            
            // Output Logic + Blink Control im gleichen Block
            case (state)
                P1_BLINK: begin
                    // Toggle zu Beginn jedes Intervalls
                    if (timer == 0) blink_state <= ~blink_state;
                    
                    if (blink_state) begin
                        tens_o <= DIGIT_P;   // 'P'
                        ones_o <= 4'd1;      // '1'
                    end else begin
                        tens_o <= DIGIT_OFF; // Aus
                        ones_o <= DIGIT_OFF; // Aus
                    end
                end
                
                P1_DISPLAY: begin
                    tens_o <= p1_tens_i;     // Normale Ziffern (0-9)
                    ones_o <= p1_ones_i;     // Normale Ziffern (0-9)
                end
                
                P2_BLINK: begin
                    // GLEICHES BLINK-PATTERN wie P1
                    if (timer == 0) blink_state <= ~blink_state;
                    
                    if (blink_state) begin
                        tens_o <= DIGIT_P;   // 'P'
                        ones_o <= 4'd2;      // '2'
                    end else begin
                        tens_o <= DIGIT_OFF; // Aus
                        ones_o <= DIGIT_OFF; // Aus
                    end
                end
                
                P2_DISPLAY: begin
                    tens_o <= p2_tens_i;     // Normale Ziffern (0-9)
                    ones_o <= p2_ones_i;     // Normale Ziffern (0-9)
                end
                
                default: begin
                    tens_o <= DIGIT_OFF;
                    ones_o <= DIGIT_OFF;
                end
            endcase
        end
    end

endmodule
`endif
`default_nettype wire
