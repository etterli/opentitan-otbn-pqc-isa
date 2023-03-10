// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/crypto/drivers/entropy.h"

#include "sw/device/lib/base/abs_mmio.h"
#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/multibits.h"

#include "csrng_regs.h"        // Generated
#include "edn_regs.h"          // Generated
#include "entropy_src_regs.h"  // Generated
#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

enum {
  kBaseCsrng = TOP_EARLGREY_CSRNG_BASE_ADDR,
  kBaseEntropySrc = TOP_EARLGREY_ENTROPY_SRC_BASE_ADDR,
  kBaseEdn0 = TOP_EARLGREY_EDN0_BASE_ADDR,
  kBaseEdn1 = TOP_EARLGREY_EDN1_BASE_ADDR,

  /**
   * CSRNG genbits buffer size in uint32_t words.
   */
  kEntropyCsrngBitsBufferNumWords = 4,
};

/**
 * Supported CSRNG application commands.
 * See https://docs.opentitan.org/hw/ip/csrng/doc/#command-header for
 * details.
 */
// TODO(#14542): Harden csrng/edn command fields.
typedef enum entropy_csrng_op {
  kEntropyDrbgOpInstantiate = 1,
  kEntropyDrbgOpReseed = 2,
  kEntropyDrbgOpGenerate = 3,
  kEntropyDrbgOpUpdate = 4,
  kEntropyDrbgOpUnisntantiate = 5,
} entropy_csrng_op_t;

/**
 * CSRNG application interface command header parameters.
 */
typedef struct entropy_csrng_cmd {
  /**
   * Application command ID.
   */
  entropy_csrng_op_t id;
  /**
   * Entropy source enable.
   *
   * Mapped to flag0 in the hardware command interface.
   */
  hardened_bool_t disable_trng_input;
  const entropy_seed_material_t *seed_material;
  /**
   * Generate length. Specified as number of 128bit blocks.
   */
  uint32_t generate_len;
} entropy_csrng_cmd_t;

/**
 * Entropy complex configuration modes.
 *
 * Each enum value is used a confiugration index in `kEntropyComplexConfigs`.
 */
typedef enum entropy_complex_config_id {
  /**
   * Entropy complex in continuous mode. This is the default runtime
   * configuration.
   */
  kEntropyComplexConfigIdContinuous,
  kEntropyComplexConfigIdNumEntries,
} entropy_complex_config_id_t;

/**
 * EDN configuration settings.
 */
typedef struct edn_config {
  /**
   * Base address of the EDN block.
   */
  uint32_t base_address;
  /**
   * Number of generate calls between reseed commands.
   */
  uint32_t reseed_interval;
  /**
   * Downstream CSRNG instantiate command configuration.
   */
  entropy_csrng_cmd_t instantiate;
  /**
   * Downstream CSRNG generate command configuration.
   */
  entropy_csrng_cmd_t generate;
  /**
   * Downstream CSRNG reseed command configuration.
   */
  entropy_csrng_cmd_t reseed;
} edn_config_t;

/**
 * Entropy complex configuration settings.
 *
 * Contains configuration paramenters for entropy_src, csrng, edn0 and edn1.
 */
typedef struct entropy_complex_config {
  /**
   * Configuration identifier.
   */
  entropy_complex_config_id_t id;
  /**
   * If set, FIPS compliant entropy will be generated by this module after being
   * processed by an SP 800-90B compliant conditioning function.
   */
  multi_bit_bool_t fips_enable;
  /**
   * If set, entropy will be routed to a firmware-visible register instead of
   * being distributed to other hardware IPs.
   */
  multi_bit_bool_t route_to_firmware;
  /**
   * If set, raw entropy will be sent to CSRNG, bypassing the conditioner block
   * and disabling the FIPS hardware generated flag.
   */
  multi_bit_bool_t bypass_conditioner;
  /**
   * Enables single bit entropy mode.
   */
  multi_bit_bool_t single_bit_mode;
  /**
   * The size of the window used for health tests.
   */
  uint16_t fips_test_window_size;
  /**
   * The number of health test failures that must occur before an alert is
   * triggered. When set to 0, alerts are disabled.
   */
  uint16_t alert_threshold;
  /**
   * EDN0 configuration.
   */
  edn_config_t edn0;
  /**
   * EDN1 configuration.
   */
  edn_config_t edn1;
} entropy_complex_config_t;

// Entropy complex configuration table. This is expected to be fixed at build
// time. For this reason, it is not recommended to use this table in a ROM
// target unless the values are known to work. In other words, only use in
// mutable code partitions.
static const entropy_complex_config_t
    kEntropyComplexConfigs[kEntropyComplexConfigIdNumEntries] = {
        [kEntropyComplexConfigIdContinuous] =
            {
                .fips_enable = kMultiBitBool4True,
                .route_to_firmware = kMultiBitBool4False,
                .bypass_conditioner = kMultiBitBool4False,
                .single_bit_mode = kMultiBitBool4False,
                .fips_test_window_size = 0x200,
                .alert_threshold = 2,
                .edn0 =
                    {
                        .base_address = kBaseEdn0,
                        .reseed_interval = 32,
                        .instantiate =
                            {
                                .id = kEntropyDrbgOpInstantiate,
                                .disable_trng_input = kHardenedBoolFalse,
                                .seed_material = NULL,
                                .generate_len = 0,
                            },
                        .generate =
                            {
                                .id = kEntropyDrbgOpGenerate,
                                .disable_trng_input = kHardenedBoolFalse,
                                .seed_material = NULL,
                                .generate_len = 8,
                            },
                        .reseed =
                            {
                                .id = kEntropyDrbgOpReseed,
                                .disable_trng_input = kHardenedBoolFalse,
                                .seed_material = NULL,
                                .generate_len = 0,
                            },
                    },
                .edn1 =
                    {
                        .base_address = kBaseEdn1,
                        .reseed_interval = 4,
                        .instantiate =
                            {
                                .id = kEntropyDrbgOpInstantiate,
                                .disable_trng_input = kHardenedBoolFalse,
                                .seed_material = NULL,
                                .generate_len = 0,
                            },
                        .generate =
                            {
                                .id = kEntropyDrbgOpGenerate,
                                .seed_material = NULL,
                                .generate_len = 1,
                            },
                        .reseed =
                            {
                                .id = kEntropyDrbgOpReseed,
                                .disable_trng_input = kHardenedBoolFalse,
                                .seed_material = NULL,
                                .generate_len = 0,
                            },
                    },
            },
};

OT_WARN_UNUSED_RESULT
static status_t csrng_send_app_cmd(uint32_t reg_address,
                                   entropy_csrng_cmd_t cmd) {
  uint32_t reg;
  bool cmd_ready;
  do {
    reg = abs_mmio_read32(kBaseCsrng + CSRNG_SW_CMD_STS_REG_OFFSET);
    cmd_ready = bitfield_bit32_read(reg, CSRNG_SW_CMD_STS_CMD_RDY_BIT);
  } while (!cmd_ready);

#define ENTROPY_CMD(m, i) ((bitfield_field32_t){.mask = m, .index = i})
  // The application command header is not specified as a register in the
  // hardware specification, so the fields are mapped here by hand. The
  // command register also accepts arbitrary 32bit data.
  static const bitfield_field32_t kAppCmdFieldFlag0 = ENTROPY_CMD(0xf, 8);
  static const bitfield_field32_t kAppCmdFieldCmdId = ENTROPY_CMD(0xf, 0);
  static const bitfield_field32_t kAppCmdFieldCmdLen = ENTROPY_CMD(0xf, 4);
  static const bitfield_field32_t kAppCmdFieldGlen = ENTROPY_CMD(0x7ffff, 12);
#undef ENTROPY_CMD

  uint32_t cmd_len = cmd.seed_material == NULL ? 0 : cmd.seed_material->len;

  if (cmd_len & ~kAppCmdFieldCmdLen.mask) {
    return INTERNAL();
  }

  // TODO: Consider removing this since the driver will be constructing these
  // commands internally.
  // Ensure the `seed_material` array is word-aligned, so it can be loaded to a
  // CPU register with natively aligned loads.
  if (cmd.seed_material != NULL &&
      misalignment32_of((uintptr_t)cmd.seed_material->data) != 0) {
    return INTERNAL();
  }

  // Clear the `cs_cmd_req_done` bit, which is asserted whenever a command
  // request is completed, because that bit will be used below to determine if
  // this command request is completed.
  reg = bitfield_bit32_write(0, CSRNG_INTR_STATE_CS_CMD_REQ_DONE_BIT, true);
  abs_mmio_write32(kBaseCsrng + CSRNG_INTR_STATE_REG_OFFSET, reg);

  // Build and write application command header.
  reg = bitfield_field32_write(0, kAppCmdFieldCmdId, cmd.id);
  reg = bitfield_field32_write(reg, kAppCmdFieldCmdLen, cmd_len);
  reg = bitfield_field32_write(reg, kAppCmdFieldGlen, cmd.generate_len);

  if (launder32(cmd.disable_trng_input) == kHardenedBoolTrue) {
    reg = bitfield_field32_write(reg, kAppCmdFieldFlag0, kMultiBitBool4True);
  }

  abs_mmio_write32(reg_address, reg);

  for (size_t i = 0; i < cmd_len; ++i) {
    abs_mmio_write32(reg_address, cmd.seed_material->data[i]);
  }

  // Poll the "command request done" interrupt bit. Once it is set, this
  // signals that the command has been processed and the "status" bit is
  // updated.
  do {
    reg = abs_mmio_read32(kBaseCsrng + CSRNG_INTR_STATE_REG_OFFSET);
  } while (!bitfield_bit32_read(reg, CSRNG_INTR_STATE_CS_CMD_REQ_DONE_BIT));

  // Check the "status" bit, which will be 1 only if there was an error.
  reg = abs_mmio_read32(kBaseCsrng + CSRNG_SW_CMD_STS_REG_OFFSET);
  if (bitfield_bit32_read(reg, CSRNG_SW_CMD_STS_CMD_STS_BIT)) {
    return INTERNAL();
  }

  return OK_STATUS();
}

/**
 * Enables the CSRNG block with the SW application and internal state registers
 * enabled.
 */
static void csrng_configure(void) {
  uint32_t reg =
      bitfield_field32_write(0, CSRNG_CTRL_ENABLE_FIELD, kMultiBitBool4True);
  reg = bitfield_field32_write(reg, CSRNG_CTRL_SW_APP_ENABLE_FIELD,
                               kMultiBitBool4True);
  reg = bitfield_field32_write(reg, CSRNG_CTRL_READ_INT_STATE_FIELD,
                               kMultiBitBool4True);
  abs_mmio_write32(kBaseCsrng + CSRNG_CTRL_REG_OFFSET, reg);
}

/**
 * Stops a given EDN instance.
 *
 * It also resets the EDN CSRNG command buffer to avoid synchronization issues
 * with the upstream CSRNG instance.
 *
 * @param edn_address The based address of the target EDN block.
 */
static void edn_stop(uint32_t edn_address) {
  // FIFO clear is only honored if edn is enabled. This is needed to avoid
  // synchronization issues with the upstream CSRNG instance.
  uint32_t reg = abs_mmio_read32(edn_address + EDN_CTRL_REG_OFFSET);
  abs_mmio_write32(edn_address + EDN_CTRL_REG_OFFSET,
                   bitfield_field32_write(reg, EDN_CTRL_CMD_FIFO_RST_FIELD,
                                          kMultiBitBool4True));

  // Disable EDN and restore the FIFO clear at the same time so that no rogue
  // command can get in after the clear above.
  abs_mmio_write32(edn_address + EDN_CTRL_REG_OFFSET, EDN_CTRL_REG_RESVAL);
}

/**
 * Blocks until EDN instance is ready to execute a new CSNRG command.
 *
 * @param edn_address EDN base address.
 * @returns an error if the EDN error status bit is set.
 */
OT_WARN_UNUSED_RESULT
static status_t edn_ready_block(uint32_t edn_address) {
  uint32_t reg;
  do {
    reg = abs_mmio_read32(edn_address + EDN_SW_CMD_STS_REG_OFFSET);
  } while (!bitfield_bit32_read(reg, EDN_SW_CMD_STS_CMD_RDY_BIT));

  if (bitfield_bit32_read(reg, EDN_SW_CMD_STS_CMD_STS_BIT)) {
    return INTERNAL();
  }
  return OK_STATUS();
}

/**
 * Configures EDN instance based on `config` options.
 *
 * @param config EDN configuration options.
 * @returns error on failure.
 */
OT_WARN_UNUSED_RESULT
static status_t edn_configure(const edn_config_t *config) {
  TRY(csrng_send_app_cmd(config->base_address + EDN_RESEED_CMD_REG_OFFSET,
                         config->reseed));
  TRY(csrng_send_app_cmd(config->base_address + EDN_GENERATE_CMD_REG_OFFSET,
                         config->generate));
  abs_mmio_write32(
      config->base_address + EDN_MAX_NUM_REQS_BETWEEN_RESEEDS_REG_OFFSET,
      config->reseed_interval);

  uint32_t reg =
      bitfield_field32_write(0, EDN_CTRL_EDN_ENABLE_FIELD, kMultiBitBool4True);
  reg = bitfield_field32_write(reg, EDN_CTRL_AUTO_REQ_MODE_FIELD,
                               kMultiBitBool4True);
  abs_mmio_write32(config->base_address + EDN_CTRL_REG_OFFSET, reg);

  TRY(edn_ready_block(config->base_address));
  TRY(csrng_send_app_cmd(config->base_address + EDN_SW_CMD_REQ_REG_OFFSET,
                         config->instantiate));
  return edn_ready_block(config->base_address);
}

/**
 * Stops the current mode of operation and disables the entropy_src module.
 *
 * All configuration registers are set to their reset values to avoid
 * synchronization issues with internal FIFOs.
 */
static void entropy_src_stop(void) {
  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_MODULE_ENABLE_REG_OFFSET,
                   ENTROPY_SRC_MODULE_ENABLE_REG_RESVAL);

  // Set default values for other critical registers to avoid synchronization
  // issues.
  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_ENTROPY_CONTROL_REG_OFFSET,
                   ENTROPY_SRC_ENTROPY_CONTROL_REG_RESVAL);
  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_CONF_REG_OFFSET,
                   ENTROPY_SRC_CONF_REG_RESVAL);
  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_HEALTH_TEST_WINDOWS_REG_OFFSET,
                   ENTROPY_SRC_HEALTH_TEST_WINDOWS_REG_RESVAL);
  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_ALERT_THRESHOLD_REG_OFFSET,
                   ENTROPY_SRC_ALERT_THRESHOLD_REG_RESVAL);
}

/**
 * Disables the entropy complex.
 *
 * The order of operations is important to avoid synchronization issues across
 * blocks. For Example, EDN has FIFOs used to send commands to the downstream
 * CSRNG instances. Such FIFOs are not cleared when EDN is reconfigured, and an
 * explicit clear FIFO command needs to be set by software (see #14506). There
 * may be additional race conditions for downstream blocks that are
 * processing requests from an upstream endpoint (e.g. entropy_src processing a
 * request from CSRNG, or CSRNG processing a request from EDN). To avoid these
 * issues, it is recommended to first disable EDN, then CSRNG and entropy_src
 * last.
 *
 * See hw/ip/csrng/doc/_index.md#module-enable-and-disable for more details.
 */
static void entropy_complex_stop_all(void) {
  edn_stop(kBaseEdn0);
  edn_stop(kBaseEdn1);
  abs_mmio_write32(kBaseCsrng + CSRNG_CTRL_REG_OFFSET, CSRNG_CTRL_REG_RESVAL);
  entropy_src_stop();
}

/**
 * Configures the entropy_src with based on `config` options.
 *
 * @param config Entropy Source configuration options.
 * @return error on failure.
 */
OT_WARN_UNUSED_RESULT
static status_t entropy_src_configure(const entropy_complex_config_t *config) {
  // Control register configuration.
  uint32_t reg = bitfield_field32_write(
      0, ENTROPY_SRC_ENTROPY_CONTROL_ES_ROUTE_FIELD, config->route_to_firmware);
  reg = bitfield_field32_write(reg, ENTROPY_SRC_ENTROPY_CONTROL_ES_TYPE_FIELD,
                               config->bypass_conditioner);
  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_ENTROPY_CONTROL_REG_OFFSET,
                   reg);

  // Config register configuration
  reg = bitfield_field32_write(0, ENTROPY_SRC_CONF_FIPS_ENABLE_FIELD,
                               config->fips_enable);
  reg = bitfield_field32_write(reg,
                               ENTROPY_SRC_CONF_ENTROPY_DATA_REG_ENABLE_FIELD,
                               config->route_to_firmware);
  reg = bitfield_field32_write(reg, ENTROPY_SRC_CONF_THRESHOLD_SCOPE_FIELD,
                               kMultiBitBool4False);
  reg = bitfield_field32_write(reg, ENTROPY_SRC_CONF_RNG_BIT_ENABLE_FIELD,
                               config->single_bit_mode);
  reg = bitfield_field32_write(reg, ENTROPY_SRC_CONF_RNG_BIT_SEL_FIELD, 0);
  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_CONF_REG_OFFSET, reg);

  // Configure health test windw. Conditioning bypass is not supported.
  abs_mmio_write32(
      kBaseEntropySrc + ENTROPY_SRC_HEALTH_TEST_WINDOWS_REG_OFFSET,
      bitfield_field32_write(ENTROPY_SRC_HEALTH_TEST_WINDOWS_REG_RESVAL,
                             ENTROPY_SRC_HEALTH_TEST_WINDOWS_FIPS_WINDOW_FIELD,
                             config->fips_test_window_size));

  // Configure alert threshold
  reg = bitfield_field32_write(
      0, ENTROPY_SRC_ALERT_THRESHOLD_ALERT_THRESHOLD_FIELD,
      config->alert_threshold);
  reg = bitfield_field32_write(
      reg, ENTROPY_SRC_ALERT_THRESHOLD_ALERT_THRESHOLD_INV_FIELD,
      ~config->alert_threshold);
  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_ALERT_THRESHOLD_REG_OFFSET,
                   reg);

  abs_mmio_write32(kBaseEntropySrc + ENTROPY_SRC_MODULE_ENABLE_REG_OFFSET,
                   kMultiBitBool4True);

  // TODO: Add FI checks.
  return OK_STATUS();
}

status_t entropy_complex_init(void) {
  entropy_complex_stop_all();

  const entropy_complex_config_t *config =
      &kEntropyComplexConfigs[kEntropyComplexConfigIdContinuous];
  if (launder32(config->id) != kEntropyComplexConfigIdContinuous) {
    return INTERNAL();
  }

  // TODO: Add health check configuration.

  TRY(entropy_src_configure(config));
  csrng_configure();
  TRY(edn_configure(&config->edn0));
  return edn_configure(&config->edn1);
}

status_t entropy_csrng_instantiate(
    hardened_bool_t disable_trng_input,
    const entropy_seed_material_t *seed_material) {
  return csrng_send_app_cmd(kBaseCsrng + CSRNG_CMD_REQ_REG_OFFSET,
                            (entropy_csrng_cmd_t){
                                .id = kEntropyDrbgOpInstantiate,
                                .disable_trng_input = disable_trng_input,
                                .seed_material = seed_material,
                                .generate_len = 0,
                            });
}

status_t entropy_csrng_reseed(hardened_bool_t disable_trng_input,
                              const entropy_seed_material_t *seed_material) {
  return csrng_send_app_cmd(kBaseCsrng + CSRNG_CMD_REQ_REG_OFFSET,
                            (entropy_csrng_cmd_t){
                                .id = kEntropyDrbgOpReseed,
                                .disable_trng_input = disable_trng_input,
                                .seed_material = seed_material,
                                .generate_len = 0,
                            });
}

status_t entropy_csrng_update(const entropy_seed_material_t *seed_material) {
  return csrng_send_app_cmd(kBaseCsrng + CSRNG_CMD_REQ_REG_OFFSET,
                            (entropy_csrng_cmd_t){
                                .id = kEntropyDrbgOpUpdate,
                                .seed_material = seed_material,
                                .generate_len = 0,
                            });
}

status_t entropy_csrng_generate_start(
    const entropy_seed_material_t *seed_material, size_t len) {
  // Round up the number of 128bit blocks. Aligning with respect to uint32_t.
  // TODO(#6112): Consider using a canonical reference for alignment operations.
  const uint32_t num_128bit_blocks = (len + 3) / 4;
  return csrng_send_app_cmd(kBaseCsrng + CSRNG_CMD_REQ_REG_OFFSET,
                            (entropy_csrng_cmd_t){
                                .id = kEntropyDrbgOpGenerate,
                                .seed_material = seed_material,
                                .generate_len = num_128bit_blocks,
                            });
}

status_t entropy_csrng_generate_data_get(uint32_t *buf, size_t len) {
  for (size_t i = 0; i < len; ++i) {
    // Block until there is more data available in the genbits buffer. CSRNG
    // generates data in 128bit chunks (i.e. 4 words).
    static_assert(kEntropyCsrngBitsBufferNumWords == 4,
                  "kEntropyCsrngBitsBufferNumWords must be a power of 2.");
    if (i & (kEntropyCsrngBitsBufferNumWords - 1)) {
      uint32_t reg;
      do {
        reg = abs_mmio_read32(kBaseCsrng + CSRNG_GENBITS_VLD_REG_OFFSET);
      } while (!bitfield_bit32_read(reg, CSRNG_GENBITS_VLD_GENBITS_VLD_BIT));
    }
    buf[i] = abs_mmio_read32(kBaseCsrng + CSRNG_GENBITS_REG_OFFSET);
  }
  return OK_STATUS();
}

status_t entropy_csrng_generate(const entropy_seed_material_t *seed_material,
                                uint32_t *buf, size_t len) {
  TRY(entropy_csrng_generate_start(seed_material, len));
  return entropy_csrng_generate_data_get(buf, len);
}

status_t entropy_csrng_uninstantiate(void) {
  return csrng_send_app_cmd(kBaseCsrng + CSRNG_CMD_REQ_REG_OFFSET,
                            (entropy_csrng_cmd_t){
                                .id = kEntropyDrbgOpUpdate,
                                .seed_material = NULL,
                                .generate_len = 0,
                            });
}
