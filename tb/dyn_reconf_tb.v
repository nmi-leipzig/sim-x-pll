/*
 * dyn_reconf_tb.v: Test bench for dyn_reconf.v
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

`ifndef CLK_PERIOD
	`define CLK_PERIOD 10
`endif

module dyn_reconf_tb ();
	reg	RST;
	reg	PWRDWN;

	reg [31:0] vco_period_1000;

	reg [6:0] DADDR;
	reg DCLK;
	reg DEN;
	reg DWE;
	reg [15:0] DI;

	wire [15:0] DO;
	output DRDY;

	wire [31:0] CLKOUT0_DIVIDE;
	wire [31:0] CLKOUT1_DIVIDE;
	wire [31:0] CLKOUT2_DIVIDE;
	wire [31:0] CLKOUT3_DIVIDE;
	wire [31:0] CLKOUT4_DIVIDE;
	wire [31:0] CLKOUT5_DIVIDE;
	wire [31:0] CLKOUT6_DIVIDE;

	wire [31:0] CLKOUT0_DUTY_CYCLE;
	wire [31:0] CLKOUT1_DUTY_CYCLE;
	wire [31:0] CLKOUT2_DUTY_CYCLE;
	wire [31:0] CLKOUT3_DUTY_CYCLE;
	wire [31:0] CLKOUT4_DUTY_CYCLE;
	wire [31:0] CLKOUT5_DUTY_CYCLE;
	wire [31:0] CLKOUT6_DUTY_CYCLE;

	wire [31:0] CLKOUT0_PHASE;
	wire [31:0] CLKOUT1_PHASE;
	wire [31:0] CLKOUT2_PHASE;
	wire [31:0] CLKOUT3_PHASE;
	wire [31:0] CLKOUT4_PHASE;
	wire [31:0] CLKOUT5_PHASE;
	wire [31:0] CLKOUT6_PHASE;

	wire [31:0] CLKFBOUT_MULT_F_1000;
	wire [31:0] CLKFBOUT_PHASE;

	wire [31:0] DIVCLK_DIVIDE;

	integer duty_cycle;

	integer	pass_count;
	integer	fail_count;

	/* adjust according to the number of test cases */
	localparam total = 11;

	dyn_reconf dut(
		.RST(RST),
		.PWRDWN(PWRDWN),

		.vco_period_1000(vco_period_1000),

		.DADDR(DADDR),
		.DCLK(DCLK),
		.DEN(DEN),
		.DWE(DWE),
		.DI(DI),
		.DO(DO),
		.DRDY(DRDY),

		.CLKOUT0_DIVIDE(CLKOUT0_DIVIDE),
		.CLKOUT0_DUTY_CYCLE_1000(CLKOUT0_DUTY_CYCLE),
		.CLKOUT0_PHASE(CLKOUT0_PHASE),

		.CLKOUT1_DIVIDE(CLKOUT1_DIVIDE),
		.CLKOUT1_DUTY_CYCLE_1000(CLKOUT1_DUTY_CYCLE),
		.CLKOUT1_PHASE(CLKOUT1_PHASE),

		.CLKOUT2_DIVIDE(CLKOUT2_DIVIDE),
		.CLKOUT2_DUTY_CYCLE_1000(CLKOUT2_DUTY_CYCLE),
		.CLKOUT2_PHASE(CLKOUT2_PHASE),

		.CLKOUT3_DIVIDE(CLKOUT3_DIVIDE),
		.CLKOUT3_DUTY_CYCLE_1000(CLKOUT3_DUTY_CYCLE),
		.CLKOUT3_PHASE(CLKOUT3_PHASE),

		.CLKOUT4_DIVIDE(CLKOUT4_DIVIDE),
		.CLKOUT4_DUTY_CYCLE_1000(CLKOUT4_DUTY_CYCLE),
		.CLKOUT4_PHASE(CLKOUT4_PHASE),

		.CLKOUT5_DIVIDE(CLKOUT5_DIVIDE),
		.CLKOUT5_DUTY_CYCLE_1000(CLKOUT5_DUTY_CYCLE),
		.CLKOUT5_PHASE(CLKOUT5_PHASE),

		.CLKOUT6_DIVIDE(CLKOUT6_DIVIDE),
		.CLKOUT6_DUTY_CYCLE_1000(CLKOUT6_DUTY_CYCLE),
		.CLKOUT6_PHASE(CLKOUT6_PHASE),

		.CLKFBOUT_MULT_F_1000(CLKFBOUT_MULT_F_1000),
		.CLKFBOUT_PHASE(CLKFBOUT_PHASE),

		.DIVCLK_DIVIDE(DIVCLK_DIVIDE));

	initial begin
		$dumpfile("dyn_reconf_tb.vcd");
		$dumpvars(0, dyn_reconf_tb);

		vco_period_1000 = 32 * 1000;
		RST = 0;
		DCLK = 0;
		DADDR = 7'h00;
		DEN = 0;
		DWE = 0;
		DI = 15'h0000;

		pass_count = 0;
		fail_count = 0;

		#(`CLK_PERIOD * 2);
		RST = 1;
		#(`CLK_PERIOD * 2);

		/* TEST CASES */

		if (DO == 15'h0000 && DRDY == 1'b1) begin
			$display("PASSED: RST");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: RST");
			fail_count = fail_count + 1;
		end

		RST = 0;
		#(`CLK_PERIOD * 2);

		if (DRDY == 1'b1) begin
			$display("PASSED: release RST");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: release RST");
			fail_count = fail_count + 1;
		end

		DADDR = 7'h08;
		DEN = 1'b1;
		DWE = 1'b1;
		/* PHASE MUX = 3
		 * RESERVED = 0
		 * HIGH TIME = 6
		 * LOW TIME = 3 */
		DI = 16'b011_0_000110_000011;

		#(`CLK_PERIOD * 2);
		if (DRDY == 1'b0) begin
			$display("PASSED: DRDY");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: DRDY");
			fail_count = fail_count + 1;
		end

		DEN = 1'b0;
		DWE = 1'b0;

		#(`CLK_PERIOD * 2);

		if (DRDY == 1'b1) begin
			$display("PASSED: DEN and DWE");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: DEN and DWE");
			fail_count = fail_count + 1;
		end

		DEN = 1'b1;
		#(`CLK_PERIOD * 2);

		if (DRDY == 1'b0 && DO == DI) begin
			$display("PASSED: DI and DO");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: DI and DO");
			fail_count = fail_count + 1;
		end

		if (CLKOUT0_DIVIDE == 9) begin
			$display("PASSED: ClkReg1 DIVIDE calculation");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: ClkReg1 DIVIDE calculation");
			fail_count = fail_count + 1;
		end

		duty_cycle = (6.0 * 1000) / (6.0 + 3.0);
		if (CLKOUT0_DUTY_CYCLE == duty_cycle) begin
			$display("PASSED: ClkReg1 DUTY_CYCLE calculation");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: ClkReg1 DUTY_CYCLE calculation");
			fail_count = fail_count + 1;
		end

		if (CLKOUT0_PHASE == (((vco_period_1000 / 1000) / 8) * 3)) begin
			$display("PASSED: ClkReg1 PHASE calculation");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: ClkReg1 PHASE calculation");
			fail_count = fail_count + 1;
		end
		DEN = 1'b0;
		#(`CLK_PERIOD * 2);
		DEN = 1'b1;
		DWE = 1'b1;
		DADDR = 7'h09;
		/* RESERVED = 0
		 * FRAC = 000
		 * FRAC_EN = 0
		 * FRAC_WF_R = 0
		 * MX = 2b'00
		 * EDGE = 0
		 * NO COUNT = 1
		 * DELAY TIME = 3 */
		DI = 16'b0_000_0_0_00_1_0_00011;

		#(`CLK_PERIOD * 2);
		DEN = 1'b0;
		DWE = 1'b0;
		#(`CLK_PERIOD * 2);

		if (CLKOUT0_DIVIDE == 1) begin
			$display("PASSED: ClkReg2 DIVIDE calculation");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: ClkReg2 DIVIDE calculation");
			fail_count = fail_count + 1;
		end

		if ((CLKOUT0_DUTY_CYCLE / 1000.0) == 0.5) begin
			$display("PASSED: ClkReg2 DUTY_CYCLE calculation");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: ClkReg2 DUTY_CYCLE calculation");
			fail_count = fail_count + 1;
		end

		if (CLKOUT0_PHASE == (((vco_period_1000 / 1000.0) / 8) * 3) + ((vco_period_1000 / 1000.0) * 3)) begin
			$display("PASSED: ClkReg2 PHASE calculation");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: ClkReg2 PHASE calculation");
			fail_count = fail_count + 1;
		end

		//TODO: test for non existing address

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

	always #`CLK_PERIOD DCLK <= ~DCLK;
endmodule
