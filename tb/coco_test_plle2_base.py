import cocotb
from cocotb.triggers import Timer, RisingEdge, Join
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess


@cocotb.test()
def plle2_base_test(dut, wait_interval=1000, clkin1_period=5):
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

    measure_thread = [[], []]
    for i in range(0, (len(CLKOUT) - 1)):
        print('start thread {}'.format(i))
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
            raise TestFailure('FAILED: CLKOUT{} period'.format(i))

    for i in range(0, (len(CLKOUT) - 1)):
        print('Phase Shift')
        fail = yield Join(measure_thread[1][i])
        print('Joined Thread Nr. {}'.format(i))
        if (fail and i != 6):
            raise TestFailure('FAILED: CLKOUT{} phase'.format(i))
        elif (fail):
            raise TestFailure('FAILED CLKFBOUT phase')

    dut.PWRDWN <= 1


def period_model(clk_period,
                 divclk_divide=1,
                 clkfbout_mult=1,
                 clkout_divide=1):
    period = clk_period * ((divclk_divide.integer * clkout_divide.integer)
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
            yield Timer(round(shift * (clk_period / 360) - 0.5, 3), 'ns')
            if (signal.value):
                fail = 1
        else:
            run_time += 2 * clk_period
            yield Timer(round(clk_period + shift * (clk_period / 360) - 0.5),
                        'ns')
            if (signal.value):
                fail = 1
        yield Timer(1, 'ns')
        if (not signal.value):
            fail = 1
    return fail
