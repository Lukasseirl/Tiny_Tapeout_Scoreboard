# Preamble
**Name:** Lukas Seirlehner

**Student Number:** k12105181

**GitHub Repository:** https://github.com/Lukasseirl/Tiny_Tapeout_Scoreboard

**Wokwi Design:** https://wokwi.com/projects/446954697164307457

# Table of Contents

- [Tiny Tapeout Scoreboard](#tiny-tapeout-scoreboard)
  - [Introduction](#introduction)
    - [Hardware](#hardware)
    - [Structure of the Top Module](#structure-of-the-top-module)
  - [Pushbutton Processor](#pushbutton-processor)
    - [Purpose](#purpose)
    - [Testing of the pushbutton processor](#testing-of-the-pushbutton-processor)
  - [Counter](#counter)
    - [Purpose](#purpose-1)
    - [Testing of the Counter](#testing-of-the-counter)
  - [Bin to Dec](#bin-to-dec)
    - [Purpose](#purpose-2)
    - [Testing of Bin to Dec](#testing-of-bin-to-dec)
  - [Display Controller](#display-controller)
    - [Purpose](#purpose-3)
    - [Testing of the Display Controller](#testing-of-the-display-controller)
  - [Dual 7 Segment Driver](#dual-7-segment-driver)
    - [Purpose](#purpose-4)
    - [Testing of the Dual 7 Segment Driver](#testing-of-the-dual-7-segment-driver)
  - [Top Module](#top-module)
    - [Testing of the Top Module](#testing-of-the-top-module)
  - [Tiny Tapeout Module](#tiny-tapeout-module)
  - [Settings for Tiny Tapeout](#settings-for-tiny-tapeout)
    - [info.json](#infojson)
    - [info.yamal](#infoyamal)
    - [docs.md](#docsmd)
  - [Github Actions](#github-actions)
  - [Testing Design with Wokwi](#testing-design-with-wokwi)
  - [Learnings](#learnings)



# Tiny Tapeout Scoreboard

## Introduction

The **Tiny Tapeout Scoreboard** chip processes the input of two pushbuttons and controls two 7-segment displays. The purpose is to count and display a game-score of two players. With the two pushbuttons you are able to set the points of both players. Button 1 is for player 1 and button 2 for player 2. A short press adds one point to the count, a long press (at least 1.5 seconds) decreases the score by 1. The two digit score of each player is then presented via two 7-segment displays which alternate between the score of player 1 and player 2. Therefore the scoreboard blinks 2 times with the text 'P1' or 'P2' and after the blinking the respective score of each player is shown for 2 seconds.

Furthermore, there is a pushbutton-processor that, not only recognises a long press of a push buthon, but has an debounce logic so that a single pushbutton press increases the score just by one - even if the button is bouncing. Also the score is limited between 00 to 99 - so if your score is 99 and you push the button, nothing will happen and the score stays at 99.

### Hardware

The screenshot below shows the required hardware for the project. For the user inputs we use two pushbuttons with a pullup resistor which are connected to the tiny tapeout board at **IN0** and **IN1**. For the representation of the score we use two 7-segment display. To control them we use 7 output pins and additionally use the bidirectional pins as output as well. 

Our tiny tapeout chip is the heart of the hardware and processes the button presses and controlls the 7-segment displays.

<img width="2208" height="880" alt="grafik" src="https://github.com/user-attachments/assets/67f0d031-a08d-4f3c-935d-ed9f1df227ab" />


### Structure of the Top Module

The project consists of several modules. The general structure of the modules can be seen in the screenshot below.

For each player we have a pushbutton processor. This processes the pushbutton signal and sends a 'count up' or 'count down' signal to a counter module which increases or decreases a counter and saves the current score. This binary count is then convertet into a decimal number with another module. The the two scores go to the display controller which controlls the represantation animation of the score and tells the display driver what should be displayed. The display driver then controlls the single bits of the 7-segment displays to display the numbers/letters of the display controller correctly.


<img width="1359" height="424" alt="grafik" src="https://github.com/user-attachments/assets/ac7c8c91-59c5-4f75-a638-3c5ba374a46f" />

In the following all modules are explained in more detail.


## Pushbutton Processor
In addition to the inputs **clock** and **reset** signals that all modules have, this module has a pushbutton signal as an input. Furthermore there are two outputs - one that gives a pulse for counting up and one for counting down. 

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

Usually pushbuttons bounce when they get pressed as shown in the screenshot below. This would cause the counter to in-/decrease the score multiple points for a single button press - what is unwanted.

<img width="500" height="300" alt="grafik" src="https://github.com/user-attachments/assets/dfa2d1b2-7068-4049-a66b-ca0baf7ff955" />

To solve this problem the pushbutton processor has a debouncing-logic implemented which checks the time duration between two or more rising flanks. Usually the bouncing of a button takes about 100 us to 10 ms. When the first rising flank appears the module waits 20 ms before it is able recognise the next rising flank. After that waiting time the bouncing process should be over and we do not make any false counts. 

We also check if the button push is hold for over 1.5s or gest released before. If the button is released before the 1.5 s we send a 10 ms pulse at the _count_up_ output. If its hold at least for 1.5s we send a pulse at the _count_down_ output.

To do so I implemented a state machine that has four states that track the life cycle of the button press:

1. **IDLE:** This is the resting state. The button is not pressed, all counters are reset, and no outputs are active. When the button signal goes HIGH, the machine moves to the debouncing state.
2. **DEBOUNCING:** In this state, the machine checks that the button press is real and not just contact bounce. As long as the button stays pressed, a counter increments. If the button is released before the debounce time expires, the machine returns to IDLE. If the button remains pressed for the full debounce time, the press is considered valid and the machine moves to the PRESSED state.
3. **PRESSED:** Here, the button is confirmed as pressed and the machine measures how long it is held. A counter increments while the button stays pressed. 
    * If the button is released before the long-press time is reached, this is treated as a short press: the machine generates a short count_up pulse and returns to IDLE.
    * If the button stays pressed long enough to exceed the long-press threshold, the machine transitions to the LONG_PRESS state and generates a short count_down pulse.
4. **LONG_PRESS:** This state indicates that a long press has already been detected and reported. No further pulses are generated here. The machine simply waits for the button to be released, and once it is, it returns to the IDLE state, ready for the next press.

For the time measurements we need flip-flops to count the clock ticks. As higher frequencies would need more flip-flops to measure the same amout of time, I choose a very low clock speed of 1kHz for this project. This is still fast enough to process pushbutton signals but saves a lot of tile area due to the smaller number of flip-flops.

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

### Testing of the pushbutton processor

To test the pushbutton processor I wrote a testbench file *pushbutton_processor_tb.v* that simulates different pushbutton presses with bouncing.

With the command 
```
./simulate.sh pushbuton_processor
```

I start the testbenchfile with a shell-script that starts up gtkwave for the simulation where we can analyze the results.

When analyzing the simulation results, it should be noted that I have selected a higher clock frequency in the testbench file. Therefore I only need to look at the ticks. For the entire project, the clock frequency is set to 1 kHz, which means that 1 tick = 1 ms. Even though nanoseconds are now visible in gtkwave, this corresponds to milliseconds later on with the correct clock speed.

If we look at the screenshot below we can see the behaviour of the module. At about t=15 ms the pushbutton signal gets HIGH, bounces a few times and gets low at about t=54 ms. We can see that this triggers the count_up to go HIGH for 10 ms. This shows that the debouncing and the short press works like its supposed to be.  

<img width="1845" height="328" alt="grafik" src="https://github.com/user-attachments/assets/ed472d7d-585b-4a8a-955d-8915012eb2f0" />

The next screenshot shows a more zoomed out image of the same simulation. After the short press a long press is simulated that is about 2s long. After 1.5s the 'count down' is triggerd and the output for the count_down gets HIGH for 10ms. When the pushbutton is finally released, no additional count up or down is triggered. This shows that the module works extactly as intended. 
<img width="2362" height="274" alt="grafik" src="https://github.com/user-attachments/assets/f453d49f-5f32-400f-90e8-7a8f7db9820c" />


## Counter
The counter module *counter_v2.v* has two inputs - one for the *count_up* and one for the *count_down* signal of the previous module. Output of the module is a 7-bit counter value *counter_val_o*. As we want to display a 2-digit number which can be maximum 99, 7-Bits are enough as we can store 0-127 with it. The number of bits can be adjusted with the parameter **BW** so that this module can be used for other projects as well where a different counting range is needed.

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
The purpose of this module is to count and save the score of a player. If a *count_up* signal appears, the counter counts up by 1. If a *count_down* signal appears, the counter counts down by 1. In addition, the score is limited to the range 00-99 (decimal). So if the score reaches 99 and a *count_up* signal appears, the counter remains at 99 and does not go on to 100, as this could no longer be displayed with the two displays.

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
To test the module a testbenchfile *counter_v2_tb.v* is made that counts up and down from 0 to 99 and above to test the counting and the intended boundaries. As shown before we use gtkwave for the simulation.  

The screenshot below show the results of the simulation. The simulation can be split into 3 time frames. In the first 
we have a signal toggling between HIGH and LOW for the up counter while the down counting signal is constant LOW. In the end we have the opposite were the count down signal is toggling while count up is constant at LOW. Inbetween we have a short time frame were both are toggling. 

<img width="2307" height="180" alt="grafik" src="https://github.com/user-attachments/assets/1127c933-77d3-40d0-8de6-3c9a3928811c" />

If we zoom into the first region we can see that the counter *cnt_val* counts up for every rising edge of the *clk_up* signal. 

<img width="1726" height="196" alt="grafik" src="https://github.com/user-attachments/assets/d8eb22f5-a21a-4cd0-9967-049f66970769" />

We can also see that the counter reaches a limit of 63 (hex) which is equal to 99 (dec).

<img width="2228" height="227" alt="grafik" src="https://github.com/user-attachments/assets/d2add1bc-4289-4e81-bc23-fc9151af7f83" />

When the up and down signals are alternatingly triggered, we can see the counter counting up and down.

<img width="1888" height="221" alt="grafik" src="https://github.com/user-attachments/assets/d800f7e6-527b-4013-8ee4-8b3e377d5a46" />

If only the count down signal toggles, then we see the counter counting down until it finally reaches 0. This shows that the counter modules works as supposed to.

<img width="2524" height="225" alt="grafik" src="https://github.com/user-attachments/assets/23cc4b4d-fcc3-4d30-a9f8-cd3fed1f4a59" />




## Bin to Dec
The module *bin_to_decimal.v* gets a binary number as an input and gives back the **ones** and **tens** of a decimal number.

```
module bin_to_decimal (
    input  wire [6:0]  bin_i,
    output wire  [3:0]  tens_o,
    output wire  [3:0]  ones_o
);
```


### Purpose
As we want to display our score as a 2 digit decimal number, this module converts the binary count of the previous module and converts it into a decimal number which is split up into ones and tens.  

The conversion is done with the following code. The expression **bin_i / 10** computes how many tens are contained in the binary input, and the modulo operation **% 10** limits this result to a single decimal digit.
The expression **bin_i % 10** computes the remainder of the division by 10, which directly corresponds to the ones digit.
Together, these lines split the binary input value into its decimal tens and ones components. Furthermore, we receive the result as a decimal number because, with 7'd10, we explicitly specify it is a decimal number. 

As single digits only goe from 0-9, we reduce the number of bits for the output with [3:0] to 4 bits.

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

The display controller *display_controller.v* gets the score as ones and tens of the two players as input. The module has two outputs - one for each 7-segment display where one display is for the ones and one is for the tens of the decimal number.

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

The animation is structured as follows: To distinguish which score belongs to which player, the respective player is always displayed before the score with the text ‘P1’ or ‘P2’. The corresponding two-digit score is then displayed afterwards.

To better distinguish between the 'score' and the ‘player text’, the player text blinks and the score remains permanently visible. The player text blinks twice for half a second before the score is then displayed for 2 seconds. The entire sequence alternates between player 1 and player 2.

The entire animation is implemented again using a state machine which has the following states:
1. **P1_BLINK:** The display blinks “P1” to indicate that player 1 is active. The digits are periodically turned on and off using BLINK_TIME (500 ms). After 2 blink cycles, the machine moves to the next state.
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
$0
            end
            
            default: begin
                tens_o <= DIGIT_OFF;
                ones_o <= DIGIT_OFF;
            end
        endcase
    end
end
```

The display controller module tells the subsequent display driver module what should be displayed on the screen and simply sends it the digits 0-9. However, there are two special cases: when the display should be turned off completely, or when a ‘P’ should be displayed for the text ‘P1’ and ‘P2’. In these cases, the module sends the numbers ‘10’ for ‘OFF’ and ‘11’ for ‘P’ to its outputs. 

Following screenshots show the different states of the animation for a score of P1=03 and P2=15.

**2x 500ms on/off**

<img width="500" height="300" alt="grafik" src="https://github.com/user-attachments/assets/c4622d3a-966f-489f-b31c-e7184c5ec28b" />
<img width="500" height="300" alt="grafik" src="https://github.com/user-attachments/assets/e9103223-9031-4e96-a56e-2976796638d3" />

**Score for 2000 ms**

<img width="500" height="300" alt="grafik" src="https://github.com/user-attachments/assets/19e83192-0d5b-4a49-96c5-4a38f34a3d1d" />

**2x 500ms on/off**

<img width="500" height="300" alt="grafik" src="https://github.com/user-attachments/assets/527ddc16-ade0-4f12-baef-45ed958e2175" />
<img width="500" height="300" alt="grafik" src="https://github.com/user-attachments/assets/e9103223-9031-4e96-a56e-2976796638d3" />

**2000 ms**

<img width="500" height="300" alt="grafik" src="https://github.com/user-attachments/assets/b8caf518-aa1a-4eeb-b417-f726a89b2536" />

### Testing of the Display Controller
To test the animation I wrote a simple testbenchfile *display_controller_tb.v* that sets the score of the players to P1=12 and P2=7 and simulates the animation. 


The screenshot below shows the results of the gtkwave simulation. At first we can see the blinking 'P1' text where both segments are alternating set to **OFF** and **P1** so that **P1** appers blinking two times. Just to remember, 10 = segments off, 11 = 'P'. After the blinking we can see that the score '12' of player 1 is shown. After that the same process begins for player 2. The simulation shows that the animation is working.

<img width="2366" height="316" alt="grafik" src="https://github.com/user-attachments/assets/4555641e-f493-466a-b531-0064ecf0d58f" />


## Dual 7 Segment Driver
The dual 7 segment display driver *dual_7_seg.v* has an input for the ones and the tens. Furthermore it has 2x 7-bit outputs to control the individual segments of the two 7-segment displays.

```
module dual_7_seg
(
    // define I/O's of the module
    input  wire        clk_i,       // clock
    input  wire        rst_i,       // reset (active high)
    input  wire [3:0]  tens_i,      // BCD tens digit
    input  wire [3:0]  ones_i,      // BCD ones digit
    output reg  [6:0]  seg_tens_o,  // 7-segment output for tens
    output reg  [6:0]  seg_ones_o   // 7-segment output for ones
);
```

### Purpose
The purpose of the dual 7 segment driver is to display the given decimal numbers and the 'P' correctly with the 7-segment displays. Therfore a simple mapping with bit masks is made. As the display is connected to a common anode we need to invert the bitmasks - so 0 means HIGH and 1 menas LOW.

The following screenshot shows the order in which the segments are used, numbered from **a** to **g**.  As a example, to represent a '0' all segments need to be HIGH except **g**.

<img width="150" height="300" alt="grafik" src="https://github.com/user-attachments/assets/dbbda87a-ed57-486e-a2fc-a877aca078c3" />

Here you can see the mapping for all possible inputs from 0-11:

```
case (bcd)
    4'd0: bcd_to_7seg = 7'b1000000; // 0 - ABCDEF
    4'd1: bcd_to_7seg = 7'b1111001; // 1 - BC
    4'd2: bcd_to_7seg = 7'b0100100; // 2 - ABDEG
    4'd3: bcd_to_7seg = 7'b0110000; // 3 - ABCDEG
    4'd4: bcd_to_7seg = 7'b0011001; // 4 - BCFG
    4'd5: bcd_to_7seg = 7'b0010010; // 5 - ACDFG
    4'd6: bcd_to_7seg = 7'b0000010; // 6 - ACDEFG
    4'd7: bcd_to_7seg = 7'b1111000; // 7 - ABC
    4'd8: bcd_to_7seg = 7'b0000000; // 8 - ABCDEFG
    4'd9: bcd_to_7seg = 7'b0010000; // 9 - ABCDFG
    4'd10: bcd_to_7seg = 7'b1111111; // OFF - all Segments off
    4'd11: bcd_to_7seg = 7'b0001100; // 'P' - ABEFG
    default: bcd_to_7seg = 7'b0111111; // "-" (Error) - G
endcase
```

### Testing of the Dual 7 Segment Driver

To test the module I made another testbenchfile *dual_7_seg_tb.v* which sets the ones and tens to different numbers so we can check if the module gives us the correct bits for the display. 

Here you can see the selected numbers for the test:
```
// Test various digit combinations
// Test 00-09
tens_i = 4'd0;
ones_i = 4'd0; #20;
ones_i = 4'd1; #20;
ones_i = 4'd2; #20;
ones_i = 4'd3; #20;
ones_i = 4'd4; #20;
ones_i = 4'd5; #20;
ones_i = 4'd6; #20;
ones_i = 4'd7; #20;
ones_i = 4'd8; #20;
ones_i = 4'd9; #20;

// Test 10-19
tens_i = 4'd1;
ones_i = 4'd0; #20;
ones_i = 4'd1; #20;
ones_i = 4'd2; #20;
ones_i = 4'd3; #20;
ones_i = 4'd4; #20;
ones_i = 4'd5; #20;
ones_i = 4'd6; #20;
ones_i = 4'd7; #20;
ones_i = 4'd8; #20;
ones_i = 4'd9; #20;

// Test some specific numbers
tens_i = 4'd4; ones_i = 4'd2; #20; // 42
tens_i = 4'd7; ones_i = 4'd7; #20; // 77
tens_i = 4'd9; ones_i = 4'd9; #20; // 99

// Test invalid BCD values
tens_i = 4'd10; ones_i = 4'd11; #20;
tens_i = 4'd15; ones_i = 4'd12; #20;

// Test reset
rst_i = 1'b1; #20;
rst_i = 1'b0; #20;

// Final test
tens_i = 4'd8; ones_i = 4'd1; #20; // 81
```

The screenshots below shows the result of the simulation. The first two lines show the input signals and the last two lines show the output signals. In gtkwave we can switch the data format of the signals. The first screenshot shows the output in decimal and the second screenshots shows the output with binary numbers. Unfortunately both representations are not very practical to check if the representation is correct.

<img width="2025" height="228" alt="grafik" src="https://github.com/user-attachments/assets/bd1e50ca-3129-438a-baa0-8265a83cc584" />
<img width="2540" height="242" alt="grafik" src="https://github.com/user-attachments/assets/00b68255-cf28-4897-9a4f-ba894ef4e3d0" />

However, gtkwave offers the option of using a filter script that converts the numbers into a different format. So I wrote and applied my own script, which interprets the binary numbers as decimal numbers/letters, just as they would be displayed with the 7-segment displays.

The filter script is a python file *filter-process.py* with the following code for the conversion:

```
def transform(value):
    seg7_map = {
        0b1000000: "0",
        0b1111001: "1",
        0b0100100: "2",
        0b0110000: "3",
        0b0011001: "4",
        0b0010010: "5",
        0b0000010: "6",
        0b1111000: "7",
        0b0000000: "8",
        0b0010000: "9",
        0b1111111: " ",
        0b0001100: "P",
        0b0111111: "-"
    }

    try:
        int_val = int(value, 2) if value.startswith("0b") else int(value, 16)
        int_val &= 0x7F  # 7-bit Common Anode
        return seg7_map.get(int_val, "?")
    except:
        return "?"
```

To use the filter script for a signal you need to select the signal in gtkwave, make a right click and then go to **Data Format** => **Translate Filter Process** => **Enable and Select**. Then you choose the filter file *filter-process.py* and click **Ok**. 

<img width="1000" height="600" alt="grafik" src="https://github.com/user-attachments/assets/f1f27867-e8d2-48f1-a198-393b0e65fe11" />
<img width="500" height="350" alt="grafik" src="https://github.com/user-attachments/assets/f6c6ac4f-6a62-4eb2-8c73-1a2e4ea799d1" />

At the screenshot below you can see the new representation of the output. Now it is very easy to compare it to the input. The simulation shows that the 7 segment displays show the expected numbers and also the letter 'P'. If any other numbers than 0-11 are given in the input, the 7 segment display shows '-' which represents an error. The simulation shows, that the module works like intended.

<img width="2426" height="227" alt="grafik" src="https://github.com/user-attachments/assets/43d21d64-5781-4974-a63c-4604fb7dfd8e" />

## Top Module
The top module *scoreboard_top.v* combines all modules like in the structure of section [Structure of the Modules](#structure-of-the-modules). For each player we need a pushbutton processor, a counter and binary to decimal converter. Then we need one display controller and the display driver. 

As inputs of the top module we have the two pushbutton signals and our outputs are the 2x 7 bits for the seven segment displays.

```
module scoreboard_top
(
    // define I/O's of the top module
    input  wire        clk_1khz_i,     // 1 kHz clock
    input  wire        rst_i,          // Reset (active high)
    input  wire        pushbutton_p1_i,// Raw pushbutton signal Spieler 1
    input  wire        pushbutton_p2_i,// Raw pushbutton signal Spieler 2
    output wire [6:0]  seg_tens_o,     // Tens 7-segment output
    output wire [6:0]  seg_ones_o      // Ones 7-segment output
);
```

### Testing of the Top Module

To test the top module we make a testbenchfile *scoreboard_top-2_tb.v* which is similar to the testbench of the pushbutton processor. We simulate different pushbutton presses and check if the displays shows the expected results. Therefore we use our filter-process python script again.

The screenshot below shows the simulation result in gtkwave. The first two signals show the displayed values of the 7-segment displays and the last two signals are the signals of the pushbuttons of player 1 and 2. We can see the blinking animation. We can also see that the score of player 1 increases with the button presses of pushbutton 1. 

<img width="2013" height="249" alt="grafik" src="https://github.com/user-attachments/assets/33da6fae-d73e-4111-8edf-34f96d10da0d" />

If we zoom furthre in we can see the pushbutton signal also simulates the bouncing. The testbench shows that the file works as intended.

<img width="1825" height="287" alt="grafik" src="https://github.com/user-attachments/assets/7cbbfe21-3ad1-46af-9c6a-67e2200e0d00" />

## Tiny Tapeout Module
In the last step we need to implement our top module *scoreboard_top.v* in the given tiny tapout module *project.v* to set the connections between our module and the board correctly. 

```
module tt_um_Lukasseirl (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Wire definitions
  wire [6:0] seg_tens;
  wire [6:0] seg_ones;
  
  // Instantiate the scoreboard module
  scoreboard_top scoreboard_inst (
    .clk_1khz_i     (clk),           // Using main clock as 1kHz clock
    .rst_i          (~rst_n),        // Convert active-low reset to active-high
    .pushbutton_p1_i(~ui_in[0]),      // Spieler 1 Pushbutton
    .pushbutton_p2_i(~ui_in[1]),      // Spieler 2 Pushbutton (neuer Input)
    .seg_tens_o     (seg_tens),      // Tens digit
    .seg_ones_o     (seg_ones)       // Ones digit
  );

  // Assign outputs - ones digit to uo_out, tens digit to uio_out
    assign uo_out = {1'b1, seg_ones};  // Pad with 0 to make 8 bits
    assign uio_out = {1'b1, seg_tens}; // Pad with 0 to make 8 bits
  
  // Set I/O enable: all uio pins as outputs
  assign uio_oe = 8'b11111111;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:2], uio_in, 1'b0};

endmodule
```

## Settings for Tiny Tapeout
For the github-actions to run through we need to make all settings correctly. So we need to update the *config.json*, *info.yamal* and the *docs.md*. Also our modules must be flawless otherwise librelane will fail building the chip design.

### info.json
In the *info.json* file the only thing we have to change is the CLOCK_PERIOD which we set to 1.000.000 ns which gives us the clock frequency of 1 kHz.

### info.yamal
In the *info.yamal* file we include all our needed modules and describe wich pins are used for what. We also set the clock speed correctly to 1000 Hz and give the project title and our top module a unique name.

```
# Tiny Tapeout project information
project:
  title:        "Tiny_Tapeout_Scoreboard"      # Project title
  author:       "Lukasseirl"      # Your name
  discord:      ""      # Your discord username, for communication and automatically assigning you a Tapeout role (optional)
  description:  "Scoreboard for two players that can be controlled with two pushbuttons."      # One line description of what your project does
  language:     "Verilog" # other examples include SystemVerilog, Amaranth, VHDL, etc
  clock_hz:     1000       # Clock frequency in Hz (or 0 if not applicable)

  # How many tiles your design occupies? A single tile is about 167x108 uM.
  tiles: "1x1"          # Valid values: 1x1, 1x2, 2x2, 3x2, 4x2, 6x2 or 8x2

  # Your top module name must start with "tt_um_". Make it unique by including your github username:
  top_module:  "tt_um_Lukasseirl"

  # List your project's source files here.
  # Source files must be in ./src and you must list each source file separately, one per line.
  # Don't forget to also update `PROJECT_SOURCES` in test/Makefile.
  source_files:
    - "project.v"
    - "bin_to_decimal.v"
    - "counter_v2.v"
    - "dual_7_seg.v"
    - "pushbutton_processor.v"
    - "scoreboard_top.v"
    - "display_controller.v"

# The pinout of your project. Leave unused pins blank. DO NOT delete or add any pins.
# This section is for the datasheet/website. Use descriptive names (e.g., RX, TX, MOSI, SCL, SEG_A, etc.).
pinout:
  # Inputs
  ui[0]: "P1"  # push button for player 1
  ui[1]: "P2"  # push button for player 2
  ui[2]: ""
  ui[3]: ""
  ui[4]: ""
  ui[5]: ""
  ui[6]: ""
  ui[7]: ""

  # Outputs
  uo[0]: "Seg_A1"    # output pins for seven segment display of the ONES 
  uo[1]: "Seg_B1"
  uo[2]: "Seg_C1"
  uo[3]: "Seg_D1"
  uo[4]: "Seg_E1"
  uo[5]: "Seg_F1"
  uo[6]: "Seg_G1"
  uo[7]: "Seg_H1"

  # Bidirectional pins
  uio[0]: "Seg_A2"    # output pins for seven segment display of the TENS
  uio[1]: "Seg_B2"
  uio[2]: "Seg_C2"
  uio[3]: "Seg_D2"
  uio[4]: "Seg_E2"
  uio[5]: "Seg_F2"
  uio[6]: "Seg_G2"
  uio[7]: "Seg_H2"

# Do not change!
yaml_version: 6
```

### docs.md
In the *docs.md* is my documentation which is this file you are reading right now. To save some time I did not make an extra protrocol and wrote my documentation in here.

## Github Actions

Here it can be seen that all github actions are green:

<img width="400" height="220" alt="grafik" src="https://github.com/user-attachments/assets/424c35ab-eed9-4083-ba5a-50dcb13a1c04" />

<img width="400" height="220" alt="grafik" src="https://github.com/user-attachments/assets/d1eacdb9-865c-4b77-934b-e01fda36037f" />

The design uses 34.97 % of the tile area. When the gds action runs through we can also view our design in the 2D and 3D viewer which gives an interesting look at our own chip:

<img width="2274" height="1581" alt="grafik" src="https://github.com/user-attachments/assets/4b39d27b-0bdd-4f82-984f-f1518ff80784" />

<img width="2921" height="1737" alt="grafik" src="https://github.com/user-attachments/assets/dc6d42ad-a32c-4a4c-b210-d951b427c8be" />

<img width="1829" height="1729" alt="grafik" src="https://github.com/user-attachments/assets/268db7fe-1c17-431a-bc8f-98687592f143" />

## Testing Design with Wokwi

With Wokwi we are able to test our chip design including all the hardware we would have in the real world. For this we build our circuit in Wokwi and for our chip we use the **Custom Chip**. When adding the chip, it is important to set the language to Verilog.

<img width="374" height="216" alt="grafik" src="https://github.com/user-attachments/assets/37ee67b8-a141-4d31-9df6-94d831ad5bc4" />

After creating the chip, two new files, **my-verilog-project.chip.json** and **my-verilog-project.chip.v** are created.

In the .json file we need define the Inputs and outputs of the Chip:
```
{
  "name": "scoreboard",
  "author": "Lukas Seirlehner",
  "pins": [
    "clk",
    "rst_n",
    "ui_in_0",    
    "ui_in_1",
    "uo_out_0",
    "uo_out_1",
    "uo_out_2",
    "uo_out_3",
    "uo_out_4",
    "uo_out_5",
    "uo_out_6",
    "uio_out_0",
    "uio_out_1",
    "uio_out_2",
    "uio_out_3",
    "uio_out_4",
    "uio_out_5",
    "uio_out_6"
  ],
  "controls": []
}
```

In the .v file we copy all of our verilog modules:

* tt_um_Lukasseirl
* scoreboard_top
* pushbutton_processor
* dual_7_seg
* display_controller
* counter_v2
* bin_to_decimal

Additionaly there is a automatically generate module called **wokwi** in this file. It is the top level module that is executed by the created chip. The inputs and outputs of the module must be adjusted so that it matches the previously created .josn file.
```
module wokwi (
  input wire clk,
  input wire rst_n,
  input wire ui_in_0,
  input wire ui_in_1,

  output wire uo_out_0,
  output wire uo_out_1,
  output wire uo_out_2,
  output wire uo_out_3,
  output wire uo_out_4,
  output wire uo_out_5,
  output wire uo_out_6,

  output wire uio_out_0,
  output wire uio_out_1,
  output wire uio_out_2,
  output wire uio_out_3,
  output wire uio_out_4,
  output wire uio_out_5,
  output wire uio_out_6
  );

wire [7:0] ui_in;
wire [7:0] uo_out;
wire [7:0] uio_in = 8'b0;
wire [7:0] uio_out;
wire [7:0] uio_oe; 
wire ena = 1'b1;

assign ui_in = {6'b0, ui_in_1, ui_in_0}; 

tt_um_Lukasseirl uut (
  .ui_in(ui_in),
  .uo_out(uo_out),
  .uio_in(uio_in),
  .uio_out(uio_out),
  .uio_oe(uio_oe),
  .ena(ena),
  .clk(clk),
  .rst_n(rst_n)
);

// Mappe 8-bit Ausgang auf einzelne Segmente
assign uo_out_0 = uo_out[0];
assign uo_out_1 = uo_out[1];
assign uo_out_2 = uo_out[2];
assign uo_out_3 = uo_out[3];
assign uo_out_4 = uo_out[4];
assign uo_out_5 = uo_out[5];
assign uo_out_6 = uo_out[6];

assign uio_out_0 = uio_out[0];
assign uio_out_1 = uio_out[1];
assign uio_out_2 = uio_out[2];
assign uio_out_3 = uio_out[3];
assign uio_out_4 = uio_out[4];
assign uio_out_5 = uio_out[5];
assign uio_out_6 = uio_out[6];

endmodule
```

For the pushbuttons there is an option **Bounce** in the settings that can be checked. So our buttons act like real buttons with bouncing. 
Feel free to test and try my chip design with wokwi here: https://wokwi.com/projects/446954697164307457



## Learnings
Through this project, I learned many new things. Before starting this project, I had never worked with a hardware description language, but now I have basic knowledge of Verilog. It was very interesting to see the whole process of how a chip is designed and created, as this process is much more complex than it might seem at first.

Because of the many tools that support the design process today, it is now possible for almost anyone to create their own chip. The Tiny Tapeout project shows that chip design is no longer limited to large companies and can also be done by students.

By designing my own chip, I gained a much better understanding of how microprocessors work. I had heard before that everything is based on transistors and logic gates, but working on a real logic design helped me understand this much better. Creating my own design made it clearer how chips, computers, and digital systems work at a basic level.
