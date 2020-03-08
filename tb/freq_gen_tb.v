/*
 * freq_gen_tb.v: Test bench for freq_gen.v
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

`ifndef M
	`define M 1
`endif

`ifndef D
	`define D 1
`endif

`ifndef O_1000
	`define O_1000 1000
`endif

module freq_gen_tb ();
	reg	RST;
	reg PWRDWN;
	reg period_stable;
	reg [31:0] ref_period_length;
	reg clk;

	wire out;
	wire [31:0] out_period_length_1000;

	/* resets the high counter module used for frequency checks */
	wire [31:0] highs_counted;
	integer	pass_count;
	integer	fail_count;

	/* adjust according to the number of test cases */
	localparam total = 5;

	freq_gen dut (
		.M(`M),
		.D(`D),
		.O_1000(`O_1000),
		.RST(RST),
		.PWRDWN(PWRDWN),
		.ref_period(ref_period_length),
		.clk(clk),
		.out(out),
		.out_period_length_1000(out_period_length_1000),
		.period_stable(period_stable));

	high_counter high_counter (
		.clk(out),
		.rst(~period_stable),
		.count(highs_counted));


	initial begin
		$dumpfile("freq_gen_tb.vcd");
		$dumpvars(0, freq_gen_tb);

		RST = 0;
		PWRDWN = 0;
		period_stable = 0;
		clk = 0;
		ref_period_length = 20;

		pass_count = 0;
		fail_count = 0;

		#10;
		RST = 1;
		#10;

		if (out === 1'b0) begin
			$display("PASSED: RST");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: RST");
			fail_count = fail_count + 1;
		end

		period_stable = 1;
		RST = 0;
		#(ref_period_length + 11);
		if (out === 1'b1) begin
			$display("PASSED: rising edge detection");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: rising edge detection");
			fail_count = fail_count + 1;
		end

		#(`WAIT_INTERVAL - (ref_period_length + 11));
		/* use 1.0 to calculate floating point numbers */
		if ($floor(`WAIT_INTERVAL / highs_counted) == $floor(ref_period_length * ((`D * (`O_1000 / 1000.0) * 1.0) / `M))) begin
			$display("PASSED: ref period = 20");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: ref period = 20");
			fail_count = fail_count + 1;
		end

		period_stable = 0;
		ref_period_length = 10;
		#`WAIT_INTERVAL;
		period_stable = 1;
		#`WAIT_INTERVAL;
		if ($floor((`WAIT_INTERVAL + ref_period_length) / highs_counted) == $floor(ref_period_length * ((`D * (`O_1000 / 1000.0) * 1.0) / `M))) begin
			$display("PASSED: ref period = 10");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: ref period = 10");
			fail_count = fail_count + 1;
		end

		if ($floor((`WAIT_INTERVAL + ref_period_length) / highs_counted) == $floor(out_period_length_1000 / 1000.0)) begin
			$display("PASSED: period length output");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: period length output");
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

	always #(ref_period_length / 2.0) clk <= ~clk;
endmodule
