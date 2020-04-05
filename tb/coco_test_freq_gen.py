import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess
from cocotb.scoreboard import Scoreboard


#class FreqGenTB(object):
#    """
#    test freq_gen.v
#    """
#    def __init__(self, dut):
#        self.dut = dut
#        self.scoreboard = Scoreboard(dut)


#@cocotb.test()
#def test_freq_gen(dut):
#    """
#    test cases
#    """
#    print("Running test!")
#    yield run_test(dut)
#    print("Ran test!")

@cocotb.test()
def test_freq_gen(dut,
             wait_interval=1000,
             m_1000=1000,
             d=1,
             o_1000=1000):
    """
    Actual testbench
    """
    ref_period_length = 20
    dut.ref_period_1000 <= ref_period_length * 1000
    dut.M_1000 <= m_1000
    dut.D <= d
    dut.O_1000 <= o_1000
    dut.RST <= 0
    dut.PWRDWN <= 0
    dut.period_stable <= 0
    cocotb.fork(Clock(dut.clk, ref_period_length, 'ns').start())

    yield Timer(10, units='ns')
    dut.RST <= 1
    yield Timer(10, units='ns')

    if (dut.out.value != 0):
        raise TestFailure("FAILED: RST")
    else:
        raise TestSuccess("PASSED: RST")
