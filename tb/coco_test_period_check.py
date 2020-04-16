import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess


@cocotb.test()
def period_check_base_test(dut):
    dut.RST <= 0
    dut.PWRDWN <= 0
    period_length = 20
    dut.period_length <= period_length

    clock = Clock(dut.clk, period_length, 'ns')
    cocotb.fork(clock.start())

    yield Timer(10, 'ns')
    dut.RST <= 1
    yield Timer(10, 'ns')

    if (dut.period_stable.value):
        raise TestFailure("FAILED: RST")

    dut.RST <= 0
    yield Timer(period_length * 2, 'ns')

    if (not dut.period_stable.value):
        raise TestFailure("FAILED: period stable")

    period_length = 10
    clock = Clock(dut.clk, period_length, 'ns')
    cocotb.fork(clock.start())
    dut.period_length <= period_length
    yield Timer(period_length / 2, 'ns')

    if (dut.period_stable.value):
        raise TestFailure("FAILED: period unstable")

    yield Timer((period_length / 2), 'ns')

    if (dut.period_stable.value):
        raise TestFailure("FAILED: period still unstable")

    yield Timer(1, 'ns')

    if (not dut.period_stable.value):
        raise TestFailure("FAILED: period stable again")

    dut.PWRDWN <= 1
    yield Timer(10, 'ns')

    if (dut.period_stable.value.binstr != 'x'):
        raise TestFailure("FAILED: PWRDWN")

    raise TestSuccess("All tests successfully ran")
