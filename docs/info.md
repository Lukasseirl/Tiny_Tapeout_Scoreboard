# Tiny Tapeout Scoreboard

## Introduction

The Tiny Tapeout Scoreboard chip processes the input of two pushbuttons and controls two 7 segment displays. The purpose is to count and show a game score of two players. With the two pushbuttons you are able to set the points - button 1 is for player 1 and button 2 for player 2. A short press adds one point to the count, a long press (at least 1.5 seconds) decreases the score by 1. The two digit score of each player is then presented via two 7-segment displays wich alternate between the score of player 1 and player 2. Therefore the scoreboard blinks 2 times with the text 'P1' or 'P2' and after the blinking the respective score of each player is shown for 2 seconds.

Furthermore, there is a pushbutton-processor that, not only recognises a long press of a push buthon, but has an debounce logic so that a single pushbutton press increases the score just by one - even if the button is bouncing. Also the score is limited to 00-99 - so if your score is 99 and you push the button, nothing will happen and the score stays at 99.

### Hardware

The screenshot below shows the required hardware for the project. For the user inputs we use two pushbuttons with a pullup resistor which are connected to the tiny tapeout board at IN0 and IN1. For the representation of the score we use two 7-segment display. To control them we use 7 of the 8 output pins and additionally use the bidirectional pins as output. 

Our tiny tapeout chip is the heart of the hardware and processes the button presses and controlls the 7-segment displays.

<img width="2468" height="1024" alt="grafik" src="https://github.com/user-attachments/assets/496a0537-259a-49d0-8b90-d642fc3afa7f" />

### Structure of the Modules

The project consists of several modules. The general structure of the modules can be seen in the screenshot below.

For each player we have a pushbutton processor. This processes the bushbutton signal and sends a 'count up' or 'count down' signal to a counter module which increases or decreases a counter and safes the current score. This binary count is then convertet into a decimal number with another module. The the two scores go to the display controller which controlls the represantation animation of the score and tells the display driver what should be displayed. The display driver then controlls the the single bits of the 7-segment displays to display the commands of the display controller correctly.


<img width="1359" height="424" alt="grafik" src="https://github.com/user-attachments/assets/ac7c8c91-59c5-4f75-a638-3c5ba374a46f" />

Further below all modules are will be explained in more detail.



## Pushbutton Processor
In addition to the clock and reset signals that all modules have, this module has the pushbutton signal as input and two outputs. 

```
module pushbutton_processor (
    input wire clk_1khz,       // 1 kHz Clock
    input wire rst_i,          // Reset signal (active high)
    input wire pushbutton_i,   // Raw pushbutton signal
    output reg count_up,       // Short press -> high pulse
    output reg count_down      // Long press (>2s) -> high pulse
);
```
### Purpose
The module _pushbutton_processor.v_ processes a signal of a pushbutton and has two main tasks to do: 

* debouncing the pushbutton signal
* decide between short (count up) and long button press (count down)

Usually pushbuttons bounce when they get pressed as shown in the screenshot below. This would cause the counter to in-/decrease the score multiple points for a single button press.

<img width="947" height="575" alt="grafik" src="https://github.com/user-attachments/assets/dfa2d1b2-7068-4049-a66b-ca0baf7ff955" />

To solve this problem the pushbutton processor has a debouncing-logic implemented which checks the time duration between two or more rising flanks. Usually the bouncing of a button takes about 100 us to 10 ms. When the first rising flank appears we wait 20 ms before we are able to recognise the next one. This ensures that the bouncing is over and we do not make false counts. 

We also check if the button push is hold for over 1.5 seceonds or gest released before. If the button is released before the 1.5 s we send a 10 ms pulse at the _count_up_ output. If its hold longer we send a puls at the _count_down_ output.

To do so we implemented a state machine that has four states that track the life cycle of the button press:

1. **IDLE:** This is the resting state. The button is not pressed, all counters are reset, and no outputs are active. When the button signal goes high, the machine moves to the debouncing state.
2. **DEBOUNCING:** In this state, the machine checks that the button press is real and not just contact bounce. As long as the button stays pressed, a counter increments. If the button is released before the debounce time expires, the machine returns to IDLE. If the button remains pressed for the full debounce time, the press is considered valid and the machine moves to the PRESSED state.
3. **PRESSED:** Here, the button is confirmed as pressed and the machine measures how long it is held. A counter increments while the button stays pressed. 
    * If the button is released before the long-press time is reached, this is treated as a short press: the machine generates a short count_up pulse and returns to IDLE.
    * If the button stays pressed long enough to exceed the long-press threshold, the machine transitions to the LONG_PRESS state and generates a short count_down pulse.
4. **LONG_PRESS:** This state indicates that a long press has already been detected and reported. No further pulses are generated here. The machine simply waits for the button to be released, and once it is, it returns to the IDLE state, ready for the next press.

```
// Timing parameters for 1kHz clock
parameter DEBOUNCE_TIME = 20;     // 20ms debounce time (20 ticks at 1kHz)
parameter LONG_PRESS_TIME = 1500; // 1.5s long press detection (1500 ticks at 1kHz)
parameter PULSE_WIDTH = 10;        // 1ms output pulse width (1 tick at 1kHz)

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
reg [3:0] pulse_counter;           // Pulse width counter

// NUR EIN always-Block für die komplette Logik
always @(posedge clk_1khz) begin
    if (rst_i) begin
        state <= IDLE;
        counter <= 0;
        pulse_counter <= 0;
        count_up <= 1'b0;
        count_down <= 1'b0;
        pulse_counter_en <= 1'b0;
    end else begin
        // Pulse Counter Logic
        if (pulse_counter_en) begin
            if (pulse_counter < PULSE_WIDTH) begin
                pulse_counter <= pulse_counter + 1;
            end else begin
                pulse_counter_en <= 1'b0;
                pulse_counter <= 0;
                count_up <= 1'b0;
                count_down <= 1'b0;
            end
        end
        
        // State Machine
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
                        count_down <= 1'b1;
                        pulse_counter_en <= 1'b1;
                        pulse_counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end else begin
                    state <= IDLE;
                    count_up <= 1'b1;
                    pulse_counter_en <= 1'b1;
                    pulse_counter <= 0;
                end
            end
            
            LONG_PRESS: begin
                if (!button_sync) begin
                    state <= IDLE;
                end
            end
            
            default: state <= IDLE;
        endcase
    end
end

```

### Testing of the pushbutton processor
