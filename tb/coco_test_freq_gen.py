import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess
from cocotb.regression import TestFactory

import math


def freq_gen_model(m, d, o, ref_period_length):
    return ref_period_length * ((d * o) / m)


@cocotb.test()
def freq_gen_test_rst(dut):
    """
    Testing behaviour on RST
    """
    ref_period = 10
    dut.ref_period_1000 <= ref_period * 1000
    dut.RST <= 0
    cocotb.fork(Clock(dut.clk, ref_period, units='ns').start())
    yield Timer(10, 'ns')
    dut.RST <= 1
    yield Timer(10, 'ns')

    if (dut.out.value == 0):
        raise TestSuccess("PASSED: RST")
    else:
        raise TestFailure("FAILED: RST")


@cocotb.test()
def freq_gen_rising_edge_test(dut):
    """
    Testing rising edge detection
    """
    ref_period = 20
    dut.ref_period_1000 <= ref_period * 1000
    dut.RST <= 0
    dut.PWRDWN <= 0
    dut.period_stable <= 0
    dut.M_1000 <= 1000
    dut.D <= 1
    dut.O_1000 <= 1000
    cocotb.fork(Clock(dut.clk, ref_period, units='ns').start())

    yield Timer(10, 'ns')
    dut.RST <= 1
    yield Timer(10, 'ns')

    dut.period_stable <= 1
    dut.RST <= 0
    yield Timer(ref_period + 1, 'ns')

    if (dut.out == 1):
        raise TestSuccess("PASSED: rising edge detection")
    else:
        raise TestFailure("FAILED: rising edge detection")


@cocotb.coroutine
def freq_gen_base_test(dut,
                       m_1000=1000,
                       d=1,
                       o_1000=1000,
                       ref_period=20):
    dut.M_1000 <= m_1000
    dut.D <= d
    dut.O_1000 <= o_1000
    dut.ref_period_1000 <= int(ref_period * 1000)
    cocotb.fork(Clock(dut.clk, ref_period, units='ns').start())

    dut.RST <= 0
    dut.PWRDWN <= 0
    dut.period_stable <= 0

    yield Timer(ref_period, 'ns')
    dut.RST <= 1
    yield Timer(ref_period, 'ns')

    dut.period_stable <= 1
    dut.RST <= 0

    yield RisingEdge(dut.out)

    measured_period = -0.001
    while(dut.out.value):
        measured_period += 0.001
        yield Timer(1, 'ps')
    while(not dut.out.value):
        measured_period += 0.001
        yield Timer(1, 'ps')

    expected_period = freq_gen_model(m_1000 / 1000,
                                     d,
                                     o_1000 / 1000,
                                     ref_period)

    test_configuration = "M_1000: {} \
                         D: {} \
                         O_1000: {} \
                         ref_period_1000: {}".format(m_1000,
                                                     d,
                                                     o_1000,
                                                     ref_period * 1000)

    if (not math.isclose(measured_period,
                         expected_period,
                         rel_tol=1e-3)):
        print("measured: {} expected: {}".
              format(measured_period, expected_period))
        raise TestFailure("FAILED: correct output frequency using "
                          + test_configuration)

    if (not math.isclose(measured_period * 1000,
                         dut.out_period_length_1000.value,
                         rel_tol=1e-3)):
        print("measured: {} calculated: {}".
              format(measured_period * 1000, dut.out_period_length_1000.value))
        raise TestFailure(
            "FAILED: correct correct output frequency calculated "
            + test_configuration)

    raise TestSuccess("All tests successful")


tf = TestFactory(test_function=freq_gen_base_test)
tf.add_option('m_1000', [1000, 8800])
tf.add_option('d', [1, 5])
tf.add_option('o_1000', [1000, 6150])
tf.add_option('ref_period', [20, 5.6])
tf.generate_tests()
