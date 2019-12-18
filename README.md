# Xilinx 7 Series PLLE2_BASE Simulation

This project aims to simulate PLLE2_BASE PLL found on the Xilinx 7 Series FPGAs.
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

- install avocado: [https://avocado-framework.readthedocs.io/en/latest/#how-to-install](Documentation)
- change into the ```tb/``` folder
- run ```$ avocado run test_pll.py```

### Make

- change into the ```tb/``` folder
- run ```make```. This will just run every testbench in it's default configuration.

## Usage and example project

To use this module, you need to have the following files in your project:
- ```plle2_base.v```
- ```period_count.v```
- ```period_check.v```
- ```freq_gen.v```
- ```divider.v```
- ```phase_shift.v```

The example project found under ```xilinx/pll_example/pll_example.srcs/sources_1/new/``` is a simple program to show the usage of the module. It can be simulated from the ```tb/``` directory using
- ```make pll_led_test```.
You might want to increase either the run time of the testbench ```tb/pll_led_tb``` or reduce the divisor in ```xilinx/pll_example/pll_example.srcs/sources_1/new/pll_led.v``` significantly, to better see results on the screen. The values chosen are adusted to be seen with the naked eye on real hardware.

To learn more about the instantiation of the module, you should read Xilinx UG953 page 509ff.

## Architecture

This diagram roughly outlines the basic architecture of the project.

![architecture diagram](https://raw.githubusercontent.com/ti-leipzig/sim-x-pll/master/arch.svg?sanitize=true)

## License

This project is licensed under the ISC license.
