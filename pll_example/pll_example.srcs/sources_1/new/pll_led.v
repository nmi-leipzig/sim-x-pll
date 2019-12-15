/*
 * pll_led.v: Example program working in simulation as well as on real hardware. Tested on Digilent Basys 3.
 * author: Till Mahlburg
 * year: 2019
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

module pll_led (
	input clk,
	input RST,

	output [15:0] led);

	/* divide the output signal, so one can see the results at the LEDs */
	wire [6:0] pll_out;

  	genvar i;

  	generate
    	for (i = 3; i < 7; i = i + 1) begin : generate_div
			divider_synth #(
				.FF_NUM(25)) div (
				.clk_in(pll_out[i]),
				.RST(RST),
				.clk_out(led[i]));
    	end 
  	endgenerate
  	


	wire CLKFB;
	/* More information about the instantiiation can be found in Xilinx UG953 509ff. */
	PLLE2_BASE #(
		.CLKFBOUT_MULT(8),
		.CLKFBOUT_PHASE(90.0),
		.CLKIN1_PERIOD(10.0),

		.CLKOUT0_DIVIDE(128),
		.CLKOUT1_DIVIDE(64),
		.CLKOUT2_DIVIDE(32),
		.CLKOUT3_DIVIDE(16),
		.CLKOUT4_DIVIDE(128),
		.CLKOUT5_DIVIDE(128),

		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT3_DUTY_CYCLE(0.5),
		.CLKOUT4_DUTY_CYCLE(0.9),
		.CLKOUT5_DUTY_CYCLE(0.1),

		.CLKOUT0_PHASE(0.0),
		.CLKOUT1_PHASE(0.0),
		.CLKOUT2_PHASE(0.0),
		.CLKOUT3_PHASE(0.0),
		.CLKOUT4_PHASE(0.0),
		.CLKOUT5_PHASE(0.0),

		.DIVCLK_DIVIDE(1))
 	pll (
		.CLKOUT0(pll_out[3]),
		.CLKOUT1(pll_out[4]),
		.CLKOUT2(pll_out[5]),
		.CLKOUT3(pll_out[6]),
		.CLKOUT4(led[8]),
		.CLKOUT5(led[9]),

		.CLKFBOUT(CLKFB),
		.LOCKED(led[0]),
		.CLKIN1(clk),

		.PWRDWN(0),
		.RST(RST),

		.CLKFBIN(CLKFB));
endmodule
