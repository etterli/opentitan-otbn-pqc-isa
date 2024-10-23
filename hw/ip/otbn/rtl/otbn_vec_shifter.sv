// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module otbn_vec_shifter
  import otbn_pkg::*;
(
  input  logic [WLEN-1:0]         shifter_in_upper_i,
  input  logic [WLEN-1:0]         shifter_in_lower_i,
  input  logic                    shift_right_i,
  input  logic [$clog2(WLEN)-1:0] shift_amt_i,
  input  elen_bignum_e            elen_i,

  output logic [WLEN-1:0] shifter_res_o
);
  logic [WLEN*2-1:0] shifter_in;
  logic [WLEN*2-1:0] shifter_out;
  logic [WLEN-1:0]   shifter_in_lower_reverse, shifter_out_lower, shifter_out_lower_reverse,
                     shifter_masked, vector_mask, unused_shifter_out_upper;

  for (genvar i = 0; i < WLEN; i++) begin : g_shifter_in_lower_reverse
    assign shifter_in_lower_reverse[i] = shifter_in_lower_i[WLEN-i-1];
  end

  assign shifter_in = {shifter_in_upper_i, shift_right_i ? shifter_in_lower_i
                                                         : shifter_in_lower_reverse};

  assign shifter_out = shifter_in >> shift_amt_i;

  // Mask out overflowing bits of the adjacent vector elements
  always_comb begin
    unique case(elen_i)
    VecElen16:  vector_mask = { 16{{ 16{1'b1}} & ((1 << ( 16-shift_amt_i)) - 1)}};
    VecElen32:  vector_mask = {  8{{ 32{1'b1}} & ((1 << ( 32-shift_amt_i)) - 1)}};
    VecElen64:  vector_mask = {  4{{ 64{1'b1}} & ((1 << ( 64-shift_amt_i)) - 1)}};
    VecElen128: vector_mask = {  2{{128{1'b1}} & ((1 << (128-shift_amt_i)) - 1)}};
    default:    vector_mask = {256{1'b1}}; // 256b is never masked
    endcase
  end
  assign shifter_masked = shifter_out[WLEN-1:0] & vector_mask;

  // assign shifter_out_lower = (elen_i == VecElen256) ? shifter_out[WLEN-1:0] : shifter_masked;
  assign shifter_out_lower = shifter_masked;

  for (genvar i = 0; i < WLEN; i++) begin : g_shifter_out_lower_reverse
    assign shifter_out_lower_reverse[i] = shifter_out_lower[WLEN-i-1];
  end

  assign shifter_res_o = shift_right_i ? shifter_out[WLEN-1:0] : shifter_out_lower_reverse;

  // Only the lower WLEN bits of the shift result are returned.
  assign unused_shifter_out_upper = shifter_out[WLEN*2-1:WLEN];
endmodule
