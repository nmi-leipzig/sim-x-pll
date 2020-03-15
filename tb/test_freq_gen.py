import test_base

import shutil
import os

from avocado import Test


class FreqGenTest(Test, test_base.Mixin):
    """
    This class tests the freq_gen.v module.
    """

    def setUp(self):
        """
        This function is needed in every test class.
        """
        # main directory of the project
        self.project_dir = os.path.dirname(self.basedir)

        # change to workdir so simulation process find the source files
        os.chdir(self.workdir)

    def generic_freq_gen_test(self,
                              wait_interval=1000,
                              m_1000=1000,
                              d=1,
                              o_1000=1000):
       """test freq gen"""

        test_files = ["freq_gen_tb.v"]
        src_files = ["freq_gen.v", "high_counter.v"]
        # copy source files so we know that all required files are there
        self.copy_sources(test_files, src_files)

        verilog_files = test_files + src_files

        sim_res = self.simulate(verilog_files,
                                "-DWAIT_INTERVAL={} -DM_1000={} -DD={} \
                                -DO_1000={}".
                                format(wait_interval, m_1000, d, o_1000))
        sim_output = sim_res.stdout_text

        # save vcd for analysis
        shutil.copy("freq_gen_tb.vcd", self.outputdir)

        self.check_test_bench_output(sim_output, 7)

    def test_freq_gen_1000_1_1_1(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_freq_gen_test(wait_interval=1000,
                                   m_1000=1000,
                                   d=1,
                                   o_1000=1000)

    def test_freq_gen_1200_2_3_4(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_freq_gen_test(wait_interval=1200,
                                   m_1000=2000,
                                   d=3,
                                   o_1000=4000)

    def test_freq_gen_1000_3_5_1(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_freq_gen_test(wait_interval=1000,
                                   m_1000=3000,
                                   d=5,
                                   o_1000=1000)

    def test_freq_gen_1000_8_1_4(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_freq_gen_test(wait_interval=1000,
                                   m_1000=8000,
                                   d=1,
                                   o_1000=4000)

    def test_freq_gen_1000_8_1_3_3(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_freq_gen_test(wait_interval=1000,
                                   m_1000=8000,
                                   d=1,
                                   o_1000=3300)

    def test_freq_gen_1000_8_1_6_15(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_freq_gen_test(wait_interval=1000,
                                   m_1000=8000,
                                   d=1,
                                   o_1000=6150)

    def test_freq_gen_1000_8_8__1__2_1(self):
        """
        :avocado: tags: quick,verilog
        """

        self.generic_freq_gen_test(wait_interval=1000,
                                   m_1000=8800,
                                   d=1,

                                   o_1000=2100)
