// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module clk_rst_gen #(
    parameter time     ClkPeriod,
    parameter unsigned RstClkCycles
) (
    output logic clk_o,
    output logic rst_no
);

    timeunit 1ns;
    timeprecision 10ps;

    logic clk;

    // Clock Generation
    initial begin
        clk = 1'b0;
    end
    always begin
        #(ClkPeriod/2);
        clk = ~clk;
    end
    assign clk_o = clk;

    // Reset Generation
    rst_gen #(
        .RstClkCycles(RstClkCycles)
    ) i_rst_gen (
        .clk_i (clk),
        .rst_ni(1'b1),
        .rst_o (),
        .rst_no(rst_no)
    );

endmodule
