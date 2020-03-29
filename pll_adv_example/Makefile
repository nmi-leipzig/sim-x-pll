pll_adv_example_build: pll_adv_example.srcs/sources_1/new/pll_adv_example_tb.v pll_adv_example.srcs/sources_1/new/pll_adv_example.v ../plle2_adv.v ../freq_gen.v ../period_check.v ../period_count.v ../phase_shift.v ../pll.v ../dyn_reconf.v
	- iverilog pll_adv_example.srcs/sources_1/new/pll_adv_example_tb.v pll_adv_example.srcs/sources_1/new/pll_adv_example.v ../plle2_adv.v ../freq_gen.v ../period_check.v ../period_count.v ../phase_shift.v ../pll.v ../dyn_reconf.v -o pll_adv_example_tb
pll_adv_example_test: pll_adv_example_build
	- vvp pll_adv_example_tb
