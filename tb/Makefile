VC	= iverilog

test: period_check_test freq_gen_test period_count_test high_counter_test phase_shift_test plle2_base_test plle2_adv_test dyn_reconf_test

build_all: period_check_build freq_gen_build freq_gen_build period_count_build high_counter_build phase_shift_build plle2_base_build pll_led_build plle2_adv_build dyn_reconf_build

build_pll: plle2_base_build plle2_adv_build


pll_led_build: ../pll_example/pll_example.srcs/sources_1/new/pll_led_tb.v ../pll_example/pll_example.srcs/sources_1/new/pll_led.v ../pll_example/pll_example.srcs/sources_1/new/divider_synth.v ../plle2_base.v ../freq_gen.v ../period_check.v ../period_count.v ../phase_shift.v ../pll.v ../dyn_reconf.v
	- $(VC) ../pll_example/pll_led_tb.v -DFF_NUM=2 ../pll_example/pll_example.srcs/sources_1/new/pll_led.v ../pll_example/pll_example.srcs/sources_1/new/divider_synth.v ../plle2_base.v ../freq_gen.v ../period_check.v ../period_count.v ../phase_shift.v ../pll.v ../dyn_reconf.v -o pll_led_tb
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

plle2_base_build: ../plle2_base.v ../period_count.v ../period_check.v ../freq_gen.v ../phase_shift.v ../pll.v ../dyn_reconf.v ../phase_shift_check.v ../duty_cycle_check.v ../period_helper.v plle2_base_tb.v
	- $(VC) ../plle2_base.v ../period_check.v ../period_count.v ../freq_gen.v ../phase_shift.v ../pll.v ../dyn_reconf.v ../duty_cycle_check.v ../phase_shift_check.v ../period_helper.v plle2_base_tb.v -o plle2_base_tb
plle2_base_test: plle2_base_build
	- vvp plle2_base_tb

plle2_adv_build: ../plle2_adv.v ../period_count.v ../period_check.v ../freq_gen.v ../phase_shift.v ../pll.v ../dyn_reconf.v plle2_adv_tb.v
	- $(VC) ../plle2_adv.v ../period_check.v ../period_count.v ../freq_gen.v ../phase_shift.v ../dyn_reconf.v plle2_adv_tb.v ../pll.v -o plle2_adv_tb
plle2_adv_test: plle2_adv_build
	- vvp plle2_adv_tb

dyn_reconf_build: ../dyn_reconf.v dyn_reconf_tb.v
	- $(VC) ../dyn_reconf.v dyn_reconf_tb.v -o dyn_reconf_tb
dyn_reconf_test: dyn_reconf_build
	- vvp dyn_reconf_tb

duty_cycle_check_build: ../duty_cycle_check.v duty_cycle_check_tb.v
	- $(VC) ../duty_cycle_check.v duty_cycle_check_tb.v -o duty_cycle_check_tb
duty_cycle_check_test: duty_cycle_check_build
	- vvp duty_cycle_check_tb

phase_shift_check_build: ../phase_shift_check.v phase_shift_check_tb.v
	- $(VC) ../phase_shift_check.v phase_shift_check_tb.v -o phase_shift_check_tb
phase_shift_check_test: phase_shift_check_build
	- vvp phase_shift_check_tb

clean:
	- rm *_tb
	- rm *_tb.vcd
