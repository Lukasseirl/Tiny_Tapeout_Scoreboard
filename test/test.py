# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 1000, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 8'b00000001    // set ui_in[0] = 1 to simulate a pushbutton-press
    await ClockCycles(dut.clk, 50)    // hold press for 50 ms so that it gets through the debounce
    dut.ui_in.value = 8'b00000000    
    
    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)   // after about 3 seconds the display should show the the score of player 1 which should be 01 after the first button press

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out.value == 8'00111111b      // ones should show 0 at 7seg display
    assert dut.uio_out.value == 8'00000110b    // tens should show 1 at 7seg display

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
