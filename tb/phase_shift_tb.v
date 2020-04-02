/*
 * phase_shift_tb.v: Testbench for phase_shift.v
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

module phase_shift_tb ();
	reg	rst;
	reg PWRDWN;
	reg clk;
	reg signed [31:0] shift_1000;
	reg	[31:0] clk_period_1000;
	reg [6:0] duty_cycle;

	wire lock;
	wire clk_shifted;

	reg	shift_fail;
	reg duty_cycle_fail;

	integer	pass_count;
	integer	fail_count;
	/* adjust according to the number of testcases */
	localparam total = 17;

	phase_shift dut(
		.RST(rst),
		.PWRDWN(PWRDWN),
		.clk(clk),
		.shift_1000(shift_1000),
		.clk_period_1000(clk_period_1000),
		.duty_cycle(duty_cycle),
		.lock(lock),
		.clk_shifted(clk_shifted));

	initial begin
		$dumpfile("phase_shift_tb.vcd");
		$dumpvars(0, phase_shift_tb);

		rst = 0;
		PWRDWN = 0;
		clk = 0;
		clk_period_1000 = 20000;

		shift_1000 = 10 * 1000;
		duty_cycle = 50;

		pass_count = 0;
		fail_count = 0;

		#10;
		if (lock === 1'bx) begin
			$display("PASSED: lock should not be set before first reset");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: lock should not be set before first reset");
			fail_count = fail_count + 1;
		end

		rst = 1;
		#10;

		if (clk_shifted === 1'b0 && lock === 1'b0) begin
			$display("PASSED: rst");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: rst");
			fail_count = fail_count + 1;
		end

		rst = 0;
		#`WAIT_INTERVAL;
		shift_fail = 0;
		#`WAIT_INTERVAL;
		if (!shift_fail && lock) begin
			$display("PASSED: shift = 10°");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: shift = 10°");
			fail_count = fail_count + 1;
		end

		shift_1000 = 182 * 1000;
		clk_period_1000 = 5000;
		#`WAIT_INTERVAL;
		shift_fail = 0;
		#`WAIT_INTERVAL;
		if (!shift_fail && lock) begin
			$display("PASSED: shift = 182°");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: shift = 182°");
			fail_count = fail_count + 1;
		end

		shift_1000 = 181 * 1000;
		#`WAIT_INTERVAL;
		shift_fail = 0;
		#`WAIT_INTERVAL;
		if (!shift_fail && lock) begin
			$display("PASSED: shift = 181°");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: shift = 181°");
			fail_count = fail_count + 1;
		end

		shift_1000 = 180 * 1000;
		#`WAIT_INTERVAL;
		shift_fail = 0;
		#`WAIT_INTERVAL;
		if (!shift_fail && lock) begin
			$display("PASSED: shift = 180°");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: shift = 180°");
			fail_count = fail_count + 1;
		end

		shift_1000 = 360 * 1000;
		#`WAIT_INTERVAL;
		shift_fail = 0;
		#`WAIT_INTERVAL;
		if (!shift_fail && lock) begin
			$display("PASSED: shift = 360°");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: shift = 360°");
			fail_count = fail_count + 1;
		end

		shift_1000 = -10 * 1000;
		#`WAIT_INTERVAL;
		shift_fail = 0;
		#`WAIT_INTERVAL;
		if (!shift_fail && lock) begin
			$display("PASSED: shift = -10°");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: shift = -10°");
			fail_count = fail_count + 1;
		end

		clk_period_1000 = 1000;
		shift_1000 = 0;
		duty_cycle = 50;
		#`WAIT_INTERVAL;
		shift_fail = 0;
		#`WAIT_INTERVAL;
		if (!shift_fail && lock) begin
			$display("PASSED: shift = 0°, clk period = 1");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: shift = 0°, clk period = 1");
			fail_count = fail_count + 1;
		end

		clk_period_1000 = 5000;
		#40;
		shift_1000 = 0;
		duty_cycle_fail = 0;
		duty_cycle = 1;
		#`WAIT_INTERVAL;
		if (!duty_cycle_fail && lock) begin
			$display("PASSED: duty cycle = 1%");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle = 1%");
			fail_count = fail_count + 1;
		end

		duty_cycle_fail = 0;
		duty_cycle = 10;
		#`WAIT_INTERVAL;
		if (!duty_cycle_fail && lock) begin
			$display("PASSED: duty cycle = 10%");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle = 10%");
			fail_count = fail_count + 1;
		end

		duty_cycle_fail = 0;
		duty_cycle = 49;
		#`WAIT_INTERVAL;
		if (!duty_cycle_fail && lock) begin
			$display("PASSED: duty cycle = 49%");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle = 49%");
			fail_count = fail_count + 1;
		end

		duty_cycle_fail = 0;
		duty_cycle = 50;
		#`WAIT_INTERVAL;
		if (!duty_cycle_fail && lock) begin
			$display("PASSED: duty cycle = 50%");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle = 50%");
			fail_count = fail_count + 1;
		end

		duty_cycle_fail = 0;
		duty_cycle = 51;
		#`WAIT_INTERVAL;
		if (!duty_cycle_fail && lock) begin
			$display("PASSED: duty cycle = 51%");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle = 51%");
			fail_count = fail_count + 1;
		end

		duty_cycle_fail = 0;
		duty_cycle = 90;
		#`WAIT_INTERVAL;
		if (!duty_cycle_fail && lock) begin
			$display("PASSED: duty cycle = 90%");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle = 90%");
			fail_count = fail_count + 1;
		end

		duty_cycle_fail = 0;
		duty_cycle = 99;
		#`WAIT_INTERVAL;
		if (!duty_cycle_fail && lock) begin
			$display("PASSED: duty cycle = 99%");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle = 99%");
			fail_count = fail_count + 1;
		end

		PWRDWN = 1'b1;
		#((clk_period_1000 / 2000.0) + 1);
		if (clk_shifted === 1'bx && lock === 1'bx) begin
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

	always #((clk_period_1000 / 1000.0) / 2.0) clk <= ~clk;

	/* check if the phase shift failed */
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			shift_fail <= 0;
		end else begin
			if (shift_1000 >= 0) begin
				#(((shift_1000 / 1000.0) * ((clk_period_1000 / 1000.0) / 360.0)) - 0.1);
				if (clk_shifted != 0) begin
					shift_fail <= 1;
				end
			end else begin
				#(((clk_period_1000 / 1000.0) + ((shift_1000 / 1000.0) * ((clk_period_1000 / 1000.0) / 360.0))) - 0.1);
				if (clk_shifted != 0) begin
					shift_fail <= 1;
				end
			end

			#0.2;
			if (clk_shifted != 1) begin
				shift_fail <= 1;
			end
		end
	end

	/* check if duty cycle is correct */

	always @(posedge clk_shifted or posedge rst) begin
		if (rst) begin
			duty_cycle_fail <= 0;
		end else begin
			#(((clk_period_1000 / 1000.0) * (duty_cycle / 100.0)) - 0.1);
			if (clk_shifted != 1) begin
				duty_cycle_fail <= 1;
			end
			#0.2;
			if (clk != 0) begin
				duty_cycle_fail <= 1;
			end
		end
	end

endmodule
