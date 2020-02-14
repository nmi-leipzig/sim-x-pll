/*
 * pll.v: Simulates the pll of the xilinx 7 series. This is used by the
 * frontend files "plle2_base.v" and "plle2_adv.v"
 * author: Till Mahlburg
 * year: 2019
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

/* A reference for the interface can be found in Xilinx UG953 page 503ff */
module pll #(
	/* not implemented */
	parameter BANDWIDTH 			= "OPTIMIZED",

	parameter CLKFBOUT_MULT 		= 5,
	parameter CLKFBOUT_PHASE 		= 0.0,

	/* are ignored, but need to be set */
	parameter CLKIN1_PERIOD			= 0.0,
	parameter CLKIN2_PERIOD			= 0.0,

	parameter CLKOUT0_DIVIDE		= 1,
	parameter CLKOUT1_DIVIDE		= 1,
	parameter CLKOUT2_DIVIDE		= 1,
	parameter CLKOUT3_DIVIDE		= 1,
	parameter CLKOUT4_DIVIDE		= 1,
	parameter CLKOUT5_DIVIDE		= 1,

	parameter CLKOUT0_DUTY_CYCLE	= 0.5,
	parameter CLKOUT1_DUTY_CYCLE	= 0.5,
	parameter CLKOUT2_DUTY_CYCLE	= 0.5,
	parameter CLKOUT3_DUTY_CYCLE	= 0.5,
	parameter CLKOUT4_DUTY_CYCLE	= 0.5,
	parameter CLKOUT5_DUTY_CYCLE	= 0.5,

	parameter CLKOUT0_PHASE			= 0.0,
	parameter CLKOUT1_PHASE			= 0.0,
	parameter CLKOUT2_PHASE			= 0.0,
	parameter CLKOUT3_PHASE			= 0.0,
	parameter CLKOUT4_PHASE			= 0.0,
	parameter CLKOUT5_PHASE			= 0.0,

	parameter DIVCLK_DIVIDE			= 1,

	/* not implemented */
	parameter REF_JITTER1			= 0.010,
	parameter REF_JITTER2			= 0.010,
	parameter STARTUP_WAIT			= "FALSE",
	parameter COMPENSATION			= "ZHOLD")(
	output 	CLKOUT0,
	output 	CLKOUT1,
	output 	CLKOUT2,
	output 	CLKOUT3,
	output 	CLKOUT4,
	output 	CLKOUT5,
	/* PLL feedback output. */
	output 	CLKFBOUT,

	output	LOCKED,

	input 	CLKIN1,
	input 	CLKIN2,
	/* Select input clk. 1 for CLKIN1, 0 for CLKIN2 */
	input 	CLKINSEL,
	/* PLL feedback input. Is ignored in this implementation, but should be connected to CLKFBOUT for internal feedback. */
	input 	CLKFBIN,

	/* Used to power down instatiated but unused PLLs */
	input	PWRDWN,
	input	RST,

	/* Dynamic reconfiguration ports */
	//TODO: port descriptions
	input 	[6:0] DADDR,
	input 	DCLK,
	input 	DEN,
	input 	DWE,
	input 	[15:0] DI,

	output	[15:0] DO,
	output	DRDY);

	/* registers for dynamic reconfiguration */
	/* ADDRESS: */
	// 0x08
	reg [15:0] ClkReg1_0;
	// 0x0A
	reg [15:0] ClkReg1_1;
	// 0x0C
	reg [15:0] ClkReg1_2;
	// 0x0E
	reg [15:0] ClkReg1_3;
	// 0x10
	reg [15:0] ClkReg1_4;
	// 0x06
	reg [15:0] ClkReg1_5;
	// 0x12
	reg [15:0] ClkReg1_6;
	// 0x14
	reg [15:0] ClkReg1_FB;

	// 0x09
	reg [15:0] ClkReg2_0;
	// 0x0B
	reg [15:0] ClkReg2_1;
	// 0x0D
	reg [15:0] ClkReg2_2;
	// 0x0F
	reg [15:0] ClkReg2_3;
	// 0x11
	reg [15:0] ClkReg2_4;
	// 0x07
	reg [15:0] ClkReg2_5;
	// 0x13
	reg [15:0] ClkReg2_6;
	// 0x15
	reg [15:0] ClkReg2_FB;

	// 0x16
	reg [15:0] DivReg;

	// 0x18
	reg [15:0] LockReg1;
	// 0x19
	reg [15:0] LockReg2;
	// 0x1A
	reg [15:0] LockReg3;

	// 0x4E
	reg [15:0] FiltReg1;
	// 0x4F
	reg [15:0] FiltReg2;

	// 0x27
	reg [15:0] PowerReg;

	/* gets assigned to the chosen CLKIN */
	reg clkin;

	wire [31:0] clkin_period_length;

	/* Used to determine the period length of the divided CLK */
	period_count #(
		.RESOLUTION(0.1))
	period_count (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(clkin),
		.period_length(clkin_period_length));

	wire period_stable;

	/* Used to delay the output of the period until it's stable */
	period_check period_check (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(clkin),
		.period_length(clkin_period_length),
		.period_stable(period_stable));

	wire out0;
	wire [31:0] out0_period_length;
	wire lock0;

	/* CLKOUT0 */
	freq_gen #(
		.M(CLKFBOUT_MULT),
		.D(DIVCLK_DIVIDE),
		.O(CLKOUT0_DIVIDE))
	fg_0 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.period_stable(period_stable),
		.ref_period(clkin_period_length),
		.clk(clkin),
		.out(out0),
		.out_period_length_1000(out0_period_length));

	phase_shift ps0 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(out0),
		.shift(CLKOUT0_PHASE + CLKFBOUT_PHASE),
		.clk_period_1000(out0_period_length),
		.duty_cycle(CLKOUT0_DUTY_CYCLE * 100),
		.lock(lock0),
		.clk_shifted(CLKOUT0));

	wire out1;
	wire [31:0] out1_period_length;
	wire lock1;

	/* CLKOUT1 */
	freq_gen #(
		.M(CLKFBOUT_MULT),
		.D(DIVCLK_DIVIDE),
		.O(CLKOUT1_DIVIDE))
	fg_1 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.period_stable(period_stable),
		.ref_period(clkin_period_length),
		.clk(clkin),
		.out(out1),
		.out_period_length_1000(out1_period_length));

	phase_shift ps1 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(out1),
		.shift(CLKOUT1_PHASE + CLKFBOUT_PHASE),
		.clk_period_1000(out1_period_length),
		.duty_cycle(CLKOUT1_DUTY_CYCLE * 100),
		.lock(lock1),
		.clk_shifted(CLKOUT1));

	wire out2;
	wire [31:0] out2_period_length;
	wire lock2;

	/* CLKOUT2 */
	freq_gen #(
		.M(CLKFBOUT_MULT),
		.D(DIVCLK_DIVIDE),
		.O(CLKOUT2_DIVIDE))
	fg_2 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.period_stable(period_stable),
		.ref_period(clkin_period_length),
		.clk(clkin),
		.out(out2),
		.out_period_length_1000(out2_period_length));

	phase_shift ps2 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(out2),
		.shift(CLKOUT2_PHASE + CLKFBOUT_PHASE),
		.clk_period_1000(out2_period_length),
		.duty_cycle(CLKOUT2_DUTY_CYCLE * 100),
		.lock(lock2),
		.clk_shifted(CLKOUT2));

	wire out3;
	wire [31:0] out3_period_length;
	wire lock3;

	/* CLKOUT3 */
	freq_gen #(
		.M(CLKFBOUT_MULT),
		.D(DIVCLK_DIVIDE),
		.O(CLKOUT3_DIVIDE))
	fg_3 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.period_stable(period_stable),
		.ref_period(clkin_period_length),
		.clk(clkin),
		.out(out3),
		.out_period_length_1000(out3_period_length));

	phase_shift ps3 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(out3),
		.shift(CLKOUT3_PHASE + CLKFBOUT_PHASE),
		.clk_period_1000(out3_period_length),
		.duty_cycle(CLKOUT3_DUTY_CYCLE * 100),
		.lock(lock3),
		.clk_shifted(CLKOUT3));

	wire out4;
	wire [31:0] out4_period_length;
	wire lock4;

	/* CLKOUT4 */
	freq_gen #(
		.M(CLKFBOUT_MULT),
		.D(DIVCLK_DIVIDE),
		.O(CLKOUT4_DIVIDE))
	fg_4 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.period_stable(period_stable),
		.ref_period(clkin_period_length),
		.clk(clkin),
		.out(out4),
		.out_period_length_1000(out4_period_length));

	phase_shift ps4 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(out4),
		.shift(CLKOUT4_PHASE + CLKFBOUT_PHASE),
		.clk_period_1000(out4_period_length),
		.duty_cycle(CLKOUT4_DUTY_CYCLE * 100),
		.lock(lock4),
		.clk_shifted(CLKOUT4));

	wire out5;
	wire [31:0] out5_period_length;
	wire lock5;

	/* CLKOUT5 */
	freq_gen #(
		.M(CLKFBOUT_MULT),
		.D(DIVCLK_DIVIDE),
		.O(CLKOUT5_DIVIDE))
	fg_5 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.period_stable(period_stable),
		.ref_period(clkin_period_length),
		.clk(clkin),
		.out(out5),
		.out_period_length_1000(out5_period_length));

	phase_shift ps5 (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(out5),
		.shift(CLKOUT5_PHASE + CLKFBOUT_PHASE),
		.clk_period_1000(out5_period_length),
		.duty_cycle(CLKOUT5_DUTY_CYCLE * 100),
		.lock(lock5),
		.clk_shifted(CLKOUT5));

	wire fb_out;
	wire [31:0] fb_out_period_length_1000;
	wire fb_lock;

	/* CLKOUTFB */
	freq_gen #(
		.M(CLKFBOUT_MULT),
		.D(DIVCLK_DIVIDE),
		.O(1.0))
	fb_fg (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.period_stable(period_stable),
		.ref_period(clkin_period_length),
		.clk(clkin),
		.out(fb_out),
		.out_period_length_1000(fb_out_period_length_1000));

	phase_shift fb_ps (
		.RST(RST),
		.PWRDWN(PWRDWN),
		.clk(fb_out),
		.shift(CLKFBOUT_PHASE),
		.clk_period_1000(fb_out_period_length_1000),
		.duty_cycle(50),
		.lock(fb_lock),
		.clk_shifted(CLKFBOUT));

	/* lock detection using the lock information given by the phase shift modules */
	assign LOCKED = lock0 & lock1 & lock2 & lock3 & lock4 & lock5 & fb_lock;
	/* set clkin to the correct CLKIN */
	always @* begin
		if (CLKINSEL === 1'b1) begin
			clkin = CLKIN1;
		end else if (CLKINSEL === 1'b0) begin
			clkin = CLKIN2;
		end
	end

	always @(posedge DCLK) begin
		if (DEN) begin
			if (DWE) begin
				case (DADDR)
					7'h06 : ClkReg1_5 <= DI;
					7'h07 : ClkReg2_5 <= DI;
					7'h08 : ClkReg1_0 <= DI;
					7'h09 : ClkReg2_0 <= DI;
					7'h0A : ClkReg1_1 <= DI;
					7'h0B : ClkReg2_1 <= DI;
					7'h0C : ClkReg1_2 <= DI;
					7'h0D : ClkReg2_2 <= DI;
					7'h0E : ClkReg1_3 <= DI;
					7'h0F : ClkReg2_3 <= DI;
					7'h10 : ClkReg1_4 <= DI;
					7'h11 : ClkReg2_4 <= DI;
					7'h12 : ClkReg1_6 <= DI;
					7'h13 : ClkReg2_6 <= DI;
					7'h14 : ClkReg1_FB <= DI;
					7'h15 : ClkReg2_FB <= DI;
					7'h16 : DivReg <= DI;
					7'h18 : LockReg1 <= DI;
					7'h19 : LockReg2 <= DI;
					7'h1A : LockReg3 <= DI;
					7'h28 : PowerReg <= DI;
					7'h4E : FiltReg1 <= DI;
					7'h4F : FiltReg2 <= DI;
					default : $display("default"); //TODO;
				endcase
			end else begin
				case (DADDR)
					7'h06 : DO <= ClkReg1_5;
					7'h07 : DO <= ClkReg2_5;
					7'h08 : DO <= ClkReg1_0;
					7'h09 : DO <= ClkReg2_0;
					7'h0A : DO <= ClkReg1_1;
					7'h0B : DO <= ClkReg2_1;
					7'h0C : DO <= ClkReg1_2;
					7'h0D : DO <= ClkReg2_2;
					7'h0E : DO <= ClkReg1_3;
					7'h0F : DO <= ClkReg2_3;
					7'h10 : DO <= ClkReg1_4;
					7'h11 : DO <= ClkReg2_4;
					7'h12 : DO <= ClkReg1_6;
					7'h13 : DO <= ClkReg2_6;
					7'h14 : DO <= ClkReg1_FB;
					7'h15 : DO <= ClkReg2_FB;
					7'h16 : DO <= DivReg;
					7'h18 : DO <= LockReg1;
					7'h19 : DO <= LockReg2;
					7'h1A : DO <= LockReg3;
					7'h28 : DO <= PowerReg;
					7'h4E : DO <= FiltReg1;
					7'h4F : DO <= FiltReg2;
					default : $display("default"); //TODO;
				endcase
		end
	end

	reg invalid = 1'b0;
	/* check if the given values are valid*/
	initial begin
		if (!(BANDWIDTH == "OPTIMIZED" || BANDWIDTH == "HIGH" || BANDWIDTH == "LOW")) begin
			$display("BANDWIDTH doesn't match any of its allowed inputs.");
			invalid = 1'b1;
		end else if (CLKFBOUT_MULT < 2 || CLKFBOUT > 64) begin
			$display("CLKFBOUT_MULT is not in the allowed range (2-64).");
			invalid = 1'b1;
		end else if (CLKFBOUT_PHASE < -360.00 || CLKFBOUT_PHASE > 360.000) begin
			$display("CLKFBOUT_PHASE is not in the allowed range (-360-360).");
			invalid = 1'b1;
		end else if (CLKIN1_PERIOD < 0.000 || CLKIN1_PERIOD > 52.631) begin
			$display("CLKIN1_PERIOD is not in the allowed range (0 - 52.631).");
			invalid = 1'b1;
		end else if (CLKIN2_PERIOD < 0.000 || CLKIN2_PERIOD > 52.631) begin
			$display("CLKIN2_PERIOD is not in the allowed range (0 - 52.631).");
			invalid = 1'b1;
		end else if (CLKOUT0_DIVIDE < 1 || CLKOUT0_DIVIDE > 128 ||
					 CLKOUT1_DIVIDE < 1 || CLKOUT1_DIVIDE > 128 ||
					 CLKOUT2_DIVIDE < 1 || CLKOUT2_DIVIDE > 128 ||
					 CLKOUT3_DIVIDE < 1 || CLKOUT3_DIVIDE > 128 ||
					 CLKOUT4_DIVIDE < 1 || CLKOUT4_DIVIDE > 128 ||
					 CLKOUT5_DIVIDE < 1 || CLKOUT5_DIVIDE > 128) begin
			$display("One of the CLKOUTn_DIVIDE parameters is not in the allowed range (1-128).");
			invalid = 1'b1;
		end else if (CLKOUT0_DUTY_CYCLE < 0.001 || CLKOUT0_DUTY_CYCLE > 0.999 ||
					 CLKOUT1_DUTY_CYCLE < 0.001 || CLKOUT1_DUTY_CYCLE > 0.999 ||
					 CLKOUT2_DUTY_CYCLE < 0.001 || CLKOUT2_DUTY_CYCLE > 0.999 ||
					 CLKOUT3_DUTY_CYCLE < 0.001 || CLKOUT3_DUTY_CYCLE > 0.999 ||
					 CLKOUT4_DUTY_CYCLE < 0.001 || CLKOUT4_DUTY_CYCLE > 0.999 ||
					 CLKOUT5_DUTY_CYCLE < 0.001 || CLKOUT5_DUTY_CYCLE > 0.999) begin
			$display("One of the CLKOUTn_DUTY_CYCLE parameters is not in the allowed range (0.001-0.999).");
			invalid = 1'b1;
		end else if (CLKOUT0_PHASE < -360.000 || CLKOUT0_PHASE > 360.000 ||
					 CLKOUT1_PHASE < -360.000 || CLKOUT1_PHASE > 360.000 ||
					 CLKOUT2_PHASE < -360.000 || CLKOUT2_PHASE > 360.000 ||
					 CLKOUT3_PHASE < -360.000 || CLKOUT3_PHASE > 360.000 ||
					 CLKOUT4_PHASE < -360.000 || CLKOUT4_PHASE > 360.000 ||
					 CLKOUT5_PHASE < -360.000 || CLKOUT5_PHASE > 360.000) begin
			$display("One of the CLKOUTn_PHASE parameters is not in the allowed range (-360.00-360.00).");
			invalid = 1'b1;
		end else if (DIVCLK_DIVIDE < 1 || DIVCLK_DIVIDE > 56) begin
			$display("DIVCLK_DIVIDE is not in the allowed range (1-56).");
			invalid = 1'b1;
		end else if (REF_JITTER1 < 0.000 || REF_JITTER1 > 0.999) begin
			$display("REF_JITTER1 is not in the allowed range (0.000 - 0.999).");
			invalid = 1'b1;
		end else if (REF_JITTER2 < 0.000 || REF_JITTER2 > 0.999) begin
			$display("REF_JITTER2 is not in the allowed range (0.000 - 0.999).");
			invalid = 1'b1;
		end else if (!(STARTUP_WAIT == "FALSE" || STARTUP_WAIT == "TRUE")) begin
			$display("STARTUP_WAIT doesn't match any of its allowed inputs");
			invalid = 1'b1;
		end else if (!(COMPENSATION == "ZHOLD" || COMPENSATION == "BUF_IN" || COMPENSATION == "EXTERNAL" || COMPENSATION == "INTERNAL")) begin
			$display("COMPENSATION doesn'T match any of its allowed inputs");
			invalid = 1'b1;
		end else if (((CLKFBOUT_MULT * 1000.0) / (CLKIN1_PERIOD * 1.0 * DIVCLK_DIVIDE)) < 800.0 || ((CLKFBOUT_MULT * 1000.0) / (CLKIN1_PERIOD * 1.0 * DIVCLK_DIVIDE)) > 1600.0) begin
			$display("The calculated VCO frequency is not in the allowed range (800.000-1600.000). Change either CLKFBOUT_MULT, CLKIN1_PERIOD or DIVCLK_DIVIDE to an appropiate value.");
			$display("To calculate the VCO frequency use this formula: (CLKFBOUT_MULT * 1000) / (CLKIN1_PERIOD * DIVCLKDIVIDE).");
			$display("Currently the value is %0f.", ((CLKFBOUT_MULT * 1000.0) / (CLKIN1_PERIOD * 1.0 * DIVCLK_DIVIDE)));
			invalid = 1'b1;
		end else if (CLKIN2_PERIOD != 0.000 && (((CLKFBOUT_MULT * 1000.0) / (CLKIN2_PERIOD * 1.0 * DIVCLK_DIVIDE)) < 800.0 || ((CLKFBOUT_MULT * 1000.0) / (CLKIN2_PERIOD * 1.0 * DIVCLK_DIVIDE)) > 1600.0)) begin
			$display("The calculated VCO frequency is not in the allowed range (800.000-1600.000). Change either CLKFBOUT_MULT, CLKIN2_PERIOD or DIVCLK_DIVIDE to an appropiate value.");
			$display("To calculate the VCO frequency use this formula: (CLKFBOUT_MULT * 1000) / (CLKIN2_PERIOD * DIVCLKDIVIDE).");
			$display("Currently the value is %0f.", ((CLKFBOUT_MULT * 1000.0) / (CLKIN2_PERIOD * 1.0 * DIVCLK_DIVIDE)));
			invalid = 1'b1;
		end
		/* delete this to simulate even if there are invalid values */
		if (invalid) begin
			$display("Exiting simulation...");
			$finish;
		end
	end
endmodule
