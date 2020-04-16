import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.result import TestFailure, TestSuccess
from cocotb.regression import TestFactory


@cocotb.test()
def dyn_reconf_base_test(dut, clk_period=10):
    cocotb.fork(Clock(dut.DCLK, clk_period, units='ns').start())

    vco_period = 32
    dut.vco_period_1000 <= vco_period * 1000
    dut.RST <= 0
    dut.DADDR <= 0x00
    dut.DEN <= 0
    dut.DWE <= 0
    dut.DI <= 0x0000

    yield Timer(clk_period * 2, 'ns')
    dut.RST <= 1
    yield Timer(clk_period * 2, 'ns')

    if (dut.DO != 0x0000 or not dut.DRDY):
        raise TestFailure("FAILED: RST")

    dut.RST <= 0
    yield Timer(clk_period * 2, 'ns')

    if (not dut.DRDY.value):
        raise TestFailure("FAILED: release RST")

    # ClkReg1/2 for CLKOUT0
    dut.DADDR <= 0x08
    dut.DEN <= 1
    dut.DWE <= 1

    # PHASE MUX: 3
    # RESERVED: 0
    # HIGH TIME: 6
    # LOW TIME: 3
    dut.DI <= 0b0110000110000011

    yield Timer(clk_period * 2, 'ns')
    if (dut.DRDY.value):
        raise TestFailure("FAILED: DRDY")

    dut.DEN <= 0
    dut.DWE <= 0

    yield Timer(clk_period * 2, 'ns')
    if (not dut.DRDY):
        raise TestFailure("FAILED: DEN and DWE")

    dut.DEN <= 1
    yield Timer(clk_period * 2, 'ns')

    if (dut.DRDY.value or (dut.DO.value != 0b0110000110000011)):
        raise TestFailure("FAILED: DI and DO")
    if (dut.CLKOUT0_DIVIDE.value != 9):
        raise TestFailure("FAILED: CLKOUT0 ClkReg1 DIVIDE calculation")

    duty_cycle = round((6 * 1000) / (6 + 3))

    if (dut.CLKOUT0_DUTY_CYCLE_1000.value != duty_cycle):
        raise TestFailure("FAILED: CLKOUT0 ClkReg1 DUTY_CYCLE calculation")
    if (dut.CLKOUT0_PHASE.value != ((vco_period / 8) * 3)):
        raise TestFailure("FAILED: CLKOUT0 ClkReg1 PHASE calculation")

    dut.DEN <= 0
    yield Timer(clk_period * 2, 'ns')

    # RESERVED: 0
    # FRAC: 000
    # FRAC_EN: 0
    # FRAC_WF_R: 0
    # MX: 00
    # EDGE: 0
    # NO COUNT: 1
    # DELAY TIME: 3
    yield write_value(dut, 0x09, 0b0000000001000011, clk_period)

    if (dut.CLKOUT0_DIVIDE.value != 1):
        raise TestFailure("FAILED: CLKOUT0 ClkReg2 DIVIDE calculation")
    if (dut.CLKOUT0_DUTY_CYCLE_1000.value != 500):
        raise TestFailure("FAILED: CLKOUT0 ClkReg2 DUTY_CYCLE calculation")
    if (dut.CLKOUT0_PHASE.value != ((vco_period / 8) * 3) + (vco_period * 3)):
        raise TestFailure("FAILED: CLKOUT0 ClkReg2 PHASE calculation")

    # CLKOUT1
    # PHASE MUX: 3
    # RESERVED: 0
    # HIGH TIME: 6
    # LOW TIME: 3
    yield write_value(dut, 0x0A, 0b0110000110000011, clk_period)

    if (dut.CLKOUT1_DIVIDE.value != 9):
        raise TestFailure("FAILED: CLKOUT1 ClkReg1 DIVIDE calculation")
    if (dut.CLKOUT1_DUTY_CYCLE_1000.value != duty_cycle):
        raise TestFailure("FAILED: CLKOUT1 ClkReg1 DUTY_CYCLE calculation")
    if (dut.CLKOUT1_PHASE != ((vco_period / 8) * 3)):
        raise TestFailure("FAILED: CLKOUT1 ClkReg1 PHASE calculation")

    # RESERVED: 000000
    # MX: 00
    # EDGE: 0
    # NO COUNT: 1
    # DELAY TIME: 3
    yield write_value(dut, 0x0B, 0b0000000001000011, clk_period)

    if (dut.CLKOUT1_DIVIDE.value != 1):
        raise TestFailure("FAILED: CLKOUT1 ClkReg2 DIVIDE calculation")
    if (dut.CLKOUT1_DUTY_CYCLE_1000.value != 500):
        raise TestFailure("FAILED: CLKOUT1 ClkReg2 DUTY_CYCLE calculation")
    if (dut.CLKOUT1_PHASE.value != ((vco_period / 8) * 3) + (vco_period * 3)):
        raise TestFailure("FAILED: CLKOUT1 ClkReg2 PHASE calculation")

    # CLKOUT5
    # PHASE MUX: 3
    # RESERVED: 0
    # HIGH TIME: 6
    # LOW TIME: 3
    yield write_value(dut, 0x06, 0b0110000110000011, clk_period)

    if (dut.CLKOUT5_DIVIDE.value != 9):
        raise TestFailure("FAILED: CLKOUT5 ClkReg1 DIVIDE calculation")
    if (dut.CLKOUT5_DUTY_CYCLE_1000.value != duty_cycle):
        raise TestFailure("FAILED: CLKOUT5 ClkReg1 DUTY_CYCLE calculation")
    if (dut.CLKOUT5_PHASE != ((vco_period / 8) * 3)):
        raise TestFailure("FAILED: CLKOUT5 ClkReg1 PHASE calculation")

    # RESERVED: 00
    # PHASE_MUX_F_CLKOUT0: 000
    # FRAC_WF_F_CLKOUT0: 0
    # MX: 00
    # EDGE: 0
    # NO COUNT: 1
    # DELAY TIME: 3
    yield write_value(dut, 0x07, 0b0000000001000011, clk_period)

    if (dut.CLKOUT5_DIVIDE.value != 1):
        raise TestFailure("FAILED: CLKOUT5 ClkReg2 DIVIDE calculation")
    if (dut.CLKOUT5_DUTY_CYCLE_1000.value != 500):
        raise TestFailure("FAILED: CLKOUT5 ClkReg2 DUTY_CYCLE calculation")
    if (dut.CLKOUT5_PHASE.value != ((vco_period / 8) * 3) + (vco_period * 3)):
        raise TestFailure("FAILED: CLKOUT5 ClkReg2 PHASE calculation")

    # CLKFBOUT
    # PHASE MUX: 3
    # RESERVED: 0
    # HIGH TIME: 6
    # LOW TIME: 3
    yield write_value(dut, 0x14, 0b0110000110000011, clk_period)

    if (dut.CLKFBOUT_MULT_F_1000 != 9000):
        raise TestFailure("FAILED: CLKFBOUT ClkReg1 DIVIDE calculation")
    if (dut.CLKFBOUT_PHASE != ((vco_period / 8) * 3)):
        raise TestFailure("FAILED: CLKFBOUT ClkReg1 PHASE calculation")

    # RESERVED: 0
    # FRAC: 000
    # FRAC_EN: 0
    # FRAC_WF_R: 0
    # MX: 00
    # EDGE: 0
    # NO COUNT: 1
    # DELAY TIME: 3
    yield write_value(dut, 0x15, 0b0000000001000011, clk_period)

    if (dut.CLKFBOUT_MULT_F_1000.value != 1000):
        raise TestFailure("FAILED: CLKFBOUT ClkReg2 DIVIDE calculation")
    if (dut.CLKFBOUT_PHASE.value != ((vco_period / 8) * 3) + (vco_period * 3)):
        raise TestFailure("FAILED: CLKFBOUT ClkReg2 PHASE calculation")

    # DIVCLK_DIVIDE
    # RESERVED: 0
    # EDGE: 0
    # NO COUNT: 0
    # HIGH TIME: 3
    # LOW TIME: 3
    yield write_value(dut, 0x16, 0b0000000011000011, clk_period)

    if (dut.DIVCLK_DIVIDE.value != 6):
        raise TestFailure("FAILED: DivReg DIVIDE calculation")

    raise TestSuccess("All tests passed")


@cocotb.coroutine
def write_value(dut, DADDR, DI, clk_period):
    dut.DEN <= 1
    dut.DWE <= 1
    dut.DADDR <= DADDR
    dut.DI <= DI
    yield Timer(clk_period * 2, 'ns')
    dut.DEN <= 0
    dut.DWE <= 0
    yield Timer(clk_period * 2, 'ns')
