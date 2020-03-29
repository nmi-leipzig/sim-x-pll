/*
 * pll_adv_example_tb.v: Test bench for pll_adv_example.v
 * author: Till Mahlburg
 * year: 2020
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

`ifndef WAIT_INTERVAL
	`define WAIT_INTERVAL 10000
`endif

module pll_adv_example_tb ();
	reg RST;
	reg clk;
	wire [7:0] led;

	pll_adv_example dut(
		.clk(clk),
		.RST(RST),
		.led(led));

	initial begin
		$dumpfile("pll_adv_example_tb.vcd");
		$dumpvars(0, pll_adv_example_tb);

		RST = 0;
		clk = 0;

		#10;
		RST = 1;
		#10;

		/* TEST CASES */
		RST = 0;
		#`WAIT_INTERVAL

		$finish;
	end

	always #5 clk <= ~clk;
endmodule
