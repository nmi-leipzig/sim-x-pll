import test_base

import shutil
import os

from avocado import Test


class HighCounterTest(Test, test_base.Mixin):
    """
    This class tests the high_counter.v module.
    """

    def setUp(self):
        """
        This function is needed in every test class.
        """
        # main directory of the project
        self.project_dir = os.path.dirname(self.basedir)

        # change to workdir so simulation process find the source files
        os.chdir(self.workdir)

    def generic_high_counter_test(self, wait_interval=1000):
        """test high counter"""

        test_files = ["high_counter_tb.v"]
        src_files = ["high_counter.v"]
        # copy source files so we know that all required files are there
        self.copy_sources(test_files, src_files)

        verilog_files = test_files + src_files

        sim_res = self.simulate(verilog_files,
                                "-DWAIT_INTERVAL={}".format(wait_interval))
        sim_output = sim_res.stdout_text

        # save vcd for analysis
        shutil.copy("high_counter_tb.vcd", self.outputdir)

        self.check_test_bench_output(sim_output, 4)

    def test_high_counter_1000(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_high_counter_test(wait_interval=1000)

    def test_high_counter_10000(self):
        """
        :avocado: tags: quick, verilog
        """
        self.generic_high_counter_test(wait_interval=10000)
