import test_base

import shutil
import os

from avocado import Test


class Mmcme2BaseTest(Test, test_base.Mixin):
    """
    This class tests the mmcme2_base.v module.
    """

    def setUp(self):
        """
        This function is needed in every test class.
        """
        # main directory of the project
        self.project_dir = os.path.dirname(self.basedir)

        # change to workdir so simulation process find the source files
        os.chdir(self.workdir)

    def generic_mmcme2_base_test(self,
                                 wait_interval=500,
                                 bandwidth=r'\"OPTIMIZED\"',

                                 clkfbout_mult_f=5.000,
                                 clkfbout_phase=0.000,

                                 clkin1_period=5.000,

                                 clkout0_divide_f=1.000,
                                 clkout1_divide=1,
                                 clkout2_divide=1,
                                 clkout3_divide=1,
                                 clkout4_divide=1,
                                 clkout5_divide=1,
                                 clkout6_divide=1,

                                 clkout0_duty_cycle=0.500,
                                 clkout1_duty_cycle=0.500,
                                 clkout2_duty_cycle=0.500,
                                 clkout3_duty_cycle=0.500,
                                 clkout4_duty_cycle=0.500,
                                 clkout5_duty_cycle=0.500,
                                 clkout6_duty_cycle=0.500,

                                 clkout0_phase=0.000,
                                 clkout1_phase=0.000,
                                 clkout2_phase=0.000,
                                 clkout3_phase=0.000,
                                 clkout4_phase=0.000,
                                 clkout5_phase=0.000,
                                 clkout6_phase=0.000,

                                 clkout4_cascade=r'\"FALSE\"',

                                 divclk_divide=1,

                                 ref_jitter1=0.010,
                                 startup_wait=r'\"FALSE\"'):
        """test mmcme2 base"""

        test_files = ["mmcme2_base_tb.v"]
        src_files = ["phase_shift.v",
                     "mmcme2_base.v",
                     "freq_gen.v",
                     "period_check.v",
                     "period_count.v",
                     "dyn_reconf.v",
                     "pll.v",
                     "phase_shift_check.v",
                     "duty_cycle_check.v"]
        # copy source files so we know that all required files are there
        self.copy_sources(test_files, src_files)

        verilog_files = test_files + src_files

        sim_res = self.simulate(verilog_files,
                                """
                                -DWAIT_INTERVAL={} \

                                -DBANDWIDTH={} \

                                -DCLKFBOUT_MULT_F={} \
                                -DCLKFBOUT_PHASE={} \

                                -DCLKIN1_PERIOD={} \

                                -DCLKOUT0_DIVIDE_F={} \
                                -DCLKOUT1_DIVIDE={} \
                                -DCLKOUT2_DIVIDE={} \
                                -DCLKOUT3_DIVIDE={} \
                                -DCLKOUT4_DIVIDE={} \
                                -DCLKOUT5_DIVIDE={} \
                                -DCLKOUT6_DIVIDE={} \

                                -DCLKOUT0_DUTY_CYCLE={} \
                                -DCLKOUT1_DUTY_CYCLE={} \
                                -DCLKOUT2_DUTY_CYCLE={} \
                                -DCLKOUT3_DUTY_CYCLE={} \
                                -DCLKOUT4_DUTY_CYCLE={} \
                                -DCLKOUT5_DUTY_CYCLE={} \
                                -DCLKOUT6_DUTY_CYCLE={} \

                                -DCLKOUT0_PHASE={} \
                                -DCLKOUT1_PHASE={} \
                                -DCLKOUT2_PHASE={} \
                                -DCLKOUT3_PHASE={} \
                                -DCLKOUT4_PHASE={} \
                                -DCLKOUT5_PHASE={} \
                                -DCLKOUT6_PHASE={} \

                                -DCLKOUT4_CASCADE={} \

                                -DDIVCLK_DIVIDE={} \

                                -DREF_JITTER1={} \
                                -DSTARTUP_WAIT={}"""
                                .format(
                                    wait_interval,

                                    bandwidth,

                                    clkfbout_mult_f,
                                    clkfbout_phase,

                                    clkin1_period,

                                    clkout0_divide_f,
                                    clkout1_divide,
                                    clkout2_divide,
                                    clkout3_divide,
                                    clkout4_divide,
                                    clkout5_divide,
                                    clkout6_divide,

                                    clkout0_duty_cycle,
                                    clkout1_duty_cycle,
                                    clkout2_duty_cycle,
                                    clkout3_duty_cycle,
                                    clkout4_duty_cycle,
                                    clkout5_duty_cycle,
                                    clkout6_duty_cycle,

                                    clkout0_phase,
                                    clkout1_phase,
                                    clkout2_phase,
                                    clkout3_phase,
                                    clkout4_phase,
                                    clkout5_phase,
                                    clkout6_phase,

                                    clkout4_cascade,

                                    divclk_divide,

                                    ref_jitter1,

                                    startup_wait)
                                .replace("\n", "").replace("\t", ""))
        sim_output = sim_res.stdout_text

        # save vcd for analysis
        shutil.copy("mmcme2_base_tb.vcd", self.outputdir)

        self.check_test_bench_output(sim_output, 32)

    def test_mmcme2_base_default(self):
        """
        :avocado: tags:quick,verilog
        """

        self.generic_mmcme2_base_test()

    def test_mmcme2_base_clkout0(self):
        """
        :avocado: tags:quick,verilog
        """

        self.generic_mmcme2_base_test(clkout0_divide_f=2.5,
                                      clkout0_duty_cycle=0.6)

    def test_mmcme2_base_clkfbout(self):
        """
        :avocado: tags:quick,verilog
        """

        self.generic_mmcme2_base_test(clkfbout_mult_f=5.5,
                                      clkfbout_phase=10,
                                      clkin1_period=5.5)

    def test_mmcme2_base_clkout6(self):
        """
        :avocado: tags:quick,verilog
        """

        self.generic_mmcme2_base_test(clkout6_divide=8,
                                      clkout6_duty_cycle=0.125)

    def test_mmcme2_base_clkout6_phase(self):
        """
        :avocado: tags:quick,verilog
        """

        self.generic_mmcme2_base_test(clkout6_phase=-11.111)

    def test_mmcme2_base_clkout4_cascade(self):
        """
        :avocado: tags:quick,verilog
        """

        self.generic_mmcme2_base_test(clkout4_cascade=r'\"TRUE\"',
                                      clkout4_divide=5,
                                      clkout6_divide=10)
