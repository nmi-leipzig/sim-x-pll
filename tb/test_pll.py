#!/usr/bin/env python3

import shutil
import re
import os

from avocado import Test
from avocado.utils import process

class PLLTest(Test):
	"""This class implements the automated tests for the PLLE2_BASE simulation modules."""

	def setUp(self):
		# main directory of the project
		self.project_dir = os.path.dirname(self.basedir)

		# change to workdir so simulation process find the source files
		os.chdir(self.workdir)

	def copy_to_workdir(self, file_list):
		"""Copy files to the working directory of the test"""

		for f in file_list:
			shutil.copy(f, self.workdir)

	def copy_sources(self, test_sources, project_sources):
		"""Copy source files from test and and project to work directory.

		test_sources: sources from test directory
		project_sources: sources from project directory
		"""
		self.copy_to_workdir([os.path.join(self.basedir, s) for s in test_sources])
		self.copy_to_workdir([os.path.join(self.project_dir, s) for s in project_sources])

	def simulate(self, verilog_sources, compiler_option=""):
		"""Simulate Verilog sources with iverilog

		name for the out file is generated from the name of the first Verilog source

		returns CommandResult of simulation
		"""

		simulation_filename = "{}.out".format(verilog_sources[0])
		cmd_res = process.run("iverilog -Wall -o {} {} {}".format(simulation_filename, " ".join(verilog_sources), compiler_option), allow_output_check="both")
		cmd_res = process.run("vvp {}".format(simulation_filename), allow_output_check="both")
		return cmd_res

	def check_test_bench_output(self, output, result_number):
		"""Check output of test bench for failed cases

		result_number: number of expected cases
		"""

		count = 0
		for line in output.split("\n"):
			res = re.match(r'(?P<result>PASSED|FAILED):\s+(?P<description>.*)', line)
			if res is not None:
				count += 1
				if res.group("result") != "PASSED":
					self.fail("Failed: {}".format(res.group("description")))

		if result_number > 0:
			# avoid false positive test result when the test bench ends with error
			self.assertEqual(result_number, count, "Expected {} test results, but found {}.".format(result_number, count))


	def generic_high_counter_test(self, wait_interval=1000):
		"""test high counter"""

		test_files = ["high_counter_tb.v"]
		src_files = ["high_counter.v"]
		# copy source files so we know that all required files are there
		self.copy_sources(test_files, src_files)

		verilog_files = test_files + src_files

		sim_res = self.simulate(verilog_files, "-DWAIT_INTERVAL={}".format(wait_interval))
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


	def generic_phase_shift_test(self, wait_interval=100):
		"""test phase shift"""

		test_files = ["phase_shift_tb.v"]
		src_files = ["phase_shift.v"]
		# copy source files so we know that all required files are there
		self.copy_sources(test_files, src_files)

		verilog_files = test_files + src_files

		sim_res = self.simulate(verilog_files, "-DWAIT_INTERVAL={}".format(wait_interval))
		sim_output = sim_res.stdout_text

		# save vcd for analysis
		shutil.copy("phase_shift_tb.vcd", self.outputdir)

		self.check_test_bench_output(sim_output, 16)

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


	def generic_plle2_base_test(self,
            wait_interval=1000,
            bandwidth=r'\"OPTIMIZED\"',

            clkfbout_mult=5,
            clkfbout_phase=0.000,

            clkin1_period=5.000,

            clkout0_divide=1,
            clkout1_divide=1,
            clkout2_divide=1,
            clkout3_divide=1,
            clkout4_divide=1,
            clkout5_divide=1,

            clkout0_duty_cycle=0.500,
            clkout1_duty_cycle=0.500,
            clkout2_duty_cycle=0.500,
            clkout3_duty_cycle=0.500,
            clkout4_duty_cycle=0.500,
            clkout5_duty_cycle=0.500,

            clkout0_phase=0.000,
            clkout1_phase=0.000,
            clkout2_phase=0.000,
            clkout3_phase=0.000,
            clkout4_phase=0.000,
            clkout5_phase=0.000,

            divclk_divide=1,

            ref_jitter1=0.010,
            startup_wait=r'\"FALSE\"'):

		"""test plle2 base"""

		test_files = ["plle2_base_tb.v"]
		src_files = ["phase_shift.v", "plle2_base.v", "freq_gen.v", "period_check.v", "period_count.v"]
		# copy source files so we know that all required files are there
		self.copy_sources(test_files, src_files)

		verilog_files = test_files + src_files

		sim_res = self.simulate(verilog_files,
			"""
			-DWAIT_INTERVAL={} \

			-DBANDWIDTH={} \

			-DCLKFBOUT_MULT={} \
			-DCLKFBOUT_PHASE={} \

			-DCLKIN1_PERIOD={} \

			-DCLKOUT0_DIVIDE={} \
			-DCLKOUT1_DIVIDE={} \
			-DCLKOUT2_DIVIDE={} \
			-DCLKOUT3_DIVIDE={} \
			-DCLKOUT4_DIVIDE={} \
			-DCLKOUT5_DIVIDE={} \

			-DCLKOUT0_DUTY_CYCLE={} \
			-DCLKOUT1_DUTY_CYCLE={} \
			-DCLKOUT2_DUTY_CYCLE={} \
			-DCLKOUT3_DUTY_CYCLE={} \
			-DCLKOUT4_DUTY_CYCLE={} \
			-DCLKOUT5_DUTY_CYCLE={} \

			-DCLKOUT0_PHASE={} \
			-DCLKOUT1_PHASE={} \
			-DCLKOUT2_PHASE={} \
			-DCLKOUT3_PHASE={} \
			-DCLKOUT4_PHASE={} \
			-DCLKOUT5_PHASE={} \

			-DDIVCLK_DIVIDE={} \

			-DREF_JITTER1={} \
			-DSTARTUP_WAIT={}"""
		.format(
			wait_interval,

			bandwidth,

			clkfbout_mult,
			clkfbout_phase,

			clkin1_period,

			clkout0_divide,
			clkout1_divide,
			clkout2_divide,
			clkout3_divide,
			clkout4_divide,
			clkout5_divide,

			clkout0_duty_cycle,
			clkout1_duty_cycle,
			clkout2_duty_cycle,
			clkout3_duty_cycle,
			clkout4_duty_cycle,
			clkout5_duty_cycle,

			clkout0_phase,
			clkout1_phase,
			clkout2_phase,
			clkout3_phase,
			clkout4_phase,
			clkout5_phase,

			divclk_divide,

			ref_jitter1,

			startup_wait)
		.replace("\n", "").replace("\t", ""))
		sim_output = sim_res.stdout_text

		# save vcd for analysis
		shutil.copy("plle2_base_tb.vcd", self.outputdir)

		self.check_test_bench_output(sim_output, 24)

	def test_plle2_base_default(self):
		"""
		:avocado: tags:quick,verilog
		"""

		self.generic_plle2_base_test()

	def test_plle2_base_clkfbout_clkin1_divclk(self):
		"""
		:avocado: tags:quick,verilog
		"""

		self.generic_plle2_base_test(clkfbout_mult=64, clkin1_period=20.000, divclk_divide=4)

	def test_plle2_base_clkout0(self):
		"""
		:avocado: tags:quick,verilog
		"""

		self.generic_plle2_base_test(clkout0_divide=5, clkout0_duty_cycle=0.100)

	def test_plle2_base_clkout5(self):
		"""
		:avocado: tags:quick,verilog
		"""

		self.generic_plle2_base_test(clkout5_divide=10, clkout5_duty_cycle=0.85)

	def test_plle2_base_clkout1_clkout2_divclk_clkfb(self):
	 	"""
	 	:avocado: tags:quick,verilog
	 	"""

	 	self.generic_plle2_base_test(clkout1_divide=3, clkout1_duty_cycle=0.450, clkout2_divide=8, clkout2_duty_cycle=0.333, divclk_divide=2, clkfbout_mult=8)

	def test_plle2_base_phase(self):
		"""
		:avocado: tags:quick, verilog
		"""

		self.generic_plle2_base_test(clkfbout_phase=90, clkout0_phase=22.5, clkout1_phase=45, clkout2_phase=90, clkout3_phase=180, clkout4_phase=270, clkout5_phase=-60)

	def test_plle2_base_showcase(self):
		"""
		:avocado: tags:verilog
		"""

		self.generic_plle2_base_test(clkout0_divide=2, clkout1_duty_cycle=0.1, clkout2_duty_cycle=0.9, clkout3_phase=180, clkout4_phase=-90, clkout5_divide=4, clkout5_duty_cycle=0.3, clkfbout_mult=4)


	def generic_period_count_test(self, wait_interval=100, resolution=1.0):
		"""test period count"""

		test_files = ["period_count_tb.v"]
		src_files = ["period_count.v"]
		# copy source files so we know that all required files are there
		self.copy_sources(test_files, src_files)

		verilog_files = test_files + src_files

		sim_res = self.simulate(verilog_files, "-DWAIT_INTERVAL={} -DRESOLUTION={}".format(wait_interval, resolution))
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


	def generic_freq_gen_test(self, wait_interval=1000, m=1, d=1, o=1):
		"""test period count"""

		test_files = ["freq_gen_tb.v"]
		src_files = ["freq_gen.v", "high_counter.v"]
		# copy source files so we know that all required files are there
		self.copy_sources(test_files, src_files)

		verilog_files = test_files + src_files

		sim_res = self.simulate(verilog_files, "-DWAIT_INTERVAL={} -DM={} -DD={} -DO={}".format(wait_interval, m, d, o))
		sim_output = sim_res.stdout_text

		# save vcd for analysis
		shutil.copy("freq_gen_tb.vcd", self.outputdir)

		self.check_test_bench_output(sim_output, 6)

	def test_freq_gen_1000_1_1_1(self):
		"""
		:avocado: tags: quick,verilog
		"""

		self.generic_freq_gen_test(wait_interval=1000, m=1, d=1, o=1)

	def test_freq_gen_1200_2_3_4(self):
		"""
		:avocado: tags: quick,verilog
		"""

		self.generic_freq_gen_test(wait_interval=1200, m=2, d=3, o=4)

	def test_freq_gen_1000_3_5_1(self):
		"""
		:avocado: tags: quick,verilog
		"""

		self.generic_freq_gen_test(wait_interval=1000, m=3, d=5, o=1)

	def test_freq_gen_1000_8_1_4(self):
		"""
		:avocado: tags: quick,verilog
		"""

		self.generic_freq_gen_test(wait_interval=1000, m=8, d=1, o=4)

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
