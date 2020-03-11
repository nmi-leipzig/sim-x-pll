/*
 * plle2_adv_tb.v: Testbench for plle2_adv.v
 * author: Till Mahlburg
 * year: 2019-2020
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

/* define all attributes as macros, so different combinations can be tested
 * more easily.
 * By default these are the given default values of the part.
 */

/* not implemented */
`ifndef WAIT_INTERVAL
	`define WAIT_INTERVAL 1000
`endif
`ifndef BANDWIDTH
	`define BANDWIDTH "OPTIMIZED"
`endif
`ifndef CLKFBOUT_MULT
	`define CLKFBOUT_MULT 5
`endif
`ifndef CLKFBOUT_PHASE
	`define CLKFBOUT_PHASE 0.000
`endif
/* This deviates from the default values, because it is required to be set */
`ifndef CLKIN1_PERIOD
	`define CLKIN1_PERIOD 5.000
`endif
`ifndef CLKIN2_PERIOD
	`define CLKIN2_PERIOD 4.000
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
/* not inplemented */
`ifndef REF_JITTER2
	`define REF_JITTER2 0.010
`endif

/* not implemented */
`ifndef STARTUP_WAIT
	`define STARTUP_WAIT "FALSE"
`endif

/* not implemented */
`ifndef COMPENSATION
	`define COMPENSATION "ZHOLD"
`endif


/* set two DADDR and two DI to test the dynamic reconfiguration */
`ifndef DADDR1
	`define DADDR1 7'h08
`endif

`ifndef DADDR2
	`define DADDR2 7'h09
`endif

`ifndef DI1
	`define DI1 16'b011_0_000110_000011
`endif

`ifndef DI2
	`define DI2 16'b0_000_0_0_00_0_0_00011
`endif

`ifndef DCLK_PERIOD
	`define DCLK_PERIOD 2
`endif


module PLLE2_ADV_tb();
	wire CLKOUT[0:5];

	wire CLKFBOUT;
	wire LOCKED;

	reg CLKIN1;
	reg	CLKIN2;
	reg	CLKINSEL;

	reg PWRDWN;
	reg RST;
	wire CLKFBIN;

	reg [6:0] DADDR;
	reg	DCLK;
	reg	DEN;
	reg	DWE;
	reg	[15:0] DI;

	wire [15:0] DO;
	wire DRDY;

	integer	pass_count;
	integer	fail_count;
	/* change according to the number of test cases */
	localparam total = 47;

	reg reset;
	wire [31:0] period_1000[0:5];
	wire [31:0] period_1000_fb;

	wire dcc_fail[0:5];
	wire dcc_fail_fb;

	wire psc_fail[0:5];
	wire psc_fail_fb;

	reg [31:0] CLKOUT_DIVIDE[0:5];
	reg [31:0] CLKOUT_DUTY_CYCLE_1000[0:5];
	reg [31:0] CLKOUT_PHASE_1000[0:5];

	reg [31:0] CLKFBOUT_MULT;
	reg [31:0] CLKFBOUT_PHASE;
	reg [31:0] DIVCLK_DIVIDE;

	/* instantiate PLLE2_ADV with default values for all the attributes */
	PLLE2_ADV #(
 		.BANDWIDTH(`BANDWIDTH),
 		.CLKFBOUT_MULT(`CLKFBOUT_MULT),
		.CLKFBOUT_PHASE(`CLKFBOUT_PHASE),
		.CLKIN1_PERIOD(`CLKIN1_PERIOD),
		.CLKIN2_PERIOD(`CLKIN2_PERIOD),

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
		.REF_JITTER2(`REF_JITTER2),
		.STARTUP_WAIT(`STARTUP_WAIT),
		.COMPENSATION(`COMPENSATION))
	dut (
		.CLKOUT0(CLKOUT[0]),
		.CLKOUT1(CLKOUT[1]),
		.CLKOUT2(CLKOUT[2]),
		.CLKOUT3(CLKOUT[3]),
		.CLKOUT4(CLKOUT[4]),
		.CLKOUT5(CLKOUT[5]),

		.CLKFBOUT(CLKFBOUT),
		.LOCKED(LOCKED),

		.CLKIN1(CLKIN1),
		.CLKIN2(CLKIN2),
		.CLKINSEL(CLKINSEL),

		.PWRDWN(PWRDWN),
		.RST(RST),
		.CLKFBIN(CLKFBIN),

		.DADDR(DADDR),
		.DCLK(DCLK),
		.DEN(DEN),
		.DWE(DWE),
		.DI(DI),

		.DO(DO),
		.DRDY(DRDY)
	);

	genvar i;
	generate
		for (i = 0; i <= 5; i = i + 1) begin : period_count
			period_count period_count (
				.RST(reset),
				.clk(CLKOUT[i]),
				.period_length_1000(period_1000[i]));
		end

		for (i = 0; i <= 5; i = i + 1) begin : dcc
			duty_cycle_check dcc (
				.desired_duty_cycle_1000(CLKOUT_DUTY_CYCLE_1000[i]),
				.clk_period_1000((`CLKIN1_PERIOD * ((DIVCLK_DIVIDE * CLKOUT_DIVIDE[i]) / CLKFBOUT_MULT)) * 1000),
				.clk(CLKOUT[i]),
				.reset(reset),
				.LOCKED(LOCKED),
				.fail(dcc_fail[i]));
		end

		for (i = 0; i <= 5; i = i + 1) begin : psc
			phase_shift_check psc (
				.desired_shift_1000(CLKOUT_PHASE_1000[i]),
				.clk_period_1000(1000 * `CLKIN1_PERIOD * ((DIVCLK_DIVIDE * CLKOUT_DIVIDE[i]) / CLKFBOUT_MULT)),
				.clk_shifted(CLKOUT[i]),
				.clk(CLKFBOUT),
				.rst(RST),
				.LOCKED(LOCKED),
				.fail(psc_fail[i]));
		end
	endgenerate

	period_count period_count_fb (
		.RST(reset),
		.clk(CLKFBOUT),
		.period_length_1000(period_1000_fb));

	phase_shift_check pscfb (
		.desired_shift_1000(CLKFBOUT_PHASE * 1000),
		.clk_period_1000(`CLKIN1_PERIOD * (DIVCLK_DIVIDE / CLKFBOUT_MULT) * 1000),
		.clk_shifted(CLKFBOUT),
		.clk(CLKIN1),
		.rst(RST),
		.LOCKED(LOCKED),
		.fail(psc_fail_fb));

/* ------------ BEGIN TEST CASES ------------- */
	/* default loop variable */
	integer k;

	initial begin
		$dumpfile("plle2_adv_tb.vcd");
		$dumpvars(0, PLLE2_ADV_tb);

		pass_count = 0;
		fail_count = 0;
		reset = 0;

		CLKINSEL = 0;
		CLKIN1 = 0;
		CLKIN2 = 0;
		RST = 0;
		PWRDWN = 0;

		/* set up initial values */
		CLKOUT_DIVIDE[0] = `CLKOUT0_DIVIDE;
		CLKOUT_DIVIDE[1] = `CLKOUT1_DIVIDE;
		CLKOUT_DIVIDE[2] = `CLKOUT2_DIVIDE;
		CLKOUT_DIVIDE[3] = `CLKOUT3_DIVIDE;
		CLKOUT_DIVIDE[4] = `CLKOUT4_DIVIDE;
		CLKOUT_DIVIDE[5] = `CLKOUT5_DIVIDE;

		CLKOUT_DUTY_CYCLE_1000[0] = (`CLKOUT0_DUTY_CYCLE * 1000);
		CLKOUT_DUTY_CYCLE_1000[1] = (`CLKOUT1_DUTY_CYCLE * 1000);
		CLKOUT_DUTY_CYCLE_1000[2] = (`CLKOUT2_DUTY_CYCLE * 1000);
		CLKOUT_DUTY_CYCLE_1000[3] = (`CLKOUT3_DUTY_CYCLE * 1000);
		CLKOUT_DUTY_CYCLE_1000[4] = (`CLKOUT4_DUTY_CYCLE * 1000);
		CLKOUT_DUTY_CYCLE_1000[5] = (`CLKOUT5_DUTY_CYCLE * 1000);

		CLKOUT_PHASE_1000[0] = (`CLKOUT0_PHASE * 1000);
		CLKOUT_PHASE_1000[1] = (`CLKOUT1_PHASE * 1000);
		CLKOUT_PHASE_1000[2] = (`CLKOUT2_PHASE * 1000);
		CLKOUT_PHASE_1000[3] = (`CLKOUT3_PHASE * 1000);
		CLKOUT_PHASE_1000[4] = (`CLKOUT4_PHASE * 1000);
		CLKOUT_PHASE_1000[5] = (`CLKOUT5_PHASE * 1000);

		CLKFBOUT_MULT = `CLKFBOUT_MULT;
		CLKFBOUT_PHASE = `CLKFBOUT_PHASE;
		DIVCLK_DIVIDE = `DIVCLK_DIVIDE;

		DADDR = 7'h00;
		DI = 16'h0000;
		DEN = 1'b0;
		DWE = 1'b0;
		DCLK = 1'b0;

		#10;
		reset = 1;
		RST = 1;
		#10;
		if ((CLKOUT[0] & CLKOUT[1] & CLKOUT[2] & CLKOUT[3] & CLKOUT[4] & CLKOUT[5] & CLKFBOUT & LOCKED) == 0) begin
			$display("PASSED: RST signal");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: RST signal");
			fail_count = fail_count + 1;
		end
		reset = 0;
		RST = 0;
		#`WAIT_INTERVAL;

		if (LOCKED === 1'b1) begin
			$display("PASSED: LOCKED");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: LOCKED");
			fail_count = fail_count + 1;
		end

		/*------ CLKIN SELECTION --- */
		if ((period_1000_fb / 1000.0) == (`CLKIN2_PERIOD * ((`DIVCLK_DIVIDE * 1.0) / `CLKFBOUT_MULT))) begin
			$display("PASSED: CLKIN2 selection");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKIN2 selection");
			fail_count = fail_count + 1;
		end

		/* switch clock back to 1 */
		CLKINSEL = 1;
		reset = 1;
		#(`WAIT_INTERVAL / 10);
		reset = 0;
		#`WAIT_INTERVAL;

		/*------- FREQUENCY ---------*/
		for (k = 0; k <= 5; k = k + 1) begin
			if ((period_1000[k] / 1000.0 == `CLKIN1_PERIOD * ((DIVCLK_DIVIDE * CLKOUT_DIVIDE[k] * 1.0) / CLKFBOUT_MULT))) begin
				$display("PASSED: CLKOUT%0d frequency", k);
				pass_count = pass_count + 1;
			end else begin
				$display("FAILED: CLKOUT%0d frequency", k);
				fail_count = fail_count + 1;
			end
		end

		if ((period_1000_fb / 1000.0) == (`CLKIN1_PERIOD * ((DIVCLK_DIVIDE * 1.0) / CLKFBOUT_MULT))) begin
			$display("PASSED: CLKFBOUT frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKFBOUT frequency");
			fail_count = fail_count + 1;
		end


		/*------- DUTY CYCLE ---------*/
		for (k = 0; k <= 5; k = k + 1) begin
			if (dcc_fail[k] !== 1'b1) begin
				$display("PASSED: CLKOUT%0d duty cycle", k);
				pass_count = pass_count + 1;
			end else begin
				$display("FAILED: CLKOUT%0d duty cycle", k);
				fail_count = fail_count + 1;
			end
		end

		/*------- PHASE SHIFT ---------*/
		for (k = 0; k <= 5; k = k + 1) begin
			if (psc_fail[k] !== 1'b1) begin
				$display("PASSED: CLKOUT%0d phase shift", k);
				pass_count = pass_count + 1;
			end else begin
				$display("FAILED: CLKOUT%0d phase shift", k);
				fail_count = fail_count + 1;
			end
		end

		if (psc_fail_fb !== 1'b1) begin
			$display("PASSED: CLKFBOUT phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKFBOUT phase shift");
			fail_count = fail_count + 1;
		end

		/*------- DYNAMIC RECONFIGURATION ---------*/
		if (DRDY == 1'b1) begin
			$display("PASSED: DRDY high");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: DRDY high");
			fail_count = fail_count + 1;
		end

		DADDR = `DADDR1;
		DI = `DI1;
		DEN = 1'b1;
		DWE = 1'b1;
		#`DCLK_PERIOD;

		if (DRDY == 1'b0) begin
			$display("PASSED: DRDY low");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: DRDY low");
			fail_count = fail_count + 1;
		end

		DWE = 1'b0;
		DEN = 1'b0;
		#(`DCLK_PERIOD * 2);

		DEN = 1'b1;
		#(`DCLK_PERIOD * 2);

		if (DO == DI) begin
			$display("PASSED: DO");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: DO");
			fail_count = fail_count + 1;
		end

		DEN = 1'b0;
		#(`DCLK_PERIOD * 2);
		DADDR = `DADDR2;
		DI = `DI2;
		DEN = 1'b1;
		DWE = 1'b1;
		#(`DCLK_PERIOD * 2);
		DEN = 1'b0;
		DWE = 1'b0;
		reset = 1;
		#`WAIT_INTERVAL;
		reset = 0;
		#`WAIT_INTERVAL;

		/*------- FREQUENCY ---------*/
		for (k = 0; k <= 5; k = k + 1) begin
			if ((period_1000[k] / 1000.0 == `CLKIN1_PERIOD * ((DIVCLK_DIVIDE * CLKOUT_DIVIDE[k] * 1.0) / CLKFBOUT_MULT))) begin
				$display("PASSED: CLKOUT%0d frequency", k);
				pass_count = pass_count + 1;
			end else begin
				$display("FAILED: CLKOUT%0d frequency", k);
				fail_count = fail_count + 1;
			end
		end

		if ((period_1000_fb / 1000.0) == (`CLKIN1_PERIOD * ((DIVCLK_DIVIDE * 1.0) / CLKFBOUT_MULT))) begin
			$display("PASSED: CLKFBOUT frequency");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKFBOUT frequency");
			fail_count = fail_count + 1;
		end


		/*------- DUTY CYCLE ---------*/
		for (k = 0; k <= 5; k = k + 1) begin
			if (dcc_fail[k] !== 1'b1) begin
				$display("PASSED: CLKOUT%0d duty cycle", k);
				pass_count = pass_count + 1;
			end else begin
				$display("FAILED: CLKOUT%0d duty cycle", k);
				fail_count = fail_count + 1;
			end
		end

		/*------- PHASE SHIFT ---------*/
		for (k = 0; k <= 5; k = k + 1) begin
			if (psc_fail[k] !== 1'b1) begin
				$display("PASSED: CLKOUT%0d phase shift", k);
				pass_count = pass_count + 1;
			end else begin
				$display("FAILED: CLKOUT%0d phase shift", k);
				fail_count = fail_count + 1;
			end
		end

		if (psc_fail_fb !== 1'b1) begin
			$display("PASSED: CLKFBOUT phase shift");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: CLKFBOUT phase shift");
			fail_count = fail_count + 1;
		end


		PWRDWN = 1;
		#100;
		if ((CLKOUT[0] & CLKOUT[1] & CLKOUT[2] & CLKOUT[3] & CLKOUT[4] & CLKOUT[5] & CLKFBOUT) === 1'bx) begin
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
	assign CLKFBIN = CLKFBOUT;

	always #(`CLKIN1_PERIOD / 2.0) CLKIN1 = ~CLKIN1;
	always #(`CLKIN2_PERIOD / 2.0) CLKIN2 = ~CLKIN2;
	always #(`DCLK_PERIOD / 2.0) DCLK = ~DCLK;


	/* calculate the dynamic values */
	wire [31:0] CLKOUT_DIVIDE_DYN[0:5];
	wire [31:0] CLKOUT_DUTY_CYCLE_DYN_1000[0:5];
	wire [31:0] CLKOUT_PHASE_DYN[0:5];
	wire [31:0] CLKFBOUT_MULT_DYN_1000;
	wire [31:0] CLKFBOUT_PHASE_DYN;
	wire [31:0] DIVCLK_DIVIDE_DYN;

	dyn_reconf dyn_reconf (
		.RST(RST),
		.PWRDWN(PWRDWN),

		.vco_period_1000(period_1000_fb),

		.DADDR(DADDR),
		.DCLK(DCLK),
		.DEN(DEN),
		.DWE(DWE),
		.DI(DI),
		.DO(DO),
		.DRDY(DRDY),

		.CLKOUT0_DIVIDE(CLKOUT_DIVIDE_DYN[0]),
		.CLKOUT0_DUTY_CYCLE_1000(CLKOUT_DUTY_CYCLE_DYN_1000[0]),
		.CLKOUT0_PHASE(CLKOUT_PHASE_DYN[0]),

		.CLKOUT1_DIVIDE(CLKOUT_DIVIDE_DYN[1]),
		.CLKOUT1_DUTY_CYCLE_1000(CLKOUT_DUTY_CYCLE_DYN_1000[1]),
		.CLKOUT1_PHASE(CLKOUT_PHASE_DYN[1]),

		.CLKOUT2_DIVIDE(CLKOUT_DIVIDE_DYN[2]),
		.CLKOUT2_DUTY_CYCLE_1000(CLKOUT_DUTY_CYCLE_DYN_1000[2]),
		.CLKOUT2_PHASE(CLKOUT_PHASE_DYN[2]),

		.CLKOUT3_DIVIDE(CLKOUT_DIVIDE_DYN[3]),
		.CLKOUT3_DUTY_CYCLE_1000(CLKOUT_DUTY_CYCLE_DYN_1000[3]),
		.CLKOUT3_PHASE(CLKOUT_PHASE_DYN[3]),

		.CLKOUT4_DIVIDE(CLKOUT_DIVIDE_DYN[4]),
		.CLKOUT4_DUTY_CYCLE_1000(CLKOUT_DUTY_CYCLE_DYN_1000[4]),
		.CLKOUT4_PHASE(CLKOUT_PHASE_DYN[4]),

		.CLKOUT5_DIVIDE(CLKOUT_DIVIDE_DYN[5]),
		.CLKOUT5_DUTY_CYCLE_1000(CLKOUT_DUTY_CYCLE_DYN_1000[5]),
		.CLKOUT5_PHASE(CLKOUT_PHASE_DYN[5]),

		.CLKFBOUT_MULT_F_1000(CLKFBOUT_MULT_DYN_1000),
		.CLKFBOUT_PHASE(CLKFBOUT_PHASE_DYN),

		.DIVCLK_DIVIDE(DIVCLK_DIVIDE_DYN));


	integer l;
	/* set the internal values to the dynamically set */
	always @* begin
		for (l = 0; l <= 5; l = l + 1) begin
			if (CLKOUT_DIVIDE_DYN[l] != 0)
				CLKOUT_DIVIDE[l] = CLKOUT_DIVIDE_DYN[l];
			if (CLKOUT_DUTY_CYCLE_DYN_1000[l] != 0)
				CLKOUT_DUTY_CYCLE_1000[l] = CLKOUT_DUTY_CYCLE_DYN_1000[l];
			if (CLKOUT_PHASE_DYN[l] != 0)
				CLKOUT_PHASE_1000[l] = CLKOUT_PHASE_DYN[l];
		end
		if (CLKFBOUT_MULT_DYN_1000 != 0)
			CLKFBOUT_MULT = CLKFBOUT_MULT_DYN_1000 / 1000;
		if (CLKFBOUT_PHASE_DYN != 0)
			CLKFBOUT_PHASE = CLKFBOUT_PHASE_DYN;
		if (DIVCLK_DIVIDE_DYN != 0)
			DIVCLK_DIVIDE = DIVCLK_DIVIDE_DYN;
	end
endmodule
