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
parameter PULSE_WIDTH = 10;        // 10ms output pulse width (10 ticks at 1kHz)

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

For the time measurements we need flip-flops to count the clock ticks. As higher frequencies would need more flip-flops to measure the same amout of time, I choose a very low clock speed of 1kHz for this project. This is still fast enough to process pushbutton signals and is also well suited for the display later on.

### Testing of the pushbutton processor

To test the pushbutton processor I wrote a testbench file *pushbutton_processor_tb.v* that simulates different pushbutton presses with bouncing.

With the command 
```
./simulate.sh pushbuton_processor
```

I start the testbenchfile with a shell-script that starts up gtkwave for the simulation where we can analyze the results.

When analyzing the simulation results, it should be noted that we have selected a higher clock frequency in the testbench file. We therefore only need to look at the ticks. For the entire project, the clock frequency is set to 1 kHz, which means that 1 tick = 1 ms. Even though nanoseconds are now visible in gtkwave, this corresponds to milliseconds later on with the correct clock.

If we look at the screenshot below we can see the behaviour of the module. At about t=15 ms the pushbutton signal gets HIGH, bounces a few times and gets low at about t=54 ms. We can see that this triggers the count_up to go high for 10 ms. This shows that the debouncing and the short press works like its supposed to be.  

<img width="1845" height="328" alt="grafik" src="https://github.com/user-attachments/assets/ed472d7d-585b-4a8a-955d-8915012eb2f0" />

The next screenshot shows a more zoomed out image of the same simulation. After the short press a long press is made that is about 2s long. After 1.5s the count down is triggerd and the output for the count_down gets high for 10ms. When the pushbutton is finally released, no additional count up or down is triggered. This shows that the module works extactly as intended. 
<img width="2362" height="274" alt="grafik" src="https://github.com/user-attachments/assets/f453d49f-5f32-400f-90e8-7a8f7db9820c" />


## Counter
The counter module *counter_v2.v* two inputs - one for the *count_up* and one for the *count_down* signal of the previous module. Output of the module is a 7 bit counter value *counter_val_o*. As we want to display a 2-digit number which can be maximum 99, 7-Bits are enough as we can store 0-127 with it. 

```
module counter_v2
#(
    parameter BW = 7 // 7 Bit = 0-127 | optional parameter
) (
    // define inputs and outputs of module
    input    clk_i,         // general clock signal
    input    clk_up_i,      // signal for counting up
    input    clk_down_i,    // signal for counting down
    input    rst_i, 
    output wire [BW-1:0] counter_val_o
);
``` 

### Purpose
The purpose of this module is to count and safe the score of one player. If a *count_up* signal appears, the counter counts up by 1. If a *count_down* signal appears, the counter counts down by 1. In addition, the score is limited to the range 00-99 (decimal). So if the score reaches 99 and a *count_up* signal appears, the counter remains at 99 and does not go on to 100, as this could no longer be displayed on the screen.

The following code snippet shows the implementaion of this logic in the module:

```
// count up on rising edge of clk_up_i
if (clk_up_edge) begin
    if (counter_val < 99) begin
        counter_val <= counter_val + 1; // increment
    end
    // otherwise stay at 99
end 
// count down on rising edge of clk_down_i  
else if (clk_down_edge) begin
    if (counter_val > 0) begin
        counter_val <= counter_val - 1; // decrement
    end
    // otherwise stay at 0
end
```

### Testing of the Counter
To test the module a testbenchfile *counter_v2_tb.v* is made that counts up and down from 0 to 99 and above to test the counting and the intended boundarys. As shown before we use gtkwave for the simulation.  

The screenshot below shows the results of the simulation. The simulation can be split into 3 time frames. In the first 
we have a toggling signal for the up counter while the down counting signal is constant low. In the end we have the opposite were the count down signal is toggling while count up is constant ag low. Inbetween we have a short time frame were both are toggling. 

<img width="2307" height="180" alt="grafik" src="https://github.com/user-attachments/assets/1127c933-77d3-40d0-8de6-3c9a3928811c" />

If we zoom into the first region we can see that the counter *cnt_val* counts up for every rising edge of the *clk_up* signal. 

<img width="1726" height="196" alt="grafik" src="https://github.com/user-attachments/assets/d8eb22f5-a21a-4cd0-9967-049f66970769" />

We can also see that the counter reaches a limit of 63 (bin) which is equal to 99 (dec).

<img width="2228" height="227" alt="grafik" src="https://github.com/user-attachments/assets/d2add1bc-4289-4e81-bc23-fc9151af7f83" />

When the up and down signals are alternatingly triggered, we can see the counter counting up and down.

<img width="1888" height="221" alt="grafik" src="https://github.com/user-attachments/assets/d800f7e6-527b-4013-8ee4-8b3e377d5a46" />

If only the count down signal toggles, then we see the counter counting down again until it finally reaches 0.

<img width="2524" height="225" alt="grafik" src="https://github.com/user-attachments/assets/23cc4b4d-fcc3-4d30-a9f8-cd3fed1f4a59" />




## Bin to Dec
The module *bin_to_decimal.v* gets a binary number as an input and gives back the ones and tens of a decimal number.

```
module bin_to_decimal (
    input  wire [6:0]  bin_i,
    output wire  [3:0]  tens_o,
    output wire  [3:0]  ones_o
);
```


### Purpose
As we want to display our score as a 2 digit decimal number, this module converts the binary count of the previous module and converts it into a decimal number which is split up into ones and tens.  

The conversion is done with the following code. The expression bin_i / 10 computes how many tens are contained in the binary input, and the modulo operation % 10 limits this result to a single decimal digit.
The expression bin_i % 10 computes the remainder of the division by 10, which directly corresponds to the ones digit.
Together, these lines split the binary input value into its decimal tens and ones components. Furthermore, we receive the result as a decimal number because, with 7'd10, we explicitly specify it is a decimal number. 

As single digits only goes from 0-9 we reduce the number of bits for the output with [3:0] to 4 bits.

```
    wire [6:0] tens_full = (bin_i / 7'd10) % 7'd10;
    wire [6:0] ones_full = bin_i % 7'd10;
    
    assign tens_o = tens_full[3:0];
    assign ones_o = ones_full[3:0];
```

### Testing of Bin to Dec
For testing I implement a testbenchfile *bin_to_decimal_tb.v* that gives the module different binary numbers that should be converted into decimal ones and tens. The different test cases can be seen below:

```
    // Test cases
    bin_i = 7'd0;   #1500; // Sollte 0 und 0 ausgeben
    bin_i = 7'd5;   #1500; // Sollte 0 und 5 ausgeben
    bin_i = 7'd15;  #1500; // Sollte 1 und 5 ausgeben
    bin_i = 7'd42;  #1500; // Sollte 4 und 2 ausgeben
    bin_i = 7'd73;  #1500; // Sollte 7 und 3 ausgeben
    bin_i = 7'd99;  #1500; // Sollte 9 und 9 ausgeben
```

The screenshot below shows the results of the simulation. The first binary number is 0 and the ones and tens are also 0. For all different binary numbers of the input, the ones and tens are correctly calculated which shows that the module works as intended.

<img width="1826" height="198" alt="grafik" src="https://github.com/user-attachments/assets/cd500ec9-e139-4918-b927-0be755e90751" />

## Display Controller

The display controller gets the score as ones and tens of the two players as input. The module has two outputs - one for each 7-segment display where one display is for the ones and one is for the tens of the decimal number.

```
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
```

### Purpose
The problem that this module solves is that we need to display a two-digit score for two players, but only have two 7-segment displays available. The solution to this problem is to animate the score so that the score of player 1 and player 2 are displayed alternately. 

The animation is structured as follows. To distinguish which score belongs to which player, the respective player is always displayed before the score with the text ‘P1’ or ‘P2’. The corresponding two-digit score is then displayed.

To better distinguish between the score and the ‘player text’, the player text blinks and the score remains permanently visible. The player text blinks twice for half a second before the score is then displayed for 2 seconds. The entire sequence alternates between player 1 and player 2.


The entire animation is implemented again using a state machine which has the following states:
1. **P1_BLINK:** The display blinks “P1” to indicate that player 1 is active. The digits are periodically turned on and off using BLINK_TIME (500 ms). After a fixed number of blink cycles, the machine moves to the next state.
2. **P1_DISPLAY:** The actual score of player 1 (tens and ones) is shown steadily for DISPLAY_TIME (2000 ms) without blinking. After this time expires, the machine switches to player 2.
3. **P2_BLINK:** The display blinks “P2” in the same way as for player 1, again to indicate the active player. After the defined number of blink cycles, the machine advances to the display state.
4. **P2_DISPLAY:** The actual score of player 2 is shown steadily for DISPLAY_TIME. Once this time is over, the machine returns to P1_BLINK, and the cycle repeats. 
```
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
```
2x
<img width="1096" height="649" alt="grafik" src="https://github.com/user-attachments/assets/c4622d3a-966f-489f-b31c-e7184c5ec28b" />
<img width="1174" height="714" alt="grafik" src="https://github.com/user-attachments/assets/e9103223-9031-4e96-a56e-2976796638d3" />

2000 ms
<img width="1115" height="670" alt="grafik" src="https://github.com/user-attachments/assets/19e83192-0d5b-4a49-96c5-4a38f34a3d1d" />


<img width="1184" height="724" alt="grafik" src="https://github.com/user-attachments/assets/527ddc16-ade0-4f12-baef-45ed958e2175" />
<img width="1174" height="714" alt="grafik" src="https://github.com/user-attachments/assets/e9103223-9031-4e96-a56e-2976796638d3" />

2000 ms
<img width="1160" height="660" alt="grafik" src="https://github.com/user-attachments/assets/b8caf518-aa1a-4eeb-b417-f726a89b2536" />


### Testing of the Display Controller

## Dual 7 Segment Driver
### Purpose
### Testing of the Dual 7 Segment Driver

## Top Module
### Purpose
### Testing of the Top Module

## Testing Design with Wokwi

## Sonstiges 
## filter
### github actions, erkenntnisse/learnings, allgemeine anleitung wie man testet / simuliert
