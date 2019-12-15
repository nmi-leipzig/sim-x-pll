/*
 * divider.v: Simple clock divider based on D-flipflops.
 * author: Till Mahlburg
 * year: 2019
 * organization: Universität Leipzig
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

module divider_synth #(
	parameter FF_NUM = 27) (
	input clk_in,
	input RST,

	output clk_out);

	wire [(FF_NUM - 1):0] D_in;
	wire [(FF_NUM - 1):0] clk_div;
	
	dff dff_0 (
		.clk(clk_in),
		.RST(RST),
		.D(D_in[0]),
		.Q(clk_div[0]));

	genvar i;
	generate
	for (i = 1; i < FF_NUM; i = i + 1) 
		begin : dff_gen_label
		dff dff_inst (
			.clk(clk_div[i-1]),
			.RST(RST),
			.D(D_in[i]),
			.Q(clk_div[i]));
		end
	endgenerate
	
	assign D_in = ~clk_div;
	assign clk_out = clk_div[(FF_NUM - 1)];

endmodule


module dff (
	input D,
	input clk,
	input RST,
	output reg Q);
	
	always @ (posedge clk or posedge RST) begin
		if (RST == 1) begin
			Q <= 1'b0;
		end else begin
			Q <= D;
		end
	end
endmodule
