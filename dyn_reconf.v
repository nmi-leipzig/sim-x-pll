/*
 * dyn_reconf.v: Handles the reconfiguration process of the pll.
 * author: Till Mahlburg
 * year: 2020
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

module dyn_reconf (
	input RST,
	input PWRDWN,

	input [6:0] DADDR,
	input DCLK,
	input DEN,
	input DWE,
	input [15:0] DI,

	output reg [15:0] DO,
	output reg DRDY);

	/* registers for dynamic output reconfiguration */
	reg [15:0] ClkReg1[0:6];
	reg [15:0] ClkReg1_FB;

	reg [15:0] ClkReg2[0:6];
	reg [15:0] ClkReg2_FB;

	reg [15:0] DivReg;

	reg [15:0] LockReg[1:3];

	reg [15:0] FiltReg[1:2];

	reg [15:0] PowerReg;

	wire [32:0] CLKOUT_DIVIDE[0:6];
	wire [32:0] CLKOUT_DUTY_CYCLE[0:6];
	wire [32:0] CLKFBOUT_MULT;

	genvar i;

	generate
		for (i = 0; i <= 6; i = i + 1) begin : generate_attributes
			//TODO: No Count
			assign CLKOUT_DIVIDE[i] = ClkReg1[i][11:6] + ClkReg1[i][5:0];
			assign CLKOUT_DUTY_CYCLE[i] = ((ClkReg1[i][11:6] + (ClkReg2[i][7] / 2.0)) / (ClkReg1[i][5:0] - (ClkReg2[i][7] / 2.0)));
		end
	endgenerate

	assign CLKFBOUT_MULT = ClkReg1_FB[11:6] + ClkReg2_FB[5:0];

	always @(posedge DCLK or posedge RST or posedge PWRDWN) begin
		if (PWRDWN) begin
			DRDY <= 1'bx;
			DO <= 16'hXXXX;
		end else if (RST) begin
			DRDY <= 1'b0;
			DO <= 16'h0000;
		end else if (DEN) begin
			DRDY <= 1'b0;
			/* Write */
			if (DWE) begin
				case (DADDR)
					7'h06 : ClkReg1[5] <= DI;
					7'h07 : ClkReg2[5] <= DI;
					7'h08 : ClkReg1[0] <= DI;
					7'h09 : ClkReg2[0] <= DI;
					7'h0A : ClkReg1[1] <= DI;
					7'h0B : ClkReg2[1] <= DI;
					7'h0C : ClkReg1[2] <= DI;
					7'h0D : ClkReg2[2] <= DI;
					7'h0E : ClkReg1[3] <= DI;
					7'h0F : ClkReg2[3] <= DI;
					7'h10 : ClkReg1[4] <= DI;
					7'h11 : ClkReg2[4] <= DI;
					7'h12 : ClkReg1[6] <= DI;
					7'h13 : ClkReg2[6] <= DI;
					7'h14 : ClkReg1_FB <= DI;
					7'h15 : ClkReg2_FB <= DI;
					7'h16 : DivReg <= DI;
					7'h18 : LockReg[1] <= DI;
					7'h19 : LockReg[2] <= DI;
					7'h1A : LockReg[3] <= DI;
					7'h28 : PowerReg <= DI;
					7'h4E : FiltReg[1] <= DI;
					7'h4F : FiltReg[2] <= DI;
					default : $display("default"); //TODO
				endcase


			/* Read */
			end else begin
				case (DADDR)
					7'h06 : DO <= ClkReg1[5];
					7'h07 : DO <= ClkReg2[5];
					7'h08 : DO <= ClkReg1[0];
					7'h09 : DO <= ClkReg2[0];
					7'h0A : DO <= ClkReg1[1];
					7'h0B : DO <= ClkReg2[1];
					7'h0C : DO <= ClkReg1[2];
					7'h0D : DO <= ClkReg2[2];
					7'h0E : DO <= ClkReg1[3];
					7'h0F : DO <= ClkReg2[3];
					7'h10 : DO <= ClkReg1[4];
					7'h11 : DO <= ClkReg2[4];
					7'h12 : DO <= ClkReg1[6];
					7'h13 : DO <= ClkReg2[6];
					7'h14 : DO <= ClkReg1_FB;
					7'h15 : DO <= ClkReg2_FB;
					7'h16 : DO <= DivReg;
					7'h18 : DO <= LockReg[1];
					7'h19 : DO <= LockReg[2];
					7'h1A : DO <= LockReg[3];
					7'h28 : DO <= PowerReg;
					7'h4E : DO <= FiltReg[1];
					7'h4F : DO <= FiltReg[2];
					default : $display("default"); //TODO;
				endcase
			end

		end else begin
			DRDY <= 1'b1;
		end
	end


endmodule
