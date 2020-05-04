import cocotb
from cocotb.triggers import Timer, RisingEdge, Join
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess


@cocotb.test()
def plle2_base_test(dut,
                    wait_interval=1000,
                    daddr1=0x08,
                    daddr2=0x09,
                    di1=0b0110000110000011,
                    di2=0b0000000000000011,
                    dclk_period=2):
    # wait for module to forward macro inputs to module outputs
    yield Timer(1, 'ns')
    clkin1_period = dut.CLKIN1_PERIOD_1000.value.integer / 1000
    clkin2_period = dut.CLKIN2_PERIOD_1000.value.integer / 1000
    cocotb.fork(Clock(dut.CLKIN1, clkin1_period, 'ns').start())
    cocotb.fork(Clock(dut.CLKIN2, clkin2_period, 'ns').start())
    cocotb.fork(Clock(dut.DCLK, dclk_period, 'ns').start())
    dut.RST <= 0
    dut.PWRDWN <= 0
    dut.CLKINSEL <= 0

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

    CLKOUT_DUTY_CYCLE_1000 = [dut.CLKOUT0_DUTY_CYCLE_1000,
                              dut.CLKOUT1_DUTY_CYCLE_1000,
                              dut.CLKOUT2_DUTY_CYCLE_1000,
                              dut.CLKOUT3_DUTY_CYCLE_1000,
                              dut.CLKOUT4_DUTY_CYCLE_1000,
                              dut.CLKOUT5_DUTY_CYCLE_1000,
                              500]

    CLKOUT_PHASE_1000 = [dut.CLKOUT0_PHASE_1000,
                         dut.CLKOUT1_PHASE_1000,
                         dut.CLKOUT2_PHASE_1000,
                         dut.CLKOUT3_PHASE_1000,
                         dut.CLKOUT4_PHASE_1000,
                         dut.CLKOUT5_PHASE_1000,
                         dut.CLKFBOUT_PHASE_1000]

    dut.DADDR <= 0x00
    dut.DI <= 0x0000
    dut.DEN <= 0
    dut.DWE <= 0

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

    measure_thread = cocotb.fork(period_count(dut.CLKFBOUT))
    measured_period = yield Join(measure_thread)
    expected_period = period_model(clkin2_period,
                                   dut.DIVCLK_DIVIDE.value,
                                   dut.CLKFBOUT_MULT.value,
                                   CLKOUT_DIVIDE[6])
    if (measured_period[0] != expected_period):
        raise TestFailure('FAILED: CLKIN2 selection')

    dut.CLKINSEL <= 1
    yield Timer(clkin1_period * 2, 'ns')

    measure_thread = [[], []]
    for i in range(0, (len(CLKOUT) - 1)):
        measure_thread[0].append(cocotb.fork(period_count(CLKOUT[i])))
        if (i != 6):
            measure_thread[1].append(
                cocotb.fork(
                    phase_shift_check(CLKOUT[6],
                                      CLKOUT[i],
                                      period_model(clkin1_period,
                                                   dut.DIVCLK_DIVIDE.value,
                                                   dut.CLKFBOUT_MULT.value,
                                                   CLKOUT_DIVIDE[i].value),
                                      int(CLKOUT_PHASE_1000[i].value)
                                      / 1000,
                                      wait_interval)))
        else:
            measure_thread[1].append(
                cocotb.fork(
                    phase_shift_check(dut.CLKIN1,
                                      CLKOUT[i],
                                      clkin1_period,
                                      int(dut.CLKFBOUT_PHASE_1000.value)
                                      / 1000,
                                      wait_interval)))

    for i in range(0, (len(CLKOUT) - 1)):
        expected_period = period_model(clkin1_period,
                                       dut.DIVCLK_DIVIDE.value,
                                       dut.CLKFBOUT_MULT.value,
                                       CLKOUT_DIVIDE[i].value)
        expected_duty_cycle = CLKOUT_DUTY_CYCLE_1000[i].value.integer / 1000
        measurement = yield Join(measure_thread[0][i])
        measured_period = measurement[0]
        measured_duty_cycle = measurement[1]
        if (expected_period != measured_period and i != 6):
            raise TestFailure('FAILED: CLKOUT{} period'.format(i))
        elif (expected_period != measured_period):
            raise TestFailure('FAILED: CLKFBOUT period')
        if (expected_duty_cycle != measured_duty_cycle and i != 6):
            raise TestFailure('FAILED: CLKOUT{} duty cycle'.format(i))

    for i in range(0, (len(CLKOUT) - 1)):
        fail = yield Join(measure_thread[1][i])
        if (fail and i != 6):
            raise TestFailure('FAILED: CLKOUT{} phase'.format(i))
        elif (fail):
            raise TestFailure('FAILED CLKFBOUT phase')

    # TODO: test dynamic reconfiguration.
    #       The basic structure is implemented below
    """
    dut.DADDR <= daddr1
    dut.DI <= di1
    dut.DEN <= 1
    dut.DWE <= 1

    yield Timer(dclk_period, 'ns')

    if (DRDY != 0):
        raise TestFailure('FAILED: DRDY low')

    dut.DWE = 0
    dut.WEN = 0
    yield Timer(dclk_period * 2, 'ns')

    dut.DEN <= 1
    yield Timer(dclk_period * 2, 'ns')

    if (dut.DO.value != dut.DI.value):
        raise TestFailure('FAILED: DO')

    dut.DEN <= 0
    yield Timer(dclk_period * 2, 'ns')
    dut.DADDR <= daddr2
    dut.DI <= di2
    dut.DEN <= 1
    dut.DWE <= 1
    yield Timer(dclk_period * 2, 'ns')
    dut.DEN <= 0
    dut.DWE <= 0
    yield Timer(dclk_period * 2, 'ns')
    """

    dut.PWRDWN <= 1

    if (CLKOUT[0].value.binstr
            == CLKOUT[1].value.binstr
            == CLKOUT[2].value.binstr
            == CLKOUT[3].value.binstr
            == CLKOUT[4].value.binstr
            == CLKOUT[5].value.binstr
            == CLKOUT[6].value.binstr
            == dut.LOCKED.value.binstr
            == 'x'):
        raise TestFailure('FAILED: PWRDWN')


def period_model(clk_period,
                 divclk_divide=1,
                 clkfbout_mult=1,
                 clkout_divide=1):
    period = clk_period * ((divclk_divide * clkout_divide)
                           / clkfbout_mult.integer)
    return period


@cocotb.coroutine
def period_count(signal, resolution=0.01):
    period_count_high = -resolution
    period_count_low = 0
    yield RisingEdge(signal)
    while(signal.value):
        period_count_high += resolution
        yield Timer(resolution, 'ns')
    while(not signal.value):
        period_count_low += resolution
        yield Timer(resolution, 'ns')
    period_count = period_count_high + period_count_low
    duty_cycle = period_count_high / period_count
    return [round(period_count, 3), round(duty_cycle, 3)]


@cocotb.coroutine
def phase_shift_check(ref_signal, signal, clk_period, shift, run_length):
    run_time = 0
    fail = 0
    while (run_time < run_length):
        yield RisingEdge(ref_signal)
        if (shift > 0):
            run_time += clk_period
            yield Timer(round(shift * (clk_period / 360) - 0.1, 3), 'ns')
            if (signal.value):
                fail = 1
        else:
            run_time += 2 * clk_period
            yield Timer(round(clk_period + shift * (clk_period / 360) - 0.1),
                        'ns')
            if (signal.value):
                fail = 1
        yield Timer(0.2, 'ns')
        if (not signal.value):
            fail = 1
    return fail
