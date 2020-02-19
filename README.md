.# Xilinx 7 Series PLLE2_BASE Simulation

This project aims to simulate the behavior of the PLLE2_BASE as well as the PLLE2_ADV PLL found on the Xilinx 7 Series FPGAs. This is done in Verilog, and can for example be simulated using the Icarus Verilog simulation and synthesis tool. It follows the instantiation interface described in the [documentation](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug953-vivado-7series-libraries.pdf) on page 509ff. This way you can just drop the files listed below into your project, instantiate the PLL like you would for real hardware and simulate it. Read on to learn how to use the module and what it can and cannot do.

## Quickstart


To use this module, you need to have the following files in your project:
- ```plle2_base.v``` or ```plle2_adv.v```, depending on [which one you want](#pll-choosing)
- ```period_count.v```
- ```period_check.v```
- ```freq_gen.v```
- ```divider.v```
- ```phase_shift.v```
- ```dyn_reconf.v```
- ```pll.v```



To build and simulate your project, you can use [icarus verilog and vvp](http://iverilog.icarus.com/) and view the results in [GTKWave](http://gtkwave.sourceforge.net/):
- ```iverilog plle2_base.v period_check.v period_count.v freq_gen.v divider.v phase_shift.v dyn_reconf.v pll.v <your project files> -o <your project name>``` or ```iverilog plle2_base.v period_check.v period_count.v freq_gen.v divider.v phase_shift.v dyn_reconf.v pll.v <your project files> -o <your project name>```, depending on which one you want
- ```vvp <your project name>```
- ```gtkwave dump.vcd```

If you specified the name of your output file using something like ```$dumpfile("<your_name.vcd>")```, you have to replace ```dump.vcd``` with your chosen name.

The module works by supplying an input clock, which will be transformed to an, or rather 6, output clocks. This output clock depends on the input clock and multiple parameters. You can set the wanted output frequency, phase shift and duty cycle. The output frequency is calculated like this: ```output frequency = input frequency * (multiplier / (divider * output divider))```, while the output phase can be calculated (in relation to the input phase) by using this formula: ```output phase = feedback phase + output phase```. The parts of these formulas with "output" in their name are specific to one specific output, while the others are global. There are certain limits to the values. If you hit them, the module is going to stop simulation and inform you about it. Check out the FAQ section at the end to learn more about these limits.

An typical instatiation of the PLLE2_BASE module might look like this:

	PLLE2_BASE #(
		.CLKFBOUT_MULT(8), 			// This multiplies your output clock by 8
		.CLKFBOUT_PHASE(90.0),		// This shifts the output clock by 90 degrees
		.CLKIN1_PERIOD(10.0),		// This specifies the period length of your input clock. This information is mandatory.

		// The following lines set up different dividers for every output
		.CLKOUT0_DIVIDE(128),
		.CLKOUT1_DIVIDE(64),
		.CLKOUT2_DIVIDE(32),
		.CLKOUT3_DIVIDE(16),
		.CLKOUT4_DIVIDE(128),
		.CLKOUT5_DIVIDE(128),

		// Similiarly you can set the duty cycle for every output
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT3_DUTY_CYCLE(0.5),
		.CLKOUT4_DUTY_CYCLE(0.9),
		.CLKOUT5_DUTY_CYCLE(0.1),

		// And the phase shift
		.CLKOUT0_PHASE(0.0),
		.CLKOUT1_PHASE(45.0),
		.CLKOUT2_PHASE(22.5),
		.CLKOUT3_PHASE(0.0),
		.CLKOUT4_PHASE(0.0),
		.CLKOUT5_PHASE(0.0),

		// You can also set up a divider for your input clock. This can be useful, if you have a very fast clock, which exceeds the limits of the PLL.
		.DIVCLK_DIVIDE(1))
 	pll (
 		// Bind the outputs of the PLL, for example like this.
		.CLKOUT0(output[0]),
		.CLKOUT1(output[1]),
		.CLKOUT2(output[2]),
		.CLKOUT3(output[3]),
		.CLKOUT4(output[5]),
		.CLKOUT5(output[6]),

		// These should always be set to the same wire.
		.CLKFBOUT(CLKFB),
		.CLKFBIN(CLKFB),

		// This informs you, if the output frequency is usable.
		.LOCKED(locked),
		// Bind your input clock.
		.CLKIN1(clk),

		// Allows you to power down or reset the PLL.
		.PWRDWN(pwrdwn),
		.RST(rst));

## Example project

An example project using the PLLE2_BASE found under ```pll_example/pll_example.srcs/sources_1/new/```. It is a simple program to show the usage of the module. It can be simulated from the ```tb/``` or the ```pll_example``` directory using
- ```make pll_led_test```

This runs iverilog and vvp to simulate the module.
To inspect the results you can use GTKWave like this:

- ```gtkwave pll_led_tb.vcd```

The default values chosen are meant to be seen with the naked eye on real hardware. If you run the simulation using ```make``` the values are adjusted to be easy to see in GTKWave.

To learn more about the instantiation of the module, you should read [Xilinx UG953](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug953-vivado-7series-libraries.pdf) page 509ff.

## Project Status

### Working
- instantiation interface compatible to the one described in UG953
- setting the phase, duty cycle and divider of CLKOUT outputs (CLKOUTn_DIVIDE, CLKOUTn_DUTY_CYCLE and CLKOUTn_PHASE)
- lock detection (LOCKED)
- PWRDWN and RST signals
- setting DIVCLK_DIVIDE (divides the input clock)
- tests for RST, PWRDWN, output frequency, output phase and output duty cycle
- applying CLKFBOUT_MULT to multiply the output frequency
- applying CLKFBOUT_PHASE to set a phase shift to every output
- setting CLKINSEL and selecting one of two input clocks
- basic dynamic reconfiguration functionality

### Not Working
- there is no feedback loop by design
- BANDWIDTH, REF_JITTER1, REF_JITTER2, COMPENSATION and STARTUP_WAIT settings won't work with the current design approach
- connecting CLKFBIN to any other clock than CLKFBOUT won't work with the current design approach
- dynamic reconfiguration only has an effect in the ClkReg1 and ClkReg2 registers

## Test

You can test this project automatically using avocado or make. The testbenches themselves are written in pure verilog.

### Avocado [recommended]

- install avocado: [Documentation](https://avocado-framework.readthedocs.io/en/latest/#how-to-install)
- change into the ```tb/``` folder
- run ```$ avocado run test_pll.py```

### Make

- change into the ```tb/``` folder
- run ```make```. This will just run every testbench in it's default configuration.

## Architecture

This diagram roughly outlines the basic architecture of the project for PLLE2_BASE.

![architecture diagram](https://raw.githubusercontent.com/ti-leipzig/sim-x-pll/master/arch.svg?sanitize=true)

## License

This project is licensed under the ISC license.

## FAQ

### Which limits does the PLL have?
Use this table for parameters:

| parameter          | allowed values             |
| ------------------ | -------------------------- |
| BANDWIDTH          | "OPTIMIZED", "HIGH", "LOW" |
| CLKFBOUT_MULT      | 2 - 64                     |
| CLKFBOUT_PHASE     | -360.000 - 360.000         |
| CLKIN1_PERIOD      | 0 - 52.631                 |
| CLKOUTn_DIVIDE     | 1 - 128                    |
| CLKOUTn_DUTY_CYCLE | -360.000 - 360.000         |
| DIVCLK_DIVIDE      | 1 - 56                     |
| REF_JITTER1        | 0.000 - 0.999              |
| STARTUP_WAIT       | "FALSE", "TRUE"            |

Also there is a limitation in the PLL regarding the possible frequency. They depend on the capabilities of the VCO. It's frequency can be calculated using this formula: ```VCO frequency = (CLKFBOUT_MULT * 1000) / (CLKIN1_PERIOD * DIVCLKDIVIDE)```. The VCO frequency should lie between **800.000 and 1600.000**.

<h3 id="pll-choosing">Which PLL should I choose?</h3>
The main differences between the two versions are the support for two input clocks and dynamic reconfiguration in PLLE2_ADV. For a more in-depth overview of the differences see [UGS472 page 70](https://www.xilinx.com/support/documentation/user_guides/ug472_7Series_Clocking.pdf).
