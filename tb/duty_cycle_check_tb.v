/*
 * duty_cycle_check_tb.v: Test bench for duty_cycle_check.v
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

`ifndef DESIRED_DUTY_CYCLE
	`define DESIRED_DUTY_CYCLE 0.5
`endif

`ifndef CLK_PERIOD
	`define CLK_PERIOD 10
`endif

module duty_cycle_check_tb ();
	reg rst;
	reg clk;
	reg LOCKED;

	wire fail;

	reg [31:0]  duty_cycle_1000;

	integer pass_count;
	integer fail_count;

	/* adjust according to the number of test cases */
	localparam total = 4;

	duty_cycle_check #(
		.desired_duty_cycle(`DESIRED_DUTY_CYCLE),
		.clk_period(`CLK_PERIOD))
	dut (
		.clk(clk),
		.reset(rst),
		.LOCKED(LOCKED),
		.fail(fail));

	initial begin
		$dumpfile("duty_cycle_check_tb.vcd");
		$dumpvars(0, duty_cycle_check_tb);

		duty_cycle_1000 = 1000 * `DESIRED_DUTY_CYCLE;

		rst = 0;
		clk = 0;
		LOCKED = 0;

		pass_count = 0;
		fail_count = 0;

		#1;
		clk = 1;
		#10;
		rst = 1;
		#10;

		if (fail == 1'b0) begin
			$display("PASSED: reset");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: reset");
			fail_count = fail_count + 1;
		end

		rst = 0;
		#(`CLK_PERIOD * 3);

		if (fail == 1'b0) begin
			$display("PASSED: LOCKED");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: LOCKED");
			fail_count = fail_count + 1;
		end

		LOCKED = 1;
		#`WAIT_INTERVAL;

		if (fail == 1'b0) begin
			$display("PASSED: duty cycle matches");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle matches");
			fail_count = fail_count + 1;
		end

		duty_cycle_1000 = duty_cycle_1000 - 100;
		#`WAIT_INTERVAL;

		if (fail == 1'b1) begin
			$display("PASSED: duty cycle differs");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: duty cycle differs");
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

	always @(posedge clk) begin
		#(`CLK_PERIOD * (duty_cycle_1000 / 1000.0)) clk <= ~clk;
	end
	always @(negedge clk) begin
		#(`CLK_PERIOD * (1 - (duty_cycle_1000 / 1000.0))) clk <= ~clk;
	end
endmodule
