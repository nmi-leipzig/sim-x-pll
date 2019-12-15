/*
 * high_counter_tb.v: Testbench for high_counter.v
 * author: Till Mahlburg
 * year: 2019
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps
`ifndef WAIT_INTERVAL
	`define WAIT_INTERVAL 1000
`endif

module high_counter_tb ();
	reg clk;
	reg rst;

	wire [31:0] count;

	integer pass_count;
	integer fail_count;
	/* change according to the number of test cases */
	localparam total = 3;

	integer clk_period;

	high_counter dut (
		.clk(clk),
		.rst(rst),
		.count(count));

	initial begin
		$dumpfile("high_counter_tb.vcd");
		$dumpvars(0, high_counter_tb);

		rst = 0;
		clk = 0;
		clk_period = 10;

		pass_count = 0;
		fail_count = 0;

		#10;
		rst = 1;
		#10;
		if (count === 0) begin
			$display("PASSED: rst");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: rst");
			fail_count = fail_count + 1;
		end

		rst = 0;
		#`WAIT_INTERVAL
		if (count == (`WAIT_INTERVAL / clk_period)) begin
			$display("PASSED: correct count");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: correct count");
			fail_count = fail_count + 1;
		end
		rst = 1;
		#10;
		clk_period = 100;
		clk = 0;
		rst = 0;
		#`WAIT_INTERVAL
		if (count == (`WAIT_INTERVAL / clk_period)) begin
			$display("PASSED: correct count after changing clk");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: correct count after changing clk");
			fail_count = fail_count + 1;
		end

		if (pass_count + fail_count == total) begin
			$display("PASSED: correct number of test cases");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: correct number of test cases");
			fail_count = fail_count + 1;
		end

		$display("%0d/%0d PASSED", pass_count, (total + 1));
		$finish;
	end

	always #(clk_period / 2) clk = ~clk;
endmodule
