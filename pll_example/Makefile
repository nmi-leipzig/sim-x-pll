pll_led_build: pll_example.srcs/sources_1/new/pll_led_tb.v pll_example.srcs/sources_1/new/pll_led.v pll_example.srcs/sources_1/new/divider_synth.v ../plle2_base.v ../freq_gen.v ../period_check.v ../period_count.v ../phase_shift.v ../pll.v ../dyn_reconf.v
	- iverilog pll_example.srcs/sources_1/new/pll_led_tb.v -DFF_NUM=2 pll_example.srcs/sources_1/new/pll_led.v pll_example.srcs/sources_1/new/divider_synth.v ../plle2_base.v ../freq_gen.v ../period_check.v ../period_count.v ../phase_shift.v ../pll.v ../dyn_reconf.v -o pll_led_tb
pll_led_test: pll_led_build
	- vvp pll_led_tb
