import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess


@cocotb.test()
def phase_shift_base_test(dut,
                          wait_interval=1000):
    dut.RST <= 0
    dut.PWRDWN <= 0
    clk_period = 36
    dut.clk_period_1000 <= clk_period * 1000

    clock_thread = cocotb.fork(Clock(dut.clk, clk_period, 'ns').start())

    shift = 10
    dut.shift_1000 <= shift * 1000
    dut.duty_cycle <= 50

    yield Timer(10, 'ns')

    if (dut.lock.value.binstr != 'x'):
        raise TestFailure('FAILED: lock should not be set before'
                          + ' first reset')

    dut.RST <= 1
    yield Timer(10, 'ns')

    if (dut.clk_shifted.value or dut.lock.value):
        raise TestFailure('FAILED: RST')

    dut.RST <= 0
    yield Timer(wait_interval, 'ns')

    # check phase shift
    shift_fail = 0
    yield phase_shift_check(dut, wait_interval, shift_fail)

    if (shift_fail or not dut.lock.value):
        print(shift_fail)
        print(dut.lock.value)
        raise TestFailure('FAILED: shift = 10°')

    shift = 182
    dut.shift_1000 <= shift * 1000
    yield Timer(wait_interval, 'ns')
    yield phase_shift_check(dut, wait_interval, shift_fail)

    if (shift_fail or not dut.lock.value):
        raise TestFailure('FAILED: shift = 182°')

    shift = 181
    dut.shift_1000 <= shift * 1000
    yield Timer(wait_interval, 'ns')
    yield phase_shift_check(dut, wait_interval, shift_fail)

    if (shift_fail or not dut.lock.value):
        raise TestFailure('FAILED: shift = 181°')

    shift = 180
    dut.shift_1000 <= shift * 1000
    yield Timer(wait_interval, 'ns')
    yield phase_shift_check(dut, wait_interval, shift_fail)

    if (shift_fail or not dut.lock.value):
        raise TestFailure('FAILED: shift = 180°')

    shift = 360
    dut.shift_1000 <= shift * 1000
    yield Timer(wait_interval, 'ns')
    yield phase_shift_check(dut, wait_interval, shift_fail)

    if (shift_fail or not dut.lock.value):
        raise TestFailure('FAILED: shift = 360°')

    shift = -10
    dut.shift_1000 <= shift * 1000
    yield Timer(wait_interval, 'ns')
    yield phase_shift_check(dut, wait_interval, shift_fail)

    if (shift_fail or not dut.lock.value):
        raise TestFailure('FAILED: shift = -10°')

    clk_period = 1
    dut.clk_period_1000 <= clk_period * 1000

    clock_thread.kill()
    clock_thread = cocotb.fork(Clock(dut.clk, clk_period, 'ns').start())
    shift = 0
    dut.shift_1000 <= shift
    yield Timer(wait_interval, 'ns')
    yield phase_shift_check(dut, wait_interval, shift_fail)
    raise TestSuccess('All tests ran successfully')

    if (shift_fail or not dut.lock.value):
        raise TestFailure('FAILED: shift = 0°, clk period = 1')

    print('Am I here?')
    clk_period = 50
    dut.clk_period_1000 <= clk_period * 1000
    clock_thread.kill()
    clock_thread = cocotb.fork(Clock(dut.clk, clk_period, 'ns').start())

    duty_cycle_fail = 0
    dut.duty_cycle <= 1
    yield Timer(wait_interval, 'ns')
    yield duty_cycle_check(dut, wait_interval, duty_cycle_check)

    if (duty_cycle_fail or not dut.lock.value):
        raise TestFailure('FAILED: duty cycle = 1%')

    dut.duty_cycle <= 10
    yield Timer(wait_interval, 'ns')
    yield duty_cycle_check(dut, wait_interval, duty_cycle_check)

    if (duty_cycle_fail or not dut.lock.value):
        raise TestFailure('FAILED: duty cycle = 10%')

    dut.duty_cycle <= 49
    yield Timer(wait_interval, 'ns')
    yield duty_cycle_check(dut, wait_interval, duty_cycle_check)

    if (duty_cycle_fail or not dut.lock.value):
        raise TestFailure('FAILED: duty cycle = 49%')

    dut.duty_cycle <= 50
    yield Timer(wait_interval, 'ns')
    yield duty_cycle_check(dut, wait_interval, duty_cycle_check)

    if (duty_cycle_fail or not dut.lock.value):
        raise TestFailure('FAILED: duty cycle = 50%')

    dut.duty_cycle <= 51
    yield Timer(wait_interval, 'ns')
    yield duty_cycle_check(dut, wait_interval, duty_cycle_check)

    if (duty_cycle_fail or not dut.lock.value):
        raise TestFailure('FAILED: duty cycle = 51%')

    dut.duty_cycle <= 90
    yield Timer(wait_interval, 'ns')
    yield duty_cycle_check(dut, wait_interval, duty_cycle_check)

    if (duty_cycle_fail or not dut.lock.value):
        raise TestFailure('FAILED: duty cycle = 90%')

    dut.duty_cycle <= 99
    yield Timer(wait_interval, 'ns')
    yield duty_cycle_check(dut, wait_interval, duty_cycle_check)

    if (duty_cycle_fail or not dut.lock.value):
        raise TestFailure('FAILED: duty cycle = 99%')

    dut.PWRDWN <= 1
    yield Timer((clk_period / 2) + 1)

    if (dut.clk_shifted.value.binstr != 'x' or dut.lock.value.binstr != 'x'):
        raise TestFailure('FAILED: PWRDWN')

    raise TestSuccess('All tests ran successfully')


@cocotb.coroutine
def phase_shift_check(dut, wait_interval, shift_fail):
    clk_period = int(dut.clk_period_1000.value) / 1000
    shift = int(dut.shift_1000.value) / 1000
    run_time = 0
    shift_fail = 0
    while (run_time < wait_interval):
        yield RisingEdge(dut.clk)
        if (shift > 0):
            run_time += clk_period
            yield Timer(round(shift * (clk_period / 360) - 0.5, 3), 'ns')
            if (dut.clk_shifted.value):
                shift_fail = 1
        else:
            run_time += 2 * clk_period
            yield Timer(clk_period + shift * (clk_period / 360) - 0.5, 'ns')
            if (dut.clk_shifted.value):
                shift_fail = 1
        yield Timer(1, 'ns')
        if (not dut.clk_shifted.value):
            shift_fail = 1
    return shift_fail


@cocotb.coroutine
def duty_cycle_check(dut, wait_interval, duty_cycle_fail):
    clk_period = int(dut.clk_period_1000.value) / 1000
    duty_cycle = int(dut.duty_cycle.value)
    run_time = 0
    duty_cycle_fail = 0
    while (run_time < wait_interval):
        yield RisingEdge(dut.clk)
        run_time += clk_period
        yield Timer(clk_period * (duty_cycle / 100) - 0.5, 'ns')
        if (not dut.clk.value):
            duty_cycle_fail = 1
        yield Timer(1, 'ns')
        if (dut.clk.value):
            duty_cycle_fail = 1
    return duty_cycle_fail
