/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors into w0-w9
*/
addi x2, x0, 0

la     x3, vec16a0
bn.lid x2++, 0(x3)
la     x3, vec16b0
bn.lid x2++, 0(x3)

la     x3, vec32a0
bn.lid x2++, 0(x3)
la     x3, vec32b0
bn.lid x2++, 0(x3)

la     x3, vec64a0
bn.lid x2++, 0(x3)
la     x3, vec64b0
bn.lid x2++, 0(x3)

la     x3, vec128a0
bn.lid x2++, 0(x3)
la     x3, vec128b0
bn.lid x2++, 0(x3)

la     x3, vec128a1
bn.lid x2++, 0(x3)
la     x3, vec128b1
bn.lid x2++, 0(x3)

/*
  Results are stored in WDRS:
  16b: w10
  32b: w11
  64b: w12
  128b0: w13
  128b1: w14
*/

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod16
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.subvm.16H w10, w0, w1

li           x2, 20
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.subvm.8S  w11, w2, w3

li           x2, 20
la           x3, mod64
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.subvm.4D  w12, w4, w5

li           x2, 20
la           x3, mod128
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20

bn.subvm.2Q   w13, w6, w7
bn.subvm.2Q   w14, w8, w9

addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  16bit vector mod16 for instruction subvm
  mod16 = [7583]
  mod16 = 0x0000000000000000000000000000000000000000000000000000000000001d9f
*/
mod16:
  .word 0x00001d9f
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  16bit vector vec16a0 for instruction subvm
  vec16a0 = [0, 0, 3791, 7580, 0, 65535, 3791, 7580, 0, 0, 3791, 7580, 0, 0, 3791, 7580]
  vec16a0 = 0x000000000ecf1d9c0000ffff0ecf1d9c000000000ecf1d9c000000000ecf1d9c
*/
vec16a0:
  .word 0x0ecf1d9c
  .word 0x00000000
  .word 0x0ecf1d9c
  .word 0x00000000
  .word 0x0ecf1d9c
  .word 0x0000ffff
  .word 0x0ecf1d9c
  .word 0x00000000

/*
  16bit vector vec16b0 for instruction subvm
  vec16b0 = [2048, 1, 2527, 7582, 2048, 32767, 2527, 7582, 2048, 1, 2527, 7582, 2048, 1, 2527, 7582]
  vec16b0 = 0x0800000109df1d9e08007fff09df1d9e0800000109df1d9e0800000109df1d9e
*/
vec16b0:
  .word 0x09df1d9e
  .word 0x08000001
  .word 0x09df1d9e
  .word 0x08000001
  .word 0x09df1d9e
  .word 0x08007fff
  .word 0x09df1d9e
  .word 0x08000001

/*
  Result of 16bit subvm
  res = [5535, 7582, 1264, 7581, 5535, 32768, 1264, 7581, 5535, 7582, 1264, 7581, 5535, 7582, 1264, 7581]
  res = 0x159f1d9e04f01d9d159f800004f01d9d159f1d9e04f01d9d159f1d9e04f01d9d
*/

/*
  32bit vector mod32 for instruction subvm
  mod32 = [8380417]
  mod32 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod32:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32a0 for instruction subvm
  vec32a0 = [0, 0, 4190208, 8380414, 0, 4294967295, 4190208, 8380414]
  vec32a0 = 0x0000000000000000003ff000007fdffe00000000ffffffff003ff000007fdffe
*/
vec32a0:
  .word 0x007fdffe
  .word 0x003ff000
  .word 0xffffffff
  .word 0x00000000
  .word 0x007fdffe
  .word 0x003ff000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32b0 for instruction subvm
  vec32b0 = [2048, 1, 2793472, 8380416, 2048, 2147483647, 2793472, 8380416]
  vec32b0 = 0x0000080000000001002aa000007fe000000008007fffffff002aa000007fe000
*/
vec32b0:
  .word 0x007fe000
  .word 0x002aa000
  .word 0x7fffffff
  .word 0x00000800
  .word 0x007fe000
  .word 0x002aa000
  .word 0x00000001
  .word 0x00000800

/*
  Result of 32bit subvm
  res = [8378369, 8380416, 1396736, 8380415, 8378369, 2147483648, 1396736, 8380415]
  res = 0x007fd801007fe00000155000007fdfff007fd8018000000000155000007fdfff
*/

/*
  64bit vector mod64 for instruction subvm
  mod64 = [8380417]
  mod64 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod64:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64a0 for instruction subvm
  vec64a0 = [0, 0, 4190208, 8380414]
  vec64a0 = 0x0000000000000000000000000000000000000000003ff00000000000007fdffe
*/
vec64a0:
  .word 0x007fdffe
  .word 0x00000000
  .word 0x003ff000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64b0 for instruction subvm
  vec64b0 = [2048, 1, 2793472, 8380416]
  vec64b0 = 0x0000000000000800000000000000000100000000002aa00000000000007fe000
*/
vec64b0:
  .word 0x007fe000
  .word 0x00000000
  .word 0x002aa000
  .word 0x00000000
  .word 0x00000001
  .word 0x00000000
  .word 0x00000800
  .word 0x00000000

/*
  Result of 64bit subvm
  res = [8378369, 8380416, 1396736, 8380415]
  res = 0x00000000007fd80100000000007fe000000000000015500000000000007fdfff
*/

/*
  128bit vector mod128 for instruction subvm
  mod128 = [8380417]
  mod128 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod128:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128a0 for instruction subvm
  vec128a0 = [0, 0]
  vec128a0 = 0x0000000000000000000000000000000000000000000000000000000000000000
*/
vec128a0:
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128a1 for instruction subvm
  vec128a1 = [4190208, 8380414]
  vec128a1 = 0x000000000000000000000000003ff000000000000000000000000000007fdffe
*/
vec128a1:
  .word 0x007fdffe
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x003ff000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b0 for instruction subvm
  vec128b0 = [2048, 1]
  vec128b0 = 0x0000000000000000000000000000080000000000000000000000000000000001
*/
vec128b0:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000800
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b1 for instruction subvm
  vec128b1 = [2793472, 8380416]
  vec128b1 = 0x000000000000000000000000002aa000000000000000000000000000007fe000
*/
vec128b1:
  .word 0x007fe000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x002aa000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  Result of 128bit subvm
  res = [8378369, 8380416]
  res = 0x000000000000000000000000007fd801000000000000000000000000007fe000
*/

/*
  Result of 128bit subvm
  res = [1396736, 8380415]
  res = 0x00000000000000000000000000155000000000000000000000000000007fdfff
*/
