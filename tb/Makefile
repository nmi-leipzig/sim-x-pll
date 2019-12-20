VC	= iverilog

test: period_check_test freq_gen_test period_count_test high_counter_test phase_shift_test plle2_base_test

build_all: period_check_build freq_gen_build freq_gen_build period_count_build high_counter_build phase_shift_build plle2_base_build pll_led_build

build_pll: plle2_base_build

pll_led_build: ../pll_example/pll_example.srcs/sources_1/new/pll_led_tb.v ../pll_example/pll_example.srcs/sources_1/new/pll_led.v ../pll_example/pll_example.srcs/sources_1/new/divider_synth.v ../plle2_base.v ../freq_gen.v ../period_check.v ../period_count.v ../phase_shift.v
	- $(VC) ../pll_example/pll_led_tb.v -DFF_NUM=2 ../pll_example/pll_example.srcs/sources_1/new/pll_led.v ../pll_example/pll_example.srcs/sources_1/new/divider_synth.v ../plle2_base.v ../freq_gen.v ../period_check.v ../period_count.v ../phase_shift.v -o pll_led_tb

pll_led_test: pll_led_build
	- vvp pll_led_tb

period_check_build: ../period_check.v period_check_tb.v
	- $(VC) ../period_check.v period_check_tb.v -o period_check_tb

period_check_test: period_check_build
	- vvp period_check_tb

freq_gen_build: ../freq_gen.v ../high_counter.v freq_gen_tb.v
	- $(VC) ../freq_gen.v ../high_counter.v freq_gen_tb.v -o freq_gen_tb

freq_gen_test: freq_gen_build
	- vvp freq_gen_tb

period_count_build: ../period_count.v period_count_tb.v
	- $(VC) ../period_count.v period_count_tb.v -o period_count_tb

period_count_test: period_count_build
	- vvp period_count_tb

high_counter_build: ../high_counter.v high_counter_tb.v
	- $(VC) ../high_counter.v high_counter_tb.v -o high_counter_tb

high_counter_test: high_counter_build
	- vvp high_counter_tb

phase_shift_build: ../phase_shift.v phase_shift_tb.v
	- $(VC) ../phase_shift.v phase_shift_tb.v -o phase_shift_tb

phase_shift_test: phase_shift_build
	- vvp phase_shift_tb

plle2_base_build: ../plle2_base.v ../period_count.v ../period_check.v ../freq_gen.v ../phase_shift.v plle2_base_tb.v
	- $(VC) ../plle2_base.v ../period_check.v ../period_count.v ../freq_gen.v ../phase_shift.v plle2_base_tb.v -o plle2_base_tb

plle2_base_test: plle2_base_build
	- vvp plle2_base_tb

clean:
	- rm *_tb
	- rm *_tb.vcd
