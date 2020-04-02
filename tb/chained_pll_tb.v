/*
 * chained_pll_tb.v: Test bench for chained plls.
 * author: Till Mahlburg
 * year: 2020
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

`ifndef WAIT_INTERVAL
	`define WAIT_INTERVAL 1000
`endif

`ifndef CLKIN1_PERIOD
	`define CLKIN1_PERIOD 5
`endif

`ifndef CLKFBOUT_MULT
	`define CLKFBOUT_MULT 5
`endif

`ifndef DIVCLK_DIVIDE
	`define DIVCLK_DIVIDE 1
`endif

`ifndef PLL_NUM
	`define PLL_NUM 3
`endif

module chained_pll_tb ();
	reg rst;
	reg clk;

	integer pass_count;
	integer fail_count;

	/* adjust according to the number of test cases */
	localparam total = (`PLL_NUM + 7);

	wire [(`PLL_NUM - 1):0] CLKOUT[5:0];
	wire [(`PLL_NUM):0] CLKFBOUT;
	wire [(`PLL_NUM - 1):0] LOCKED;
	assign CLKFBOUT[0] = CLKFBOUT[`PLL_NUM];

	wire [31:0] period_1000[0:5];
	wire [31:0] period_1000_fb;

	genvar i;
	generate
		for (i = 0; i < `PLL_NUM; i = i + 1) begin : pll
			PLLE2_BASE #(
				.CLKFBOUT_MULT(`CLKFBOUT_MULT),
				.CLKFBOUT_PHASE(0.0),
				.CLKIN1_PERIOD(`CLKIN1_PERIOD),
				.DIVCLK_DIVIDE(`DIVCLK_DIVIDE)) pll (
				.CLKOUT0(CLKOUT[0][i]),
				.CLKOUT1(CLKOUT[1][i]),
				.CLKOUT2(CLKOUT[2][i]),
				.CLKOUT3(CLKOUT[3][i]),
				.CLKOUT4(CLKOUT[4][i]),
				.CLKOUT5(CLKOUT[5][i]),
				.CLKFBOUT(CLKFBOUT[i+1]),
				.CLKFBIN(CLKFBOUT[i]),
				.LOCKED(LOCKED[i]),
				.RST(rst),
				.CLKIN1(clk),
				.PWRDWN(1'b0));
		end

		for (i = 0; i <= 5; i = i + 1) begin : period_count
			period_count period_count (
				.RST(rst),
				.clk(CLKOUT[i][`PLL_NUM - 1]),
				.period_length_1000(period_1000[i]));
		end
	endgenerate

	period_count period_count_fb (
		.RST(rst),
		.clk(CLKFBOUT[`PLL_NUM - 1]),
		.period_length_1000(period_1000_fb));

	integer k;
	initial begin
		$dumpfile("chained_pll_tb.vcd");
		$dumpvars(0, chained_pll_tb);

		rst = 0;
		clk = 0;

		pass_count = 0;
		fail_count = 0;

		#10;
		rst = 1;
		#10;
		/* TEST CASES */
		for (k = 0; k < `PLL_NUM; k = k + 1) begin
			if ((CLKOUT[0][k] & CLKOUT[1][k] & CLKOUT[2][k] & CLKOUT[3][k] & CLKOUT[4][k] & CLKOUT[5][k] & CLKFBOUT[k+1] & LOCKED[k]) == 0) begin
				$display("PASSED: RST on PLL %0d", k);
				pass_count = pass_count + 1;
			end else begin
				$display("FAILED: RST on PLL %0d", k);
				fail_count = fail_count + 1;
			end
		end

		rst = 0;
		#`WAIT_INTERVAL;

		for (k = 0; k <= 5; k = k + 1) begin
			if ((period_1000[k] / 1000.0) == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
				$display("PASSED: CLKOUT%0d frequency", k);
				pass_count = pass_count + 1;
			end else begin
				$display("FAILED: CLKOUT%0d frequency", k);
				fail_count = fail_count + 1;
			end
		end

		if ((period_1000_fb / 1000.0) == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKFBOUT frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKFBOUT frequency");
			fail_count = fail_count + 1;
		end

		if ((pass_count + fail_count) == total) begin
			$display("PASSED: number of test cases");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: number of test cases");
			fail_count = fail_count + 1;
		end

		$display("%0d/%0d PASSED", pass_count, (total + 1));
		$finish;
	end

	always #(`CLKIN1_PERIOD / 2.0) clk <= ~clk;
endmodule
