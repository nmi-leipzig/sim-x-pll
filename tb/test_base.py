#!/usr/bin/env python3

import shutil
import re
import os

from avocado.utils import process


class Mixin():
    """
    This class implements the common function of the tests for the PLL
    simulation and helper modules.
    """

    def copy_to_workdir(self, file_list):
        """Copy files to the working directory of the test"""

        for f in file_list:
            shutil.copy(f, self.workdir)

    def copy_sources(self, test_sources, project_sources):
        """Copy source files from test and and project to work directory.

        test_sources: sources from test directory
        project_sources: sources from project directory
        """
        self.copy_to_workdir([os.path.join(self.basedir, s)
                              for s in test_sources])
        self.copy_to_workdir([os.path.join(self.project_dir, s)
                              for s in project_sources])

    def simulate(self, verilog_sources, compiler_option=""):
        """Simulate Verilog sources with iverilog

        name for the out file is generated from the name of the first
         Verilog source

        returns CommandResult of simulation
        """

        simulation_filename = "{}.out".format(verilog_sources[0])
        cmd_res = process.run("iverilog -Wall -o {} {} {}".format(
                              simulation_filename,
                              " ".join(verilog_sources), compiler_option),
                              allow_output_check="both")

        cmd_res = process.run("vvp {}".format(
            simulation_filename), allow_output_check="both")
        return cmd_res

    def check_test_bench_output(self, output, result_number):
        """Check output of test bench for failed cases

        result_number: number of expected cases
        """

        count = 0
        for line in output.split("\n"):
            res = re.match(
                r'(?P<result>PASSED|FAILED):\s+(?P<description>.*)', line)
            if res is not None:
                count += 1
                if res.group("result") != "PASSED":
                    self.fail("Failed: {}".format(res.group("description")))

        if result_number > 0:
            # avoid false positive test result when the test bench
            # ends with error
            self.assertEqual(result_number, count,
                             "Expected {} test results, but found {}.".format(
                             result_number, count))
