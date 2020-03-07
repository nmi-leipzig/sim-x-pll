import test_base

import shutil
import os

from avocado import Test


class PeriodCheckTest(Test, test_base.Mixin):
    """
    This class tests the period_check.v module.
    """

    def setUp(self):
        """
        This function is needed in every test class.
        """
        # main directory of the project
        self.project_dir = os.path.dirname(self.basedir)

        # change to workdir so simulation process find the source files
        os.chdir(self.workdir)

    def generic_period_check_test(self):
        """test period check"""

        test_files = ["period_check_tb.v"]
        src_files = ["period_check.v"]
        # copy source files so we know that all required files are there
        self.copy_sources(test_files, src_files)

        verilog_files = test_files + src_files

        sim_res = self.simulate(verilog_files, "")
        sim_output = sim_res.stdout_text

        # save vcd for analysis
        shutil.copy("period_check_tb.vcd", self.outputdir)

        self.check_test_bench_output(sim_output, 7)

    def test_period_check(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_period_check_test()
