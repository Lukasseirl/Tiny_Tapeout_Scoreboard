#!/usr/bin/env bash

set -e -x

cd $(dirname "$0")

GREEN='\033[1;32m'
NC='\033[0m'

name=$1
RTL=../src
TEST_FOLDER=.

echo -e "${GREEN}Verilator:------------------------------------------ ${NC}"
verilator --lint-only -I"$RTL" "$TEST_FOLDER/${name}_tb.v"

echo -e "${GREEN}IVerilog:------------------------------------------- ${NC}"
iverilog -g2005 -I"$RTL" \
  "$RTL/tt_um_scoreboard_simple_top.v" \
  "$RTL/scoreboard_simple_controller.v" \
  "$RTL/display_simple_controller.v" \
  "$RTL/button_debouncer.v" \
  "$RTL/long_press_detector.v" \
  "$RTL/seven_segment_decoder.v" \
  "$TEST_FOLDER/${name}_tb.v"

echo -e "${GREEN}Simulation:----------------------------------------- ${NC}"
./a.out

echo -e "${GREEN}GTKWave:-------------------------------------------- ${NC}"
gtkwave "$TEST_FOLDER/${name}_tb.vcd"

rm -f a.out
echo -e "${GREEN}Fertig!--------------------------------------------- ${NC}"
