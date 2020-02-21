/*
 * duty_cycle_check.v: This module determines the duty cycle of the input
 * 	signal and compares it against the desired duty cycle.
 * author: Till Mahlburg
 * year: 2020
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

module duty_cycle_check #(
	/* duty cycle as decimal (0.5 for 50 % in high) */
	parameter desired_duty_cycle = 0.5,
	parameter clk_period = 10) 	(
	input clk,
	input reset,
	input LOCKED,

	/* 0 - clk duty cycle matches desired_duty_cycle
	 * 1 - clk duty cycle does not match the desired_duty_cycle
	 */
	output reg fail);

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			fail <= 0;
		end else if (LOCKED) begin
			#((clk_period * desired_duty_cycle) - 0.1);
			if (clk != 1) begin
				fail <= 1;
			end
			#0.2;
			if (clk != 0) begin
				fail <= 1;
			end
		end else begin
			fail <= 0;
		end
	end
endmodule
