/*
 * plle2_base_tb.v: Testbench for plle2_base.v
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

/* define all attributes as macros, so different combinations can be tested
 * more easily.
 * By default these are the given default values of the part.
 */

/* not implemented */
`ifndef BANDWIDTH
	`define BANDWIDTH "OPTIMIZED"
`endif
`ifndef CLKFBOUT_MULT
	`define CLKFBOUT_MULT 1
`endif
`ifndef CLKFBOUT_PHASE
	`define CLKFBOUT_PHASE 0.000
`endif
/* This deviates from the default values, because it is required to be set */
`ifndef CLKIN1_PERIOD
	`define CLKIN1_PERIOD 10.000
`endif

`ifndef CLKOUT0_DIVIDE
	`define CLKOUT0_DIVIDE 1
`endif
`ifndef CLKOUT1_DIVIDE
	`define CLKOUT1_DIVIDE 1
`endif
`ifndef CLKOUT2_DIVIDE
	`define CLKOUT2_DIVIDE 1
`endif
`ifndef CLKOUT2_DIVIDE
	`define CLKOUT2_DIVIDE 1
`endif
`ifndef CLKOUT3_DIVIDE
	`define CLKOUT3_DIVIDE 1
`endif
`ifndef CLKOUT4_DIVIDE
	`define CLKOUT4_DIVIDE 1
`endif
`ifndef CLKOUT5_DIVIDE
	`define CLKOUT5_DIVIDE 1
`endif

`ifndef CLKOUT0_DUTY_CYCLE
	`define CLKOUT0_DUTY_CYCLE 0.500
`endif
`ifndef CLKOUT1_DUTY_CYCLE
	`define CLKOUT1_DUTY_CYCLE 0.500
`endif
`ifndef CLKOUT2_DUTY_CYCLE
	`define CLKOUT2_DUTY_CYCLE 0.500
`endif
`ifndef CLKOUT3_DUTY_CYCLE
	`define CLKOUT3_DUTY_CYCLE 0.500
`endif
`ifndef CLKOUT4_DUTY_CYCLE
	`define CLKOUT4_DUTY_CYCLE 0.500
`endif
`ifndef CLKOUT5_DUTY_CYCLE
	`define CLKOUT5_DUTY_CYCLE 0.500
`endif

`ifndef CLKOUT0_PHASE
	`define CLKOUT0_PHASE 0.000
`endif
`ifndef CLKOUT1_PHASE
	`define CLKOUT1_PHASE 0.000
`endif
`ifndef CLKOUT2_PHASE
	`define CLKOUT2_PHASE 0.000
`endif
`ifndef CLKOUT3_PHASE
	`define CLKOUT3_PHASE 0.000
`endif
`ifndef CLKOUT4_PHASE
	`define CLKOUT4_PHASE 0.000
`endif
`ifndef CLKOUT5_PHASE
	`define CLKOUT5_PHASE 0.000
`endif

`ifndef DIVCLK_DIVIDE
	`define DIVCLK_DIVIDE 1
`endif
/* not implemented */
`ifndef REF_JITTER1
	`define REF_JITTER1 0.010
`endif

/* not implemented */
`ifndef STARTUP_WAIT
	`define STARTUP_WAIT "FALSE"
`endif

module PLLE2_BASE_tb();
	wire 	CLKOUT0;
	wire 	CLKOUT1;
	wire 	CLKOUT2;
	wire 	CLKOUT3;
	wire 	CLKOUT4;
	wire 	CLKOUT5;

	wire 	CLKFBOUT;
	wire 	LOCKED;

	reg 	CLKIN1;

	reg 	PWRDWN;
	reg 	RST;
	reg 	CLKFBIN;

	integer	pass_count;
	integer	fail_count;
	/* change according to the number of test cases */
	localparam total = 23;

	reg 			reset;
	wire [31:0] 	frequency_0;
	wire [31:0] 	frequency_1;
	wire [31:0] 	frequency_2;
	wire [31:0] 	frequency_3;
	wire [31:0] 	frequency_4;
	wire [31:0] 	frequency_5;
	wire [31:0] 	frequency_fb;

	wire dcc_fail_0;
	wire dcc_fail_1;
	wire dcc_fail_2;
	wire dcc_fail_3;
	wire dcc_fail_4;
	wire dcc_fail_5;

	wire psc_fail_0;
	wire psc_fail_1;
	wire psc_fail_2;
	wire psc_fail_3;
	wire psc_fail_4;
	wire psc_fail_5;
	wire psc_fail_fb;


	/* instantiate PLLE2_BASE with default values for all the attributes */
	PLLE2_BASE #(
 		.BANDWIDTH(`BANDWIDTH),
 		.CLKFBOUT_MULT(`CLKFBOUT_MULT),
		.CLKFBOUT_PHASE(`CLKFBOUT_PHASE),
		.CLKIN1_PERIOD(`CLKIN1_PERIOD),

		.CLKOUT0_DIVIDE(`CLKOUT0_DIVIDE),
		.CLKOUT1_DIVIDE(`CLKOUT1_DIVIDE),
		.CLKOUT2_DIVIDE(`CLKOUT2_DIVIDE),
		.CLKOUT3_DIVIDE(`CLKOUT3_DIVIDE),
		.CLKOUT4_DIVIDE(`CLKOUT4_DIVIDE),
		.CLKOUT5_DIVIDE(`CLKOUT5_DIVIDE),

		.CLKOUT0_DUTY_CYCLE(`CLKOUT0_DUTY_CYCLE),
		.CLKOUT1_DUTY_CYCLE(`CLKOUT1_DUTY_CYCLE),
		.CLKOUT2_DUTY_CYCLE(`CLKOUT2_DUTY_CYCLE),
		.CLKOUT3_DUTY_CYCLE(`CLKOUT3_DUTY_CYCLE),
		.CLKOUT4_DUTY_CYCLE(`CLKOUT4_DUTY_CYCLE),
		.CLKOUT5_DUTY_CYCLE(`CLKOUT5_DUTY_CYCLE),

		.CLKOUT0_PHASE(`CLKOUT0_PHASE),
		.CLKOUT1_PHASE(`CLKOUT1_PHASE),
		.CLKOUT2_PHASE(`CLKOUT2_PHASE),
		.CLKOUT3_PHASE(`CLKOUT3_PHASE),
		.CLKOUT4_PHASE(`CLKOUT4_PHASE),
		.CLKOUT5_PHASE(`CLKOUT5_PHASE),

		.DIVCLK_DIVIDE(`DIVCLK_DIVIDE),
		.REF_JITTER1(`REF_JITTER1),
		.STARTUP_WAIT(`STARTUP_WAIT))
	dut (
		.CLKOUT0(CLKOUT0),
		.CLKOUT1(CLKOUT1),
		.CLKOUT2(CLKOUT2),
		.CLKOUT3(CLKOUT3),
		.CLKOUT4(CLKOUT4),
		.CLKOUT5(CLKOUT5),

		.CLKFBOUT(CLKFBOUT),
		.LOCKED(LOCKED),

		.CLKIN1(CLKIN1),

		.PWRDWN(PWRDWN),
		.RST(RST),
		.CLKFBIN(CLKFBIN)
	);

	frequency_counter frequency_counter_0 (
		.reset(reset),
		.LOCKED(LOCKED),
		.clk(CLKOUT0),
		.period_1000(frequency_0)
	);
	frequency_counter frequency_counter_1 (
		.reset(reset),
		.LOCKED(LOCKED),
		.clk(CLKOUT1),
		.period_1000(frequency_1)
	);
	frequency_counter frequency_counter_2 (
		.reset(reset),
		.LOCKED(LOCKED),
		.clk(CLKOUT2),
		.period_1000(frequency_2)
	);
	frequency_counter frequency_counter_3 (
		.reset(reset),
		.LOCKED(LOCKED),
		.clk(CLKOUT3),
		.period_1000(frequency_3)
	);
	frequency_counter frequency_counter_4 (
		.reset(reset),
		.LOCKED(LOCKED),
		.clk(CLKOUT4),
		.period_1000(frequency_4)
	);
	frequency_counter frequency_counter_5 (
		.reset(reset),
		.LOCKED(LOCKED),
		.clk(CLKOUT5),
		.period_1000(frequency_5)
	);
	frequency_counter frequency_counter_fb (
		.reset(reset),
		.LOCKED(LOCKED),
		.clk(CLKFBOUT),
		.period_1000(frequency_fb)
	);

	duty_cycle_check #(
		.desired_duty_cycle(`CLKOUT0_DUTY_CYCLE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT0_DIVIDE) / `CLKFBOUT_MULT)))
	dcc0 (
		.clk(CLKOUT0),
		.reset(reset),
		.LOCKED(LOCKED),
		.fail(dcc_fail_0));
	duty_cycle_check #(
		.desired_duty_cycle(`CLKOUT1_DUTY_CYCLE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT1_DIVIDE) / `CLKFBOUT_MULT)))
	dcc1 (
		.clk(CLKOUT1),
		.reset(reset),
		.LOCKED(LOCKED),
		.fail(dcc_fail_1));
	duty_cycle_check #(
		.desired_duty_cycle(`CLKOUT2_DUTY_CYCLE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT2_DIVIDE) / `CLKFBOUT_MULT)))
	dcc2 (
		.clk(CLKOUT2),
		.reset(reset),
		.LOCKED(LOCKED),
		.fail(dcc_fail_2));
	duty_cycle_check #(
		.desired_duty_cycle(`CLKOUT3_DUTY_CYCLE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT3_DIVIDE) / `CLKFBOUT_MULT)))
	dcc3 (
		.clk(CLKOUT3),
		.reset(reset),
		.LOCKED(LOCKED),
		.fail(dcc_fail_3));
	duty_cycle_check #(
		.desired_duty_cycle(`CLKOUT4_DUTY_CYCLE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT4_DIVIDE) / `CLKFBOUT_MULT)))
	dcc4 (
		.clk(CLKOUT4),
		.reset(reset),
		.LOCKED(LOCKED),
		.fail(dcc_fail_4));
	duty_cycle_check #(
		.desired_duty_cycle(`CLKOUT5_DUTY_CYCLE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT5_DIVIDE) / `CLKFBOUT_MULT)))
	dcc5 (
		.clk(CLKOUT5),
		.reset(reset),
		.LOCKED(LOCKED),
		.fail(dcc_fail_5));

	phase_shift_check #(
		.desired_shift(`CLKOUT0_PHASE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT0_DIVIDE) / `CLKFBOUT_MULT)))
	psc0 (
		.clk_shifted(CLKOUT0),
		.clk(CLKFBOUT),
		.rst(RST),
		.LOCKED(LOCKED),
		.fail(psc_fail_0));
	phase_shift_check #(
		.desired_shift(`CLKOUT1_PHASE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT1_DIVIDE) / `CLKFBOUT_MULT)))
	psc1 (
		.clk_shifted(CLKOUT1),
		.clk(CLKFBOUT),
		.rst(RST),
		.LOCKED(LOCKED),
		.fail(psc_fail_1));
	phase_shift_check #(
		.desired_shift(`CLKOUT2_PHASE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT2_DIVIDE) / `CLKFBOUT_MULT)))
	psc2 (
		.clk_shifted(CLKOUT2),
		.clk(CLKFBOUT),
		.rst(RST),
		.LOCKED(LOCKED),
		.fail(psc_fail_2));
	phase_shift_check #(
		.desired_shift(`CLKOUT3_PHASE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT3_DIVIDE) / `CLKFBOUT_MULT)))
	psc3 (
		.clk_shifted(CLKOUT3),
		.clk(CLKFBOUT),
		.rst(RST),
		.LOCKED(LOCKED),
		.fail(psc_fail_3));
	phase_shift_check #(
		.desired_shift(`CLKOUT4_PHASE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT4_DIVIDE) / `CLKFBOUT_MULT)))
	psc4 (
		.clk_shifted(CLKOUT4),
		.clk(CLKFBOUT),
		.rst(RST),
		.LOCKED(LOCKED),
		.fail(psc_fail_4));
	phase_shift_check #(
		.desired_shift(`CLKOUT5_PHASE),
		.clk_period(`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT5_DIVIDE) / `CLKFBOUT_MULT)))
	psc5 (
		.clk_shifted(CLKOUT5),
		.clk(CLKFBOUT),
		.rst(RST),
		.LOCKED(LOCKED),
		.fail(psc_fail_5));
	phase_shift_check #(
		.desired_shift(`CLKFBOUT_PHASE),
		.clk_period(`CLKIN1_PERIOD * (`DIVCLK_DIVIDE / `CLKFBOUT_MULT)))
	pscfb (
		.clk_shifted(CLKFBOUT),
		.clk(CLKIN1),
		.rst(RST),
		.LOCKED(LOCKED),
		.fail(psc_fail_fb));

/* ------------ BEGIN TEST CASES ------------- */

	initial begin
		$dumpfile("plle2_base_tb.vcd");
		$dumpvars(0, PLLE2_BASE_tb);

		pass_count = 0;
		fail_count = 0;
		reset = 0;

		CLKIN1 = 0;
		RST = 0;
		PWRDWN = 0;
		#10;
		reset = 1;
		RST = 1;
		#10;
		if ((CLKOUT0 & CLKOUT1 & CLKOUT2 & CLKOUT3 & CLKOUT4 & CLKOUT5 & CLKFBOUT & LOCKED) == 0) begin
			$display("PASSED: RST signal");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: RST signal");
			fail_count = fail_count + 1;
		end
		reset = 0;
		RST = 0;
		/* Test for correct number of highs for the given parameters.
		 * This is down for all six outputs and the feedback output.
		 */
		#`WAIT_INTERVAL;

		if (LOCKED === 1'b1) begin
			$display("PASSED: LOCKED");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: LOCKED");
			fail_count = fail_count + 1;
		end


		/*------- FREQUENCY ---------*/
		if ((frequency_0 / 1000.0)  == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT0_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKOUT0 frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT0 frequency");
			fail_count = fail_count + 1;
		end

		if ((frequency_1 / 1000.0)  == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT1_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKOUT1 frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT1 frequency %0f, %0f", frequency_1, (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT1_DIVIDE * 1.0) / `CLKFBOUT_MULT)));
			fail_count = fail_count + 1;
		end

		if ((frequency_2 / 1000.0)  == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT2_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKOUT2 frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT2 frequency");
			fail_count = fail_count + 1;
		end

		if ((frequency_3 / 1000.0)  == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT3_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKOUT3 frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT3 frequency");
			fail_count = fail_count + 1;
		end

		if ((frequency_4 / 1000.0) == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT4_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKOUT4 frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT4 frequency");
			fail_count = fail_count + 1;
		end

		if ((frequency_5 / 1000.0)  == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * `CLKOUT5_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKOUT5 frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT5 frequency");
			fail_count = fail_count + 1;
		end

		if ((frequency_fb / 1000.0) == (`CLKIN1_PERIOD * ((`DIVCLK_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKFBOUT frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKFBOUT frequency");
			fail_count = fail_count + 1;
		end


		/*------- DUTY CYCLE ---------*/
		if (dcc_fail_0 !== 1'b1) begin
			$display("PASSED: CLKOUT0 duty cycle");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT0 duty cycle");
			fail_count = fail_count + 1;
		end

		if (dcc_fail_1 !== 1'b1) begin
			$display("PASSED: CLKOUT1 duty cycle");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT1 duty cycle");
			fail_count = fail_count + 1;
		end

		if (dcc_fail_2 !== 1'b1) begin
			$display("PASSED: CLKOUT2 duty cycle");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT2 duty cycle");
			fail_count = fail_count + 1;
		end

		if (dcc_fail_3 !== 1'b1) begin
			$display("PASSED: CLKOUT3 duty cycle");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT3 duty cycle");
			fail_count = fail_count + 1;
		end

		if (dcc_fail_4 !== 1'b1) begin
			$display("PASSED: CLKOUT4 duty cycle");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT4 duty cycle");
			fail_count = fail_count + 1;
		end

		if (dcc_fail_5 !== 1'b1) begin
			$display("PASSED: CLKOUT5 duty cycle");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT5 duty cycle");
			fail_count = fail_count + 1;
		end


		/*------- PHASE SHIFT ---------*/
		if (psc_fail_0 !== 1'b1) begin
			$display("PASSED: CLKOUT0 phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT0 phase shift");
			fail_count = fail_count + 1;
		end

		if (psc_fail_1 !== 1'b1) begin
			$display("PASSED: CLKOUT1 phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT1 phase shift");
			fail_count = fail_count + 1;
		end

		if (psc_fail_2 !== 1'b1) begin
			$display("PASSED: CLKOUT2 phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT2 phase shift");
			fail_count = fail_count + 1;
		end

		if (psc_fail_3 !== 1'b1) begin
			$display("PASSED: CLKOUT3 phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT3 phase shift");
			fail_count = fail_count + 1;
		end

		if (psc_fail_4 !== 1'b1) begin
			$display("PASSED: CLKOUT4 phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT4 phase shift");
			fail_count = fail_count + 1;
		end

		if (psc_fail_5 !== 1'b1) begin
			$display("PASSED: CLKOUT5 phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUT5 phase shift");
			fail_count = fail_count + 1;
		end

		if (psc_fail_fb !== 1'b1) begin
			$display("PASSED: CLKOUTFB phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKOUTFB phase shift");
			fail_count = fail_count + 1;
		end


		PWRDWN = 1;
		#100;
		if ((CLKOUT0 & CLKOUT1 & CLKOUT2 & CLKOUT3 & CLKOUT4 & CLKOUT5 & CLKFBOUT) === 1'bx) begin
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

	/* connect CLKFBIN with CLKFBOUT to use internal feedback */
	always @(posedge CLKFBOUT or negedge CLKFBOUT) begin
		CLKFBIN <= CLKFBOUT;
	end

	always #(`CLKIN1_PERIOD / 2) CLKIN1 = ~CLKIN1;
endmodule


/* counts all the highs of the input signal */
module frequency_counter #(
	parameter RESOLUTION = 0.01) (
	input	clk,
	input 	reset,
	input	LOCKED,

	output reg [31:0] period_1000);

	reg [31:0] count;

	always begin
		#0.001;
		if (reset) begin
			count <= 0;
		end else begin
			count <= count + 1;
		end
		#(RESOLUTION - 0.001);
	end

	always @(posedge clk) begin
		period_1000 <= (count * RESOLUTION * 1000);
		count <= 0;
	end
endmodule

/* checks the duty cycle of the input signal */
module duty_cycle_check (
	input clk,
	input reset,
	input LOCKED,

	/* 0 - clk duty cycle matches desired_duty_cycle
	 * 1 - clk duty cycle does not match the desired_duty_cycle
	 */
	output reg fail);

	/* duty cycle as decimal (0.5 for 50 % in high) */
	parameter desired_duty_cycle = 0.5;
	parameter clk_period = 10;

	always @(posedge clk or posedge reset) begin
		if (!reset && LOCKED) begin
			#((clk_period * desired_duty_cycle) - 1);
			if (clk != 1) begin
				fail <= 1;
			end
			#2;
			if (clk != 0) begin
				fail <= 1;
			end
		end else begin
			fail <= 0;
		end
	end
endmodule

/* checks the phase shift of the input signal in relation to clk */
module phase_shift_check #(
	parameter desired_shift = 0,
	parameter clk_period = 10) (
	input clk_shifted,
	input clk,
	input rst,
	input LOCKED,
	output reg fail);

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			fail <= 0;
		end else if (LOCKED) begin
			if (desired_shift >= 0) begin
				#((desired_shift * (clk_period / 360.0)) - 0.1);
				if (clk_shifted != 0) begin
					fail <= 1;
				end
			end else begin
				#((clk_period + (desired_shift * (clk_period / 360.0))) - 0.1);
				if (clk_shifted != 0) begin
					fail <= 1;
				end
			end

			#0.2;
			if (clk_shifted != 1) begin
				fail <= 1;
			end
		end
	end
endmodule
