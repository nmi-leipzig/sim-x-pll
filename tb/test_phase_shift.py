import test_base

import shutil
import os

from avocado import Test


class PhaseShiftTest(Test, test_base.Mixin):
    """
    This class test the phase_shift.v module.
    """

    def setUp(self):
        """
        This function is needed in every test class.
        """
        # main directory of the project
        self.project_dir = os.path.dirname(self.basedir)

        # change to workdir so simulation process find the source files
        os.chdir(self.workdir)

    def generic_phase_shift_test(self, wait_interval=100):
        """test phase shift"""

        test_files = ["phase_shift_tb.v"]
        src_files = ["phase_shift.v"]
        # copy source files so we know that all required files are there
        self.copy_sources(test_files, src_files)

        verilog_files = test_files + src_files

        sim_res = self.simulate(
            verilog_files, "-DWAIT_INTERVAL={}".format(wait_interval))
        sim_output = sim_res.stdout_text

        # save vcd for analysis
        shutil.copy("phase_shift_tb.vcd", self.outputdir)

        self.check_test_bench_output(sim_output, 18)

    def test_phase_shift_100(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_phase_shift_test(wait_interval=100)

    def test_phase_shift_1000(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_phase_shift_test(wait_interval=1000)
