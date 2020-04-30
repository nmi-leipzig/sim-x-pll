/*
 * plle2_adv_cocotb_wrapper.v: Wrapper for plle2_adv.v allowing
 *                             instantiation using macros
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

/* define all attributes as macros, so different combinations can be tested
 * more easily.
 * By default these are the given default values of the part.
 */

/* not implemented */
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
/*not implemented */
`ifndef REF_JITTER2
	`define REF_JITTER2 0.010
`endif
/* not implemented */
`ifndef STARTUP_WAIT
	`define STARTUP_WAIT "FALSE"
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


module plle2_adv_cocotb_wrapper (
	output CLKOUT0,
	output CLKOUT1,
	output CLKOUT2,
	output CLKOUT3,
	output CLKOUT4,
	output CLKOUT5,
	/* PLL feedback output. */
	output CLKFBOUT,

	output LOCKED,

	input CLKIN1,
	input CLKIN2,
	input CLKINSEL,
	/* PLL feedback input. Is ignored in this implementation, but should be connected to CLKFBOUT for internal feedback. */
	input CLKFBIN,

	/* Used to power down instatiated but unused PLLs */
	input PWRDWN,
	input RST,

	input [6:0] DADDR,
	input DCLK,
	input DEN,
	input DWE,
	input [15:0] DI,
	output [15:0] DO,
	output DRDY

	output reg [31:0] CLKFBOUT_MULT,
	output reg [31:0] CLKFBOUT_PHASE_1000,
	output reg [31:0] CLKIN1_PERIOD_1000,
	output reg [31:0] CLKIN2_PERIOD_1000,

	output reg [31:0] CLKOUT0_DIVIDE,
	output reg [31:0] CLKOUT1_DIVIDE,
	output reg [31:0] CLKOUT2_DIVIDE,
	output reg [31:0] CLKOUT3_DIVIDE,
	output reg [31:0] CLKOUT4_DIVIDE,
	output reg [31:0] CLKOUT5_DIVIDE,

	output reg [31:0] CLKOUT0_DUTY_CYCLE_1000,
	output reg [31:0] CLKOUT1_DUTY_CYCLE_1000,
	output reg [31:0] CLKOUT2_DUTY_CYCLE_1000,
	output reg [31:0] CLKOUT3_DUTY_CYCLE_1000,
	output reg [31:0] CLKOUT4_DUTY_CYCLE_1000,
	output reg [31:0] CLKOUT5_DUTY_CYCLE_1000,

	output reg [31:0] CLKOUT0_PHASE_1000,
	output reg [31:0] CLKOUT1_PHASE_1000,
	output reg [31:0] CLKOUT2_PHASE_1000,
	output reg [31:0] CLKOUT3_PHASE_1000,
	output reg [31:0] CLKOUT4_PHASE_1000,
	output reg [31:0] CLKOUT5_PHASE_1000,

	output reg [31:0] DIVCLK_DIVIDE,
	output reg [31:0] REF_JITTER1_1000,
	output reg [31:0] REF_JITTER2_1000);

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
		.CLKIN2(CLKIN2),
		.CLKINSEL(CLKINSEL),

		.PWRDWN(PWRDWN),
		.RST(RST),
		.CLKFBIN(CLKFBIN)

		.DADDR(DADDR),
		.DCLK(DCLK),
		.DEN(DEN),
		.DWE(DWE),
		.DI(DI),

		.DO(DO),
		.DRDY(DRDY)
	);

	initial begin
		$dumpfile("plle2_base_cocotb_wrapper.vcd");
		$dumpvars(0, plle2_base_cocotb_wrapper);

		CLKFBOUT_MULT = `CLKFBOUT_MULT;
		CLKFBOUT_PHASE_1000 = `CLKFBOUT_PHASE * 1000;
		CLKIN1_PERIOD_1000 = `CLKIN1_PERIOD * 1000;
		CLKIN2_PERIOD_1000 = `CLKIN2_PERIOD * 1000;

		CLKOUT0_DIVIDE = `CLKOUT0_DIVIDE;
		CLKOUT1_DIVIDE = `CLKOUT1_DIVIDE;
		CLKOUT2_DIVIDE = `CLKOUT2_DIVIDE;
		CLKOUT3_DIVIDE = `CLKOUT3_DIVIDE;
		CLKOUT4_DIVIDE = `CLKOUT4_DIVIDE;
		CLKOUT5_DIVIDE = `CLKOUT5_DIVIDE;

		CLKOUT0_DUTY_CYCLE_1000 = 1000 * `CLKOUT0_DUTY_CYCLE;
		CLKOUT1_DUTY_CYCLE_1000 = 1000 * `CLKOUT1_DUTY_CYCLE;
		CLKOUT2_DUTY_CYCLE_1000 = 1000 * `CLKOUT2_DUTY_CYCLE;
		CLKOUT3_DUTY_CYCLE_1000 = 1000 * `CLKOUT3_DUTY_CYCLE;
		CLKOUT4_DUTY_CYCLE_1000 = 1000 * `CLKOUT4_DUTY_CYCLE;
		CLKOUT5_DUTY_CYCLE_1000 = 1000 * `CLKOUT5_DUTY_CYCLE;

		CLKOUT0_PHASE_1000 = 1000 * `CLKOUT0_PHASE;
		CLKOUT1_PHASE_1000 = 1000 * `CLKOUT1_PHASE;
		CLKOUT2_PHASE_1000 = 1000 * `CLKOUT2_PHASE;
		CLKOUT3_PHASE_1000 = 1000 * `CLKOUT3_PHASE;
		CLKOUT4_PHASE_1000 = 1000 * `CLKOUT4_PHASE;
		CLKOUT5_PHASE_1000 = 1000 * `CLKOUT5_PHASE;

		DIVCLK_DIVIDE = `DIVCLK_DIVIDE;
		REF_JITTER1_1000 = 1000 * `REF_JITTER1;
		REF_JITTER2_1000 = 1000 * `REF_JITTER2;
		#1;
	end
endmodule
