# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
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
    # set the RTC_clk to 1kHz 
    RTC_clk = Clock(dut.ui_in[7], 1, units="ms")
    cocotb.start_soon(RTC_clk.start())
     # set the serial_readout_clk to 4MHz 
    serial_readout_clk = Clock(dut.uio_in[7], 250, units="ns")
    cocotb.start_soon(serial_readout_clk.start())


    #set values for channels 
    dut.ui_in[0].value = 0; #ch1(0)
    dut.ui_in[1].value = 0; #ch1(1)
    dut.ui_in[2].value = 0; #ch1(2)
    dut.ui_in[3].value = 0; #ch1(3)
    dut.ui_in[4].value = 0; #ch1(4)
    dut.ui_in[5].value = 0; #ch1(5)
    dut.ui_in[6].value = 0; #ch1(6)
    dut.uio_in[0].value = 0; #ch2(0)
    dut.uio_in[1].value = 0; #ch2(1)
    dut.uio_in[2].value = 0; #ch2(2)
    dut.uio_in[3].value = 0; #ch2(3)
    dut.uio_in[4].value = 0; #ch2(4)
    dut.uio_in[5].value = 0; #ch2(5)
    dut.uio_in[6].value = 0; #ch2(6)

    
    # Wait 1 ms
    await ClockCycles(dut.clk,1000)

    
    #firt input signal
    dut.ui_in[0].value = 1; #ch1(0)
    dut.ui_in[1].value = 1; #ch1(1)
    dut.ui_in[2].value = 1; #ch1(2)
    dut.ui_in[3].value = 1; #ch1(3)
    dut.ui_in[4].value = 0; #ch1(4)
    dut.ui_in[5].value = 0; #ch1(5)
    dut.ui_in[6].value = 0; #ch1(6)
    for i in range(0, 7) :
        dut.uio_in[i].value = 1;
        # Wait 10 us
        await ClockCycles(dut.clk,10)
    for i in range(6, -1, -1) :
        dut.uio_in[i].value = 0;
        # Wait 10 us
        await ClockCycles(dut.clk,10) 
    dut.ui_in[0].value = 0; #ch1(0)
    dut.ui_in[1].value = 0; #ch1(1)
    dut.ui_in[2].value = 0; #ch1(2)
    dut.ui_in[3].value = 0; #ch1(3)
    dut.ui_in[4].value = 0; #ch1(4)
    dut.ui_in[5].value = 0; #ch1(5)
    dut.ui_in[6].value = 0; #ch1(6)

    # Wait to see the overflow
    await ClockCycles(dut.clk,500)

    #second input signal
    dut.ui_in[0].value = 1; #ch1(0)
    dut.ui_in[1].value = 1; #ch1(1)
    dut.ui_in[2].value = 1; #ch1(2)
    dut.ui_in[3].value = 1; #ch1(3)
    dut.ui_in[4].value = 1; #ch1(4)
    dut.ui_in[5].value = 1; #ch1(5)
    dut.ui_in[6].value = 0; #ch1(6)
    for i in range(0, 7) :
        dut.uio_in[i].value = 1;
        # Wait 50 us
        await ClockCycles(dut.clk,50)
    for i in range(6, -1, -1) :
        dut.uio_in[i].value = 0;
        # Wait 50 us
        await ClockCycles(dut.clk,50) 
    dut.ui_in[0].value = 0; #ch1(0)
    dut.ui_in[1].value = 0; #ch1(1)
    dut.ui_in[2].value = 0; #ch1(2)
    dut.ui_in[3].value = 0; #ch1(3)
    dut.ui_in[4].value = 0; #ch1(4)
    dut.ui_in[5].value = 0; #ch1(5)
    dut.ui_in[6].value = 0; #ch1(6)

    # Wait to see the overflow
    await ClockCycles(dut.clk,1000)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    # assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
