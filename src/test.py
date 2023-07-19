import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# True for gatelevel simulation
GL_TEST = ('GL_TEST' in os.environ and os.environ['GL_TEST'] != 'false') or ('GATES' in os.environ and os.environ['GATES'] != 'no')


segments = [ 63, 6, 91, 79, 102, 109, 124, 7, 127, 103 ]

@cocotb.test()
async def test_7seg(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    dut._log.info("reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # We use 1000 to speed up simulation
    CYCLES_PER_SEGMENT = 10_000_000 if(GL_TEST) else 1000

    dut._log.info("check all segments")
    for i in range(10):
        dut._log.info("check segment {}".format(i))
        await ClockCycles(dut.clk, CYCLES_PER_SEGMENT)
        assert int(dut.segments.value) == segments[i]

        # all bidirectionals are set to output
        assert dut.uio_oe == 0xFF
