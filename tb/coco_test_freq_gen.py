import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess
import math


@cocotb.test()
def test_freq_gen(dut,
                  wait_interval=1000,
                  m_1000=1000,
                  d=1,
                  o_1000=1000):
    """
    Actual testbench
    """
    print("START")
    ref_period_length = 20
    dut.ref_period_1000 <= ref_period_length * 1000
    dut.M_1000 <= m_1000
    dut.D <= d
    dut.O_1000 <= o_1000
    dut.RST <= 0
    dut.PWRDWN <= 0
    dut.period_stable <= 0
    cocotb.fork(Clock(dut.clk, ref_period_length, units='ns').start())

    # TEST CASES #
    yield Timer(10, units='ns')
    dut.RST <= 1
    yield Timer(10, units='ns')

    if (dut.out.value == 0):
        raise TestSuccess("PASSED: RST")
    else:
        raise TestFailure("FAILED: RST")

    dut.period_stable <= 1
    dut.RST <= 0
    yield Timer(ref_period_length + 11, units='ns')

    if (dut.out == 1):
        raise TestSuccess("PASSED: rising edge detection")
    else:
        raise TestFailure("FAILED: rising edge detection")

    cocotb.fork(check_period(ref_period_length,
                             d,
                             o_1000,
                             m_1000,
                             dut.clk,
                             wait_interval))


@cocotb.coroutine
def check_period(ref_period_length,
                 d,
                 o_1000,
                 m_1000,
                 clk,
                 wait_interval):
    run = 1
    highs_counted = high_counter(clk, run)
    yield Timer(wait_interval, units='ns')
    run = 0
    highs_expected = ref_period_length * d * (o_1000 / 1000) / (m_1000 / 1000)
    if (math.floor(wait_interval / highs_counted)
            == math.floor(highs_expected)):
        raise TestSuccess("PASSED: ref period = " + ref_period_length)
    else:
        raise TestFailure("FAILED: ref period = " + ref_period_length)


@cocotb.coroutine
def high_counter(clk, run):
    clkedge = RisingEdge(clk)
    count = 0
    while (run):
        yield clkedge
        count += 1
    return count
