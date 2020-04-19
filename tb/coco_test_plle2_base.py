import cocotb
from cocotb.triggers import Timer, RisingEdge, Join
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess


@cocotb.test()
def plle2_base_test(dut, wait_interval = 1000, clkin1_period = 5):
    cocotb.fork(Clock(dut.CLKIN1, clkin1_period, 'ns').start())
    dut.RST <= 0
    dut.PWRDWN <= 0

    CLKOUT = [dut.CLKOUT0,
              dut.CLKOUT1,
              dut.CLKOUT2,
              dut.CLKOUT3,
              dut.CLKOUT4,
              dut.CLKOUT5,
              dut.CLKFBOUT]

    CLKOUT_DIVIDE = [dut.CLKOUT0_DIVIDE,
                     dut.CLKOUT1_DIVIDE,
                     dut.CLKOUT2_DIVIDE,
                     dut.CLKOUT3_DIVIDE,
                     dut.CLKOUT4_DIVIDE,
                     dut.CLKOUT5_DIVIDE,
                     1]

    yield Timer(10, 'ns')
    dut.RST <= 1
    yield Timer(10, 'ns')

    if (dut.CLKOUT0.value
            or dut.CLKOUT1.value
            or dut.CLKOUT2.value
            or dut.CLKOUT3.value
            or dut.CLKOUT4.value
            or dut.CLKOUT5.value
            or dut.CLKFBOUT.value
            or dut.LOCKED.value):
        raise TestFailure('FAILED: RST')

    dut.RST <= 0
    yield Timer(wait_interval, 'ns')

    if (not dut.LOCKED.value):
        raise TestFailure('FAILED: LOCKED')

    measure_thread = []
    for i in range(0, (len(CLKOUT) - 1)):
        measure_thread.append(cocotb.fork(period_count(CLKOUT[i])))

    for i in range(0, (len(CLKOUT) - 1)):
        expected_period = period_model(clkin1_period,
                                       dut.DIVCLK_DIVIDE.value,
                                       dut.CLKFBOUT_MULT.value,
                                       CLKOUT_DIVIDE[i].value)
        measured_period = yield Join(measure_thread[i])
        if (expected_period != measured_period and i != 6):
            raise TestFailure('FAILED: CLKOUT{} period'.format(i))
        elif (expected_period != measured_period):
            raise TestFailure('FAILED: CLKFBOUT period')


def period_model(clk_period,
                 divclk_divide=1,
                 clkfbout_mult=1,
                 clkout_divide=1):
    period = clk_period * ((divclk_divide.integer * clkout_divide.integer)
                            / clkfbout_mult.integer)
    return period


@cocotb.coroutine
def period_count(signal, resolution=0.01):
    period_count = -resolution
    yield RisingEdge(signal)
    while(signal.value):
        period_count += resolution
        yield Timer(resolution, 'ns')
    while(not signal.value):
        period_count += resolution
        yield Timer(resolution, 'ns')
    return round(period_count, 3)
