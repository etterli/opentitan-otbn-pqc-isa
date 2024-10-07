/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors into w0-w7
*/
addi x2, x0, 0

la     x3, vec16a
bn.lid x2++, 0(x3)
la     x3, vec16b
bn.lid x2++, 0(x3)

la     x3, vec32a
bn.lid x2++, 0(x3)
la     x3, vec32b
bn.lid x2++, 0(x3)

la     x3, vec64a
bn.lid x2++, 0(x3)
la     x3, vec64b
bn.lid x2++, 0(x3)

la     x3, vec128a
bn.lid x2++, 0(x3)
la     x3, vec128b
bn.lid x2++, 0(x3)

/*
  Transposed vectors are written into w10 to w13
*/
bn.trn2.16H w10, w0, w1
bn.trn2.8S  w11, w2, w3
bn.trn2.4D  w12, w4, w5
bn.trn2.2Q  w13, w6, w7

ecall

.section .data
/*
  16bit vector vec16a for instruction trn2
  vec16a = n/a
  vec16a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec16a:
  .word 0x00030002
  .word 0x05000004
  .word 0x07000004
  .word 0x00050008
  .word 0x00900006
  .word 0x00100008
  .word 0x00300008
  .word 0x1000000a

/*
  16bit vector vec16b for instruction trn2
  vec16b = n/a
  vec16b = 0x0100a00003000080000100809000060050000800700000400050004000300020
*/
vec16b:
  .word 0x00300020
  .word 0x00500040
  .word 0x70000040
  .word 0x50000800
  .word 0x90000600
  .word 0x00010080
  .word 0x03000080
  .word 0x0100a000

/*
  Result of 16bit trn2
  res = n/a
  res = 0x0100100003000030000100109000009050000005700007000050050000300003
*/

/*
  32bit vector vec32a for instruction trn2
  vec32a = n/a
  vec32a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec32a:
  .word 0x00030002
  .word 0x05000004
  .word 0x07000004
  .word 0x00050008
  .word 0x00900006
  .word 0x00100008
  .word 0x00300008
  .word 0x1000000a

/*
  32bit vector vec32b for instruction trn2
  vec32b = n/a
  vec32b = 0x0100a00003000080000100809000060050000800700000400050004000300020
*/
vec32b:
  .word 0x00300020
  .word 0x00500040
  .word 0x70000040
  .word 0x50000800
  .word 0x90000600
  .word 0x00010080
  .word 0x03000080
  .word 0x0100a000

/*
  Result of 32bit trn2
  res = n/a
  res = 0x0100a0001000000a000100800010000850000800000500080050004005000004
*/

/*
  64bit vector vec64a for instruction trn2
  vec64a = n/a
  vec64a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec64a:
  .word 0x00030002
  .word 0x05000004
  .word 0x07000004
  .word 0x00050008
  .word 0x00900006
  .word 0x00100008
  .word 0x00300008
  .word 0x1000000a

/*
  64bit vector vec64b for instruction trn2
  vec64b = n/a
  vec64b = 0x0100a00003000080000100809000060050000800700000400050004000300020
*/
vec64b:
  .word 0x00300020
  .word 0x00500040
  .word 0x70000040
  .word 0x50000800
  .word 0x90000600
  .word 0x00010080
  .word 0x03000080
  .word 0x0100a000

/*
  Result of 64bit trn2
  res = n/a
  res = 0x0100a000030000801000000a0030000850000800700000400005000807000004
*/

/*
  128bit vector vec128a for instruction trn2
  vec128a = n/a
  vec128a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec128a:
  .word 0x00030002
  .word 0x05000004
  .word 0x07000004
  .word 0x00050008
  .word 0x00900006
  .word 0x00100008
  .word 0x00300008
  .word 0x1000000a

/*
  128bit vector vec128b for instruction trn2
  vec128b = n/a
  vec128b = 0x0100a00003000080000100809000060050000800700000400050004000300020
*/
vec128b:
  .word 0x00300020
  .word 0x00500040
  .word 0x70000040
  .word 0x50000800
  .word 0x90000600
  .word 0x00010080
  .word 0x03000080
  .word 0x0100a000

/*
  Result of 128bit trn2
  res = n/a
  res = 0x0100a0000300008000010080900006001000000a003000080010000800900006
*/
