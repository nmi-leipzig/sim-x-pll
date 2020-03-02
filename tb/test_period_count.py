import test_base

import shutil
import os

from avocado import Test


class PeriodCountTest(Test, test_base.Mixin):
    """
    This class tests the period_count.v module.
    """

    def setUp(self):
        """
        This function is needed in every test class.
        """
        # main directory of the project
        self.project_dir = os.path.dirname(self.basedir)

        # change to workdir so simulation process find the source files
        os.chdir(self.workdir)

    def generic_period_count_test(self, wait_interval=100, resolution=1.0):
        """
        test period count
                """

        test_files = ["period_count_tb.v"]
        src_files = ["period_count.v"]
        # copy source files so we know that all required files are there
        self.copy_sources(test_files, src_files)

        verilog_files = test_files + src_files

        sim_res = self.simulate(verilog_files,
                                "-DWAIT_INTERVAL={} -DRESOLUTION={}".
                                format(wait_interval, resolution))
        sim_output = sim_res.stdout_text

        # save vcd for analysis
        shutil.copy("period_count_tb.vcd", self.outputdir)

        self.check_test_bench_output(sim_output, 6)

    def test_period_count_100_1_0(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_period_count_test(wait_interval=100, resolution=1.0)

    def test_period_count_100_0_1(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_period_count_test(wait_interval=100, resolution=0.1)
