# Tiny Tapeout Scoreboard

## Introduction

The Tiny Tapeout Scoreboard chip processes the input of two pushbuttons and controls two 7 segment displays. The purpose is to count and show a game score of two players. With the two pushbuttons you are able to set the points - button 1 is for player 1 and button 2 for player 2. A short press adds one point to the count, a long press (at least 1.5 seconds) decreases the score by 1. The two digit score of each player is then presented via two 7-segment displays wich alternate between the score of player 1 and player 2. Therefore the scoreboard blinks 2 times with the text 'P1' or 'P2' and after the blinking the respective score of each player is shown for 2 seconds.

Furthermore, there is a pushbutton-processor that, not only recognises a long press of a push buthon, but has an debounce logic so that a single pushbutton press increases the score just by one - even if the button is bouncing. Also the score is limited to 00-99 - so if your score is 99 and you push the button, nothing will happen and the score stays at 99.

## Hardware

The screenshot below shows the required hardware for the project. For the user inputs we use two pushbuttons with a pullup resistor which are connected to the tiny tapeout board at IN0 and IN1. For the representation of the score we use two 7-segment display. To control them we use 7 of the 8 output pins and additionally use the bidirectional pins as output. 

Our tiny tapeout chip is the heart of the hardware and processes the button presses and controlls the 7-segment displays.

<img width="2468" height="1024" alt="grafik" src="https://github.com/user-attachments/assets/496a0537-259a-49d0-8b90-d642fc3afa7f" />

## Structure of the Modules

The project consists of several modules. The general structure of the modules can be seen in the screenshot below. 

<img width="1359" height="424" alt="grafik" src="https://github.com/user-attachments/assets/ac7c8c91-59c5-4f75-a638-3c5ba374a46f" />
