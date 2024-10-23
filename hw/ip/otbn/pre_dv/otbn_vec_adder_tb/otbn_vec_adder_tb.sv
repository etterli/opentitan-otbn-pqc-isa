// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module otbn_vec_adder_tb
  import otbn_pkg::*;
  ();

  timeunit 1ns;
  timeprecision 1ps;
  localparam time CLK_PERIOD         = 50ns;
  localparam time ACQ_DELAY          = 30ns;
  localparam time APPL_DELAY         = 10ns;
  localparam time EVAL_DELAY         = ACQ_DELAY + 5ns;
  localparam unsigned RST_CLK_CYCLES = 10;

  logic  clk, rst_n;

  clk_rst_gen #(
      .ClkPeriod   (CLK_PERIOD),
      .RstClkCycles(RST_CLK_CYCLES)
  ) i_clk_rst_gen (
      .clk_o (clk),
      .rst_no(rst_n)
  );

  // Signals to the dut
  logic [VLEN-1:0]     operand_a;
  logic [VLEN-1:0]     operand_b;
  logic                operand_b_invert;
  logic [NVecProc-1:0] carries_in;
  elen_bignum_e    elen;

  // Signals from the dut
  logic [VLEN-1:0]     sum;
  logic [NVecProc-1:0] carries_out;

  ///////////////
  // DUT       //
  ///////////////
  // The tested module must be named "dut" (see run.tcl)
  otbn_vec_adder dut (
    .operand_a_i        (operand_a),
    .operand_b_i        (operand_b),
    .operand_b_invert_i (operand_b_invert),
    .carries_in_i       (carries_in),
    .elen_i             (elen),

    .sum_o              (sum),
    .carries_out_o      (carries_out)
  );

  ///////////////
  // Testbench //
  ///////////////

  // packed result to pass to queue
  typedef struct packed {
    logic [VLEN-1:0]     sum;
    logic [NVecProc-1:0] carries_out;
  } response_t;

  // Response queues to pass results to checker
  response_t acq_response_queue[$],
             exp_response_queue[$];

  integer n_errs, n_checks, all_stim_applied;

  initial begin : application_block
    response_t gold_response;
    integer stim_fd;
    integer ret_code;
    integer elen_size;

    all_stim_applied = 0;
    // Testbench is started from parent directory
    stim_fd = $fopen("./otbn_vec_adder_tb/otbn_vec_adder.golden", "r");
    if (stim_fd == 0) begin
      $fatal(1, "Could not open stimuli file!");
    end

    wait (rst_n);
    while (!$feof(stim_fd)) begin
      @(posedge clk);
      #(APPL_DELAY);
      // Set inputs
      ret_code = $fscanf(stim_fd, "%d, 0x%h, 0x%h, 0x%h, %d, 0x%h, 0x%h\n",
                        elen_size, operand_a, operand_b,
                        carries_in, operand_b_invert,
                        gold_response.sum, gold_response.carries_out);
      if (ret_code == 0) begin
        $error("Could not parse line of golden vector");
      end

      unique case (elen_size)
        16: elen = VecElen16;
        32: elen = VecElen32;
        64: elen = VecElen64;
        128: elen = VecElen128;
        256: elen = VecElen256;
        default: $error("Invalid ELEN in golden vector");
      endcase

      // $display("Testing ELEN = %d ", elen,
      //          "a = 0x%h ", operand_a,
      //          "b = 0x%h ", operand_b,
      //          "cin = 0x%h ", carries_in,
      //          "invert = %d ", operand_b_invert,
      //          "s = 0x%h ", gold_response.sum,
      //          "cou = 0x%h", gold_response.carries_out);

      // Publish the expected values
      exp_response_queue.push_back(gold_response);
    end
    $fclose(stim_fd);
    all_stim_applied = 1; // Signal finish
  end

  initial begin : acquire_block
    response_t response;
    wait (rst_n);

    while (1) begin
      @(posedge clk);
      #(ACQ_DELAY);
      // Capture output
      response.sum = sum;
      response.carries_out = carries_out;
      acq_response_queue.push_back(response);
    end
  end

  initial begin : checker_block
    response_t acq_resp, exp_resp;
    n_errs = 0;
    n_checks = 0;

    wait (rst_n);
    while (!all_stim_applied) begin
      @(posedge clk);
      #(EVAL_DELAY);
      if (acq_response_queue.size() > 0 && exp_response_queue.size() > 0) begin
        n_checks += 1;
        acq_resp = acq_response_queue.pop_front();
        exp_resp = exp_response_queue.pop_front();
        if (acq_resp !== exp_resp) begin
            n_errs = n_errs + 1;
            $display("Mismatch occurred at %dns, check %d!\n ", $time, n_checks,
                    "Acquired (sum, carries): %x, %x\n ", acq_resp.sum, acq_resp.carries_out,
                    "Expected (sum, carries): %x, %x\n ", exp_resp.sum, exp_resp.carries_out);
        end
      end
    end
    if (n_errs > 0) begin
      $display("Test ***FAILED*** with ", n_errs, " mismatches out of ", n_checks, " checks.");
    end else begin
      $display("Test ***PASSED*** with ", n_errs, " mismatches out of ", n_checks, " checks.");
    end
    $finish();
  end

endmodule
