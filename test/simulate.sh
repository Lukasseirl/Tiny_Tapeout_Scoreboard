#!/usr/bin/env bash

# =====================================================
# Author: Simon Dorrer  
# Last Modified: 02.10.2025
# Description: Adapted for scoreboard testbench
# =====================================================

set -e -x

cd $(dirname "$0")

GREEN='\033[1;32m'
NC='\033[0m'

name=$1

RTL=${RTL:-../src}           # Source files location
TEST_FOLDER=${TEST_FOLDER:-.} # Testbench location

echo -e "${GREEN}Verilator:------------------------------------------ ${NC}"
verilator --lint-only -I"$RTL" "$TEST_FOLDER"/"$name"_tb.v

echo -e "${GREEN}IVerilog:------------------------------------------- ${NC}"
# Kompiliert alle notwendigen Files
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
if [ -e "$TEST_FOLDER"/"$name"_tb.gtkw ]
then
  gtkwave "$TEST_FOLDER"/"$name"_tb.gtkw
else
  gtkwave "$TEST_FOLDER"/"$name"_tb.vcd
fi

# Clean
rm -f a.out
# rm -f *.vcd

echo -e "${GREEN}Generated files were removed------------------------ ${NC}"
