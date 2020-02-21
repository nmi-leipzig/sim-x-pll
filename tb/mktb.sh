#! /bin/sh

#####################################################
# Name: mktb.sh
#
# Creates the skeleton of a Verilog testbench
#
# Usage: mktb.sh <name of the module to test>
#
# Date of Creation: 2019-08-30
######################################################

# Functions

usage () {
cat <<- EOF
usage: $(basename $0) <name of the module> [-h]

Creates the skeleton of a Verilog testbench.

OPTIONS:
    -h shows this help
EOF
}

tb () {
cat << EOF
/*
 * $1_tb.v: Test bench for $1.v
 * author: Till Mahlburg
 * year: $(date +%Y)
 * organization: Universität Leipzig
 * license: ISC
 *
 */

\`timescale 1 ns / 1 ps

\`ifndef WAIT_INTERVAL
	\`define WAIT_INTERVAL 1000
\`endif

module $1_tb ();
	reg rst;

	integer pass_count;
	integer fail_count;

	/* adjust according to the number of test cases */
	localparam total = ;

	$1 dut(
	);

	initial begin
		\$dumpfile("$1_tb.vcd");
		\$dumpvars(0, $1_tb);

		rst = 0;

		pass_count = 0;
		fail_count = 0;

		#10;
		rst = 1;
		#10;

		/* TEST CASES */

		if ((pass_count + fail_count) == total) begin
			\$display("PASSED: number of test cases");
			pass_count = pass_count + 1;
		end else begin
			\$display("FAILED: number of test cases");
			fail_count = fail_count + 1;
		end

		\$display("%0d/%0d PASSED", pass_count, (total + 1));
		\$finish;
	end
endmodule
EOF
}

# Main functionality. Evaluates the given arguments.

main () {
    while getopts "h" opt; do
        case $opt in
            h )     usage ;;
            \? )    usage
                    exit 1 ;;
            esac
    done
    shift $((OPTIND - 1))

    tb "$@"

}
main "$@"
