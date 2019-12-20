/*
 * pll_led_tb.v: Test bench for pll_led.v
 * author: Till Mahlburg
 * year: 2019
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`ifndef FF_NUM
	`define FF_NUM 25
`endif

`timescale 1 ns / 1 ps

module pll_led_tb ();
	reg	rst;
	reg clk;
	wire [6:0] led;

	pll_led #(
		.FF_NUM(`FF_NUM))
	dut(
		.clk(clk),
		.RST(rst),
		.led(led));

	initial begin
		$dumpfile("pll_led_tb.vcd");
		$dumpvars(0, pll_led_tb);

		clk = 0;
		rst = 0;


		#10;
		rst = 1;
		#10;
		rst = 0;
		#100000;
		$finish;
	end

	/* 100 MHz Clock */
	always #(10 / 2) clk <= ~clk;
endmodule
