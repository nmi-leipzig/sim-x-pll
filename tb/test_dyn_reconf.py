import test_base

import shutil
import os

from avocado import Test


class DynReconfTest(Test, test_base.Mixin):
    """
    This class tests the dyn_reconf.v module
    """

    def setUp(self):
        """
        This function is neeeded in every test class.
        """
        # main directory of the project
        self.project_dir = os.path.dirname(self.basedir)

        # change to workdir so simulation process finds the source files
        os.chdir(self.workdir)

    def generic_dyn_reconf_test(self, wait_interval=1000, clk_period=10):
        """
        test dyn reconf
        """

        test_files = ["dyn_reconf_tb.v"]
        src_files = ["dyn_reconf.v"]
        # copy source files, so all the required files are there
        self.copy_sources(test_files, src_files)

        verilog_files = test_files + src_files

        sim_res = self.simulate(verilog_files,
                                "-DWAIT_INTERVAL={} -DCLK_PERIOD={}".
                                format(wait_interval, clk_period))
        sim_output = sim_res.stdout_text

        # save vcd for analysis
        shutil.copy("dyn_reconf_tb.vcd", self.outputdir)

        self.check_test_bench_output(sim_output, 29)

    def test_dyn_reconf_1000_10(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_dyn_reconf_test(wait_interval=1000, clk_period=10)
