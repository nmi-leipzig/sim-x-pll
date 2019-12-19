# Xilinx 7 Series PLLE2_BASE Simulation

This project aims to simulate the behavior of the PLLE2_BASE PLL found on the Xilinx 7 Series FPGAs. This is done in Verilog, using the Icarus Verilog simulation and synthesis tool. It follows the instantiation interface described in the [documentation](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug953-vivado-7series-libraries.pdf) on page 509ff. This way you can just drop the files listed below into your project, instatiate the PLL like you would for real hardware and simulate it. Read on to learn how to use the module and what it can and cannot do.

## Usage and example project

To use this module, you need to have the following files in your project:
- ```plle2_base.v```
- ```period_count.v```
- ```period_check.v```
- ```freq_gen.v```
- ```divider.v```
- ```phase_shift.v```

To build and simulate your project, you can use [icarus verilog and vvp](http://iverilog.icarus.com/) and view the results in [GTKWave](http://gtkwave.sourceforge.net/):
- ```iverilog plle2_base.v period_check.v period_count.v freq_gen.v divider.v phase_shift.v <your project files> -o <your project name>```
- ```vvp <your project name>```
- ```gtkwave dump.vcd```

If you specified the name of your output file using something like ```$dumpfile("<your_name.vcd>")```, you have to replace ```dump.vcd``` with your chosen name.

An example project found under ```pll_example/pll_example.srcs/sources_1/new/```. It is a simple program to show the usage of the module. It can be simulated from the ```tb/``` directory using
- ```make pll_led_test```

This runs iverilog and vvp to simulate the module.
To inspect the results you can use GTKWave like this:

- ```gtkwave pll_led_tb.vcd```


To run this on real hardware you might want to increase the FF_NUM parameter in ```pll_example/pll_example.srcs/sources_1/new/pll_led.v``` significantly, to achieve better result. The values chosen are adusted to be seen with the naked eye on real hardware.

To learn more about the instantiation of the module, you should read [Xilinx UG953](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug953-vivado-7series-libraries.pdf) page 509ff.

## Project Status

### Working
- instantiation interface compatible to the one described in UG953
- setting the phase, duty cycle and divider of CLKOUT outputs (CLKOUTn_DIVIDE, CLKOUTn_DUTY_CYCLE and CLKOUTn_PHASE)
- lock detection (LOCKED)
- PWRDWN and RST signals
- setting DIVCLK_DIVIDE (divides the input clock)
- tests for RST, PWRDWN, output frequency, output phase and output duty cycle
- applying CLKFB_MULT to multiply the output frequency
- applying CLKFB_PHASE to set a phase shift to every output

### Not Working
- there is no feedback loop by design
- BANDWIDTH, REF_JITTER1 and STARTUP_WAIT settings won't work with the current design approach
- connecting CLKFBIN to any other clock than CLKFBOUT won't work with the current design approach

## Test

You can test this project automatically using avocado or make.

### Avocado [recommended]

- install avocado: [Documentation](https://avocado-framework.readthedocs.io/en/latest/#how-to-install)
- change into the ```tb/``` folder
- run ```$ avocado run test_pll.py```

### Make

- change into the ```tb/``` folder
- run ```make```. This will just run every testbench in it's default configuration.

## Architecture

This diagram roughly outlines the basic architecture of the project.

![architecture diagram](https://raw.githubusercontent.com/ti-leipzig/sim-x-pll/master/arch.svg?sanitize=true)

## License

This project is licensed under the ISC license.
