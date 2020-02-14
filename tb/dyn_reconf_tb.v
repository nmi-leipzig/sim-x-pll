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
	reg [6:0] DADDR;
	reg DCLK;
	reg DEN;
	reg DWE;
	reg [15:0] DI;

	wire [15:0] DO;
	output DRDY;

	wire [15:0] ClkReg1_0;
	wire [15:0] ClkReg1_1;
	wire [15:0] ClkReg1_2;
	wire [15:0] ClkReg1_3;
	wire [15:0] ClkReg1_4;
	wire [15:0] ClkReg1_5;
	wire [15:0] ClkReg1_6;
	wire [15:0] ClkReg1_FB;
	wire [15:0] ClkReg2_0;
	wire [15:0] ClkReg2_1;
	wire [15:0] ClkReg2_2;
	wire [15:0] ClkReg2_3;
	wire [15:0] ClkReg2_4;
	wire [15:0] ClkReg2_5;
	wire [15:0] ClkReg2_6;
	wire [15:0] ClkReg2_FB;
	wire [15:0] DivReg;
	wire [15:0] LockReg1;
	wire [15:0] LockReg2;
	wire [15:0] LockReg3;
	wire [15:0] FiltReg1;
	wire [15:0] FiltReg2;
	wire [15:0] PowerReg;

	integer	pass_count;
	integer	fail_count;

	/* adjust according to the number of test cases */
	localparam total = 5;

	dyn_reconf dut(
		.RST(RST),
		.PWRDWN(PWRDWN),

		.DADDR(DADDR),
		.DCLK(DCLK),
		.DEN(DEN),
		.DWE(DWE),
		.DI(DI),
		.DO(DO),
		.DRDY(DRDY),

		.ClkReg1_0(ClkReg1_0),
		.ClkReg1_1(ClkReg1_1),
		.ClkReg1_2(ClkReg1_2),
		.ClkReg1_3(ClkReg1_3),
		.ClkReg1_4(ClkReg1_4),
		.ClkReg1_5(ClkReg1_5),
		.ClkReg1_6(ClkReg1_6),
		.ClkReg1_FB(ClkReg1_FB),

		.ClkReg2_1(ClkReg2_1),
		.ClkReg2_2(ClkReg2_2),
		.ClkReg2_3(ClkReg2_3),
		.ClkReg2_4(ClkReg2_4),
		.ClkReg2_5(ClkReg2_5),
		.ClkReg2_6(ClkReg2_6),
		.ClkReg2_FB(ClkReg2_FB),

		.DivReg(DivReg),

		.LockReg1(LockReg2),
		.LockReg2(LockReg2),
		.LockReg3(LockReg3),

		.FiltReg1(FiltReg1),
		.FiltReg2(FiltReg2),

		.PowerReg(PowerReg));

	initial begin
		$dumpfile("dyn_reconf_tb.vcd");
		$dumpvars(0, dyn_reconf_tb);

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

		if (DO == 15'h0000 && DRDY == 1'b0) begin
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
		DI = 16'h9999;

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
