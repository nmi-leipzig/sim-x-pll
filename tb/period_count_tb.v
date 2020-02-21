/*
 * period_count_tb.v: Test bench for period_count.v
 * author: Till Mahlburg
 * year: 2019
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

`ifndef WAIT_INTERVAL
	`define WAIT_INTERVAL 100
`endif

`ifndef RESOLUTION
	`define RESOLUTION 0.1
`endif

module period_count_tb ();
	reg		RST;
	reg		PWRDWN;
	reg		clk;

	wire 	[31:0] period_length_1000;

	reg 	[31:0] clk_period;

	integer	pass_count;
	integer	fail_count;

	/* adjust according to the number of test cases */
	localparam total = 5;

	period_count #(
		.RESOLUTION(`RESOLUTION))
	dut(
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(clk),
		.period_length_1000(period_length_1000));

	initial begin
		$dumpfile("period_count_tb.vcd");
		$dumpvars(0, period_count_tb);

		RST = 0;
		PWRDWN = 0;
		clk = 0;
		clk_period = 10;

		pass_count = 0;
		fail_count = 0;

		#10;
		RST = 1;
		#10;

		if (period_length_1000 === 0) begin
			$display("PASSED: RST");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: RST");
			fail_count = fail_count + 1;
		end

		RST = 0;
		#`WAIT_INTERVAL;

		if ((period_length_1000 / 1000.0) == clk_period) begin
			$display("PASSED: period = 10");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period = 10");
			fail_count = fail_count + 1;
		end

		clk_period = 13;
		#`WAIT_INTERVAL;

		if ((period_length_1000 / 1000.0) == clk_period) begin
			$display("PASSED: period = 13");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period = 13");
			fail_count = fail_count + 1;
		end

		clk_period = 1;
		#`WAIT_INTERVAL;

		if ((period_length_1000 / 1000.0) == clk_period) begin
			$display("PASSED: period = 1");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period = 1");
			fail_count = fail_count + 1;
		end

		clk_period = (`WAIT_INTERVAL / 2);
		#`WAIT_INTERVAL;

		if ((period_length_1000 / 1000.0) == `WAIT_INTERVAL / 2) begin
			$display("PASSED: period = %0d", (`WAIT_INTERVAL / 2));
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period = %0d", (`WAIT_INTERVAL / 2));
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

	always #(clk_period / 2.0) clk <= ~clk;

endmodule
