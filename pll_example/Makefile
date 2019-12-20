build: 	pll_example.srcs/sources_1/new/pll_led_tb.v pll_example.srcs/sources_1/new/pll_led.v pll_example.srcs/sources_1/new/divider_synth.v ../freq_gen.v ../plle2_base.v ../period_check.v ../period_count.v ../phase_shift.v
	- iverilog pll_example.srcs/sources_1/new/pll_led_tb.v -DFF_NUM=2 pll_example.srcs/sources_1/new/pll_led.v pll_example.srcs/sources_1/new/divider_synth.v ../freq_gen.v ../plle2_base.v ../period_check.v ../period_count.v ../phase_shift.v -o pll_led_tb
	- vvp pll_led_tb
