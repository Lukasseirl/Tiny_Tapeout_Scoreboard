`default_nettype none
`ifndef __PUSHBUTTON_PROCESSOR__
`define __PUSHBUTTON_PROCESSOR__

module pushbutton_processor (
    input wire clk_1khz,       // 1 kHz Clock
    input wire rst_i,          // Reset signal (active high)
    input wire pushbutton_i,   // Raw pushbutton signal
    output reg count_up,       // Short press -> high pulse
    output reg count_down      // Long press (>2s) -> high pulse
);

// Timing parameters for 1kHz clock
parameter DEBOUNCE_TIME = 20;     // 20ms debounce time (20 ticks at 1kHz)
parameter LONG_PRESS_TIME = 1500; // 1.5s long press detection (1500 ticks at 1kHz)
parameter PULSE_WIDTH = 1;        // 1ms output pulse width (1 tick at 1kHz)

// State machine definitions
reg [1:0] state;
localparam IDLE       = 2'b00;
localparam DEBOUNCING = 2'b01;
localparam PRESSED    = 2'b10;
localparam LONG_PRESS = 2'b11;

// Counters and control signals
reg [10:0] counter;          // 11-bit counter for timing (max 2048 ticks)
reg button_sync;             // Synchronized button signal
reg pulse_counter_en;        // Pulse counter enable
reg pulse_counter;           // Pulse width counter

// Button synchronization for metastability protection
always @(posedge clk_1khz) begin
    if (rst_i) begin
        button_sync <= 1'b0;
    end else begin
        button_sync <= pushbutton_i;
    end
end

// Pulse counter for output signals
always @(posedge clk_1khz) begin
    if (rst_i) begin
        pulse_counter_en <= 1'b0;
        pulse_counter <= 0;
        count_up <= 1'b0;
        count_down <= 1'b0;
    end else if (pulse_counter_en) begin
        if (pulse_counter < PULSE_WIDTH) begin
            pulse_counter <= pulse_counter + 1;
        end else begin
            // Pulse duration completed, disable outputs
            pulse_counter_en <= 1'b0;
            pulse_counter <= 0;
            count_up <= 1'b0;
            count_down <= 1'b0;
        end
    end
end

// Main state machine
always @(posedge clk_1khz) begin
    if (rst_i) begin
        state <= IDLE;
        counter <= 0;
    end else begin
        case (state)
            IDLE: begin
                counter <= 0;
                if (button_sync) begin
                    // Button pressed, start debouncing
                    state <= DEBOUNCING;
                    counter <= 0;
                end
            end
            
            DEBOUNCING: begin
                if (button_sync) begin
                    if (counter >= DEBOUNCE_TIME) begin
                        // Debouncing complete, button is stable
                        state <= PRESSED;
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end else begin
                    // Button released during debouncing, return to idle
                    state <= IDLE;
                end
            end
            
            PRESSED: begin
                if (button_sync) begin
                    if (counter >= LONG_PRESS_TIME) begin
                        // Long press detected (>1.5s)
                        state <= LONG_PRESS;
                        // Generate count_down pulse
                        count_down <= 1'b1;
                        pulse_counter_en <= 1'b1;
                        pulse_counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end else begin
                    // Short press detected, generate count_up pulse
                    state <= IDLE;
                    count_up <= 1'b1;
                    pulse_counter_en <= 1'b1;
                    pulse_counter <= 0;
                    counter <= 0;
                end
            end
            
            LONG_PRESS: begin
                // Wait for button release
                if (!button_sync) begin
                    state <= IDLE;
                    counter <= 0;
                end
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule
`endif
