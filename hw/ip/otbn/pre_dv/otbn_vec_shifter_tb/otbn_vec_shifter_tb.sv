// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module otbn_vec_shifter_tb
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
  logic [WLEN-1:0]         shifter_in_upper;
  logic [WLEN-1:0]         shifter_in_lower;
  logic                    shift_right;
  logic [$clog2(WLEN)-1:0] shift_amt;
  elen_bignum_e            elen;

  // Signals from the dut
  logic [WLEN-1:0] shifter_res;

  ///////////////
  // DUT       //
  ///////////////
  // The tested module must be named "dut" (see run.tcl)
  otbn_vec_shifter dut (
    .shifter_in_upper_i(shifter_in_upper),
    .shifter_in_lower_i(shifter_in_lower),
    .shift_right_i(shift_right),
    .shift_amt_i(shift_amt),
    .elen_i(elen),
    .shifter_res_o(shifter_res)
  );

  ///////////////
  // Testbench //
  ///////////////

  // packed result to pass to queue
  typedef struct packed {
    logic [WLEN-1:0] result;
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
    stim_fd = $fopen("./otbn_vec_shifter_tb/otbn_vec_shifter.golden", "r");
    if (stim_fd == 0) begin
      $fatal(1, "Could not open stimuli file!");
    end

    wait (rst_n);
    while (!$feof(stim_fd)) begin
      @(posedge clk);
      #(APPL_DELAY);
      // Set inputs
      ret_code = $fscanf(stim_fd, "%d, 0x%h, 0x%h, %d, %d, 0x%h\n",
                         elen_size, shifter_in_upper, shifter_in_lower,
                         shift_right, shift_amt, gold_response.result);
      if (ret_code == 0) begin
        $error("Could not parse line of golden vector. Error %d", ret_code);
        $fatal("Abort due to corrupted golden vector.");
      end

      unique case (elen_size)
        16: elen = VecElen16;
        32: elen = VecElen32;
        64: elen = VecElen64;
        128: elen = VecElen128;
        256: elen = VecElen256;
        default: $error("Invalid ELEN in golden vector");
      endcase

      // $display("Elen %d, ", elen,
      //          "operand a 0x%h, ", operand_a,
      //          "operand b 0x%h, ", operand_a,
      //          "is trn1 %d, ", is_trn1,
      //          "res 0x%h", gold_response.result);

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
      response.result = shifter_res;
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
                    "Acquired (result): %x\n ", acq_resp.result,
                    "Expected (result): %x\n ", exp_resp.result);
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
