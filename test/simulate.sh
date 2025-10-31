#!/usr/bin/env bash

set -e -x

cd $(dirname "$0")

GREEN='\033[1;32m'
NC='\033[0m'

name=$1
RTL=../src
TEST_FOLDER=.

echo -e "${GREEN}Verilator:------------------------------------------ ${NC}"
verilator --lint-only --timing -I"$RTL" "$TEST_FOLDER/${name}_tb.v"

echo -e "${GREEN}IVerilog:------------------------------------------- ${NC}"
iverilog -g2005 -I"$RTL" \
  "$RTL/scoreboard_top.v" \
  "$RTL/pushbutton_processor.v" \
  "$RTL/counter_v2.v" \
  "$RTL/bin_to_decimal.v" \
  "$RTL/dual_7_seg.v" \
  "$TEST_FOLDER/${name}_tb.v"

echo -e "${GREEN}Simulation:----------------------------------------- ${NC}"
./a.out

echo -e "${GREEN}GTKWave:-------------------------------------------- ${NC}"
gtkwave "$TEST_FOLDER/${name}_tb.vcd"

rm -f a.out
echo -e "${GREEN}Fertig!--------------------------------------------- ${NC}"
