// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Vectorized Transposer
 *
 * This module transposes the elements of two input vectors in two different ways.
 * It only supports 16b, 32b, 64b, 128b. The 256b value is not supported!
 *
 * If we have two vectors with 4 elements the transpositions are as follows:
 * Transposition            TRN1                          TRN2
 *                 +----+----+----+----+         +----+----+----+----+
 * Input A         | A3 | A2 | A1 | A0 |         | A3 | A2 | A1 | A0 |
 *                 +----+----+----+----+         +----+----+----+----+
 *                 +----+----+----+----+         +----+----+----+----+
 * Input B         | B3 | B2 | B1 | B0 |         | B3 | B2 | B1 | B0 |
 *                 +----+----+----+----+         +----+----+----+----+
 *                 +----+----+----+----+         +----+----+----+----+
 * Result          | B2 | A2 | B0 | A0 |         | B3 | A3 | B1 | A1 |
 *                 +----+----+----+----+         +----+----+----+----+
 */

module otbn_vec_transposer
  import otbn_pkg::*;
(
  input  logic[VLEN-1:0] operand_a_i,
  input  logic[VLEN-1:0] operand_b_i,
  input  logic           is_trn1_i,
  // Ugly: elen_bignum_e contains the 256b variant but we don't support it and return 'b0
  // TODO: Finda a cleaner solution, maybe crash?
  input  elen_bignum_e   elen_i,

  output logic[VLEN-1:0] result_o
);
  logic [VLEN-1:0] result_trn1_16b;
  logic [VLEN-1:0] result_trn1_32b;
  logic [VLEN-1:0] result_trn1_64b;
  logic [VLEN-1:0] result_trn1_128b;
  logic [VLEN-1:0] result_trn2_16b;
  logic [VLEN-1:0] result_trn2_32b;
  logic [VLEN-1:0] result_trn2_64b;
  logic [VLEN-1:0] result_trn2_128b;

  always_comb begin
    result_trn1_16b  = 'b0;
    result_trn1_32b  = 'b0;
    result_trn1_64b  = 'b0;
    result_trn1_128b = 'b0;
    result_trn2_16b  = 'b0;
    result_trn2_32b  = 'b0;
    result_trn2_64b  = 'b0;
    result_trn2_128b = 'b0;

    result_o = 'b0;

    // This is not nice. We specify the same loop for each ELEN type.
    // There is certainly a nicer solution..
    // Idea: A giant MUX structure which handles each 16b chunk separately?
    unique case (elen_i)
      VecElen16: begin
        localparam int Elen = 16;
        localparam int NumElem = 16;
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn1_16b
          result_trn1_16b[i_elem*Elen+:Elen]     = operand_a_i[i_elem*Elen+:Elen];
          result_trn1_16b[(i_elem+1)*Elen+:Elen] = operand_b_i[i_elem*Elen+:Elen];
        end
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn2_16b
          result_trn2_16b[i_elem*Elen+:Elen]     = operand_a_i[(i_elem+1)*Elen+:Elen];
          result_trn2_16b[(i_elem+1)*Elen+:Elen] = operand_b_i[(i_elem+1)*Elen+:Elen];
        end
        result_o = is_trn1_i ? result_trn1_16b : result_trn2_16b;
      end
      VecElen32: begin
        localparam int Elen = 32;
        localparam int NumElem = 8;
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn1_32b
          result_trn1_32b[i_elem*Elen+:Elen]     = operand_a_i[i_elem*Elen+:Elen];
          result_trn1_32b[(i_elem+1)*Elen+:Elen] = operand_b_i[i_elem*Elen+:Elen];
        end
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn2_32b
          result_trn2_32b[i_elem*Elen+:Elen]     = operand_a_i[(i_elem+1)*Elen+:Elen];
          result_trn2_32b[(i_elem+1)*Elen+:Elen] = operand_b_i[(i_elem+1)*Elen+:Elen];
        end
        result_o = is_trn1_i ? result_trn1_32b : result_trn2_32b;
      end
      VecElen64: begin
        localparam int Elen = 64;
        localparam int NumElem = 4;
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn1_64b
          result_trn1_64b[i_elem*Elen+:Elen]     = operand_a_i[i_elem*Elen+:Elen];
          result_trn1_64b[(i_elem+1)*Elen+:Elen] = operand_b_i[i_elem*Elen+:Elen];
        end
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn2_64b
          result_trn2_64b[i_elem*Elen+:Elen]     = operand_a_i[(i_elem+1)*Elen+:Elen];
          result_trn2_64b[(i_elem+1)*Elen+:Elen] = operand_b_i[(i_elem+1)*Elen+:Elen];
        end
        result_o = is_trn1_i ? result_trn1_64b : result_trn2_64b;
      end
      VecElen128: begin
        localparam int Elen = 128;
        localparam int NumElem = 2;
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn1_128b
          result_trn1_128b[i_elem*Elen+:Elen]     = operand_a_i[i_elem*Elen+:Elen];
          result_trn1_128b[(i_elem+1)*Elen+:Elen] = operand_b_i[i_elem*Elen+:Elen];
        end
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn2_128b
          result_trn2_128b[i_elem*Elen+:Elen]     = operand_a_i[(i_elem+1)*Elen+:Elen];
          result_trn2_128b[(i_elem+1)*Elen+:Elen] = operand_b_i[(i_elem+1)*Elen+:Elen];
        end
        result_o = is_trn1_i ? result_trn1_128b : result_trn2_128b;
      end
      default: result_o = 'b0;// We do not support the 256b case -> TODO: Crash with assertion?
    endcase
  end
endmodule
