#!/usr/bin/env bash

set -e -x

cd $(dirname "$0")

GREEN='\033[1;32m'
NC='\033[0m'

name=$1
RTL=../src
TEST_FOLDER=.

echo -e "${GREEN}Verilator:------------------------------------------ ${NC}"
verilator --lint-only --timing -I"$RTL" "$TEST_FOLDER/${name}.v"

echo -e "${GREEN}IVerilog:------------------------------------------- ${NC}"
# Nur die Testbench kompilieren - sie bindet alle anderen Module automatisch ein
iverilog -g2005 -I"$RTL" "$TEST_FOLDER/${name}_tb.v"

echo -e "${GREEN}Simulation:----------------------------------------- ${NC}"
./a.out

echo -e "${GREEN}GTKWave:-------------------------------------------- ${NC}"
gtkwave "$TEST_FOLDER/${name}_tb.vcd"

rm -f a.out
echo -e "${GREEN}Fertig!--------------------------------------------- ${NC}"
