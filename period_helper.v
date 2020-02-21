/*
 * period_helper.v: Determines the period of the given input. It differs
 *	from period_count.v mainly regarding the LOCKED input. It tells the module
 *	that the input is reliable.
 * author: Till Mahlburg
 * year: 2020
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

module period_helper #(
	parameter RESOLUTION = 0.01) (
	input	clk,
	input 	reset,
	/* tells the module, that the input is reliable */
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

