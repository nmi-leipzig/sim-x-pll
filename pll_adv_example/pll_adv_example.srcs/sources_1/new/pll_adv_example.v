/*
 * pll_adv_example.v: Example program working in simulation as well as it should on real hardware.
 *  To be tested on Digilent Basys 3.
 * author: Till Mahlburg
 * year: 2019
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

module pll_adv_example (
	input clk,
	input RST,
	output [7:0] led);

    reg [6:0] DADDR;
    reg [15:0] DI;
    wire [15:0] DO;
    reg DEN;
    reg DWE;
    wire DRDY;

	wire CLKFB;
	/* More information about the instantiiation can be found in Xilinx UG953 509ff. */
	PLLE2_ADV #(
		.CLKFBOUT_MULT(8),
		.CLKFBOUT_PHASE(90.0),
		.CLKIN1_PERIOD(10.0),
		.CLKIN2_PERIOD(10.0),

		.CLKOUT0_DIVIDE(128),
		.CLKOUT1_DIVIDE(2),
		.CLKOUT2_DIVIDE(32),
		.CLKOUT3_DIVIDE(16),
		.CLKOUT4_DIVIDE(128),
		.CLKOUT5_DIVIDE(128),

		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT3_DUTY_CYCLE(0.5),
		.CLKOUT4_DUTY_CYCLE(0.9),
		.CLKOUT5_DUTY_CYCLE(0.1),

		.CLKOUT0_PHASE(0.0),
		.CLKOUT1_PHASE(0.0),
		.CLKOUT2_PHASE(0.0),
		.CLKOUT3_PHASE(0.0),
		.CLKOUT4_PHASE(0.0),
		.CLKOUT5_PHASE(0.0),

		.DIVCLK_DIVIDE(1))
 	pll (
		.CLKOUT0(led[0]),
		.CLKOUT1(led[1]),
		.CLKOUT2(led[2]),
		.CLKOUT3(led[3]),
		.CLKOUT4(led[5]),
		.CLKOUT5(led[6]),

		.CLKFBOUT(CLKFB),
		.LOCKED(led[7]),
		.CLKIN1(clk),
		.CLKIN2(clk),
		.CLKINSEL(1'b1),

		.DADDR(DADDR),
		.DI(DI),
		.DO(DO),
		.DWE(DEW),
		.DEN(DEN),
		.DRDY(DRDY),
		.DCLK(led[0]),

		.PWRDWN(0),
		.RST(RST),

		.CLKFBIN(CLKFB));

	integer step = 0;
	/* CLKOUT1 will be dynamically reconfigured */
	always @(posedge clk) begin
		/* After some time to achieve LOCK & DRDY status, we can write the first value into ClkReg1
		 * for CLKOUT1 */
		if (led[7] && DRDY && step == 0) begin
			/* Address of ClkReg1 for CLKOUT1 */
			DADDR <= 7'h0A;
			/* PHASE MUX = 3
		 	 * RESERVED = 0
		 	 * HIGH TIME = 16
		 	 * LOW TIME = 32 */
		    /* This translates to a CLKOUT1_DIVDE of 48, a CLKOUT1_DUTY_CYCLE of 0.666
		     * and a phase offset of 3x45° relative to the VCO */
			DI = 16'b011_0_010000_100000;
			DEN <= 1;
			DWE <= 1;
			step <= 1;
		/* Next, we will disable DEN and DWE, as soon as DRDY and LOCK are achieved again */
		end else if (led[7] && step == 1) begin
			DEN <= 0;
			DWE <= 0;
			step <= 2;
		/* Now we will write into ClkReg2 for CLKOUT1 */
		end else if (led[7] && DRDY && step == 2) begin
			DEN <= 1;
			DWE <= 1;
			/* Address of ClkReg2 of CLKOUT1 */
			DADDR = 7'h0B;
			/* RESERVED = 000000
			 * MX = 2b'00
			 * EDGE = 0
			 * NO COUNT = 0
			 * DELAY TIME = 3 */
			/* This will add an additional phase delay as high as 3 VCO clock cycles */
			DI <= 16'b000000_00_0_0_000011;
			step <= 3;
		end else if (led[7] && step == 3) begin
			/* Disable Read/Write again */
			DEN <= 0;
			DWE <= 0;
			step <= 4;
		end
	end
endmodule
