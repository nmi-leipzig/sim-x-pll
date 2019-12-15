/*
 * period_check_tb.v: Test bench for period_check.v
 * author: Till Mahlburg
 * year: 2019
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

module period_check_tb ();
	reg	RST;
	reg PWRDWN;
	reg clk;
	reg [31:0] period_length;

	wire period_stable;

	integer	pass_count;
	integer	fail_count;

	/* adjust according to the number of test cases */
	localparam total = 6;

	period_check dut(
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(clk),
		.period_length(period_length),
		.period_stable(period_stable));

	initial begin
		$dumpfile("period_check_tb.vcd");
		$dumpvars(0, period_check_tb);

		RST = 0;
		PWRDWN = 0;
		clk = 0;
		period_length = 20;

		pass_count = 0;
		fail_count = 0;

		#10;
		RST = 1;
		#10;

		if (period_stable === 1'b0) begin
			$display("PASSED: RST");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: RST");
			fail_count = fail_count + 1;
		end

		RST = 0;
		#(period_length * 2)
		if (period_stable === 1'b1) begin
			$display("PASSED: period stable");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period stable");
			fail_count = fail_count + 1;
		end

		period_length = 10;
		#((period_length / 2.0) + 1);
		if (period_stable === 1'b0) begin
			$display("PASSED: period unstable");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period unstable");
			fail_count = fail_count + 1;
		end

		#(period_length - 1);
		if (period_stable === 1'b0) begin
			$display("PASSED: period still unstable");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period still unstable");
			fail_count = fail_count + 1;
		end

		#1;
		if (period_stable === 1'b1) begin
			$display("PASSED: period stable again");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period stable again");
			fail_count = fail_count + 1;
		end

		PWRDWN = 1;
		#10;
		if (period_stable === 1'bx) begin
			$display("PASSED: PWRDWN");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: PWRDWN");
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

	always #(period_length / 2.0) clk <= ~clk;
endmodule
