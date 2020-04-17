import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess


@cocotb.test()
def period_count_base_test(dut,
                           wait_interval=100):
    dut.RST <= 0
    dut.PWRDWN <= 0
    clk_period = 10
    clock = Clock(dut.clk, clk_period, units='ns')
    clock_thread = cocotb.fork(clock.start())

    yield Timer(10, 'ns')
    dut.RST <= 1
    yield Timer(10, 'ns')

    if (dut.period_length_1000.value != 0):
        raise TestFailure("FAILED: RST")

    dut.RST <= 0
    yield Timer(wait_interval, 'ns')

    if (dut.period_length_1000.value != clk_period * 1000):
        raise TestFailure("FAILED: period = 10")

    clock_thread.kill()
    clk_period = 13
    clock = Clock(dut.clk, clk_period, 'ns')
    clock_thread = cocotb.fork(clock.start())
    yield Timer(wait_interval, 'ns')

    if (dut.period_length_1000.value != clk_period * 1000):
        print(dut.period_length_1000.value.integer)
        raise TestFailure("FAILED: period = 13")

    clock_thread.kill()
    clk_period = 1
    clock = Clock(dut.clk, clk_period, 'ns')
    clock_thread = cocotb.fork(clock.start())
    yield Timer(wait_interval, 'ns')

    if (dut.period_length_1000.value != clk_period * 1000):
        raise TestFailure("FAILED: period = 1")

    clock_thread.kill()
    clk_period = wait_interval / 2
    clock = Clock(dut.clk, clk_period, 'ns')
    clock_thread = cocotb.fork(clock.start())
    yield Timer(wait_interval, 'ns')

    if (dut.period_length_1000.value != wait_interval * 1000 / 2):
        raise TestFailure("FAILED: period = {}".format(wait_interval / 2))

    raise TestSuccess("All tests successfully ran.")
