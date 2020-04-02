import test_base

import shutil
import os

from avocado import Test


class ChainedPllTest(Test, test_base.Mixin):
    """
    This class tests, if chained PLLs work as expected.
    """

    def setUp(self):
        """
        This function is needed in every test class.
        """
        # main directory of the project
        self.project_dir = os.path.dirname(self.basedir)

        # change to workdir so simulation process find the source files
        os.chdir(self.workdir)

    def generic_chained_pll_test(self,
                                 wait_interval=1000,
                                 clkin1_period=5,
                                 clkfbout_mult=5,
                                 divclk_divide=1,
                                 pll_num=3):
        """
        test chained plls
        """

        test_files = ["chained_pll_tb.v"]
        src_files=["plle2_base.v",
                   "dyn_reconf.v",
                   "freq_gen.v",
                   "period_check.v",
                   "period_count.v",
                   "phase_shift.v",
                   "pll.v"]
        # copy source files
        self.copy_sources(test_files, src_files)

        verilog_files = test_files + src_files

        sim_res = self.simulate(verilog_files,
                                "-DWAIT_INTERVAL={} \
                                 -DCLKIN1_PERIOD={} \
                                 -DCLKFBOUT_MULT={} \
                                 -DDIVCLK_DIVIDE={} \
                                 -DPLL_NUM={}".
                                format(wait_interval,
                                       clkin1_period,
                                       clkfbout_mult,
                                       divclk_divide,
                                       pll_num))

        sim_output = sim_res.stdout_text

        shutil.copy("chained_pll_tb.vcd", self.outputdir)

        self.check_test_bench_output(sim_output, pll_num + 8)

    def test_chained_pll_1000_5_5_1_3(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_chained_pll_test(wait_interval=1000,
                                      clkin1_period=5,
                                      clkfbout_mult=5,
                                      divclk_divide=1,
                                      pll_num=3)

    def test_chained_pll_1000_20_50_2_2(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_chained_pll_test(wait_interval=1000,
                                      clkin1_period=20,
                                      clkfbout_mult=50,
                                      divclk_divide=2,
                                      pll_num=2)
