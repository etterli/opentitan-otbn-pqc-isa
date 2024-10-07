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
bn.addvm.16H w10, w0, w1

li           x2, 20
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.addvm.8S  w11, w2, w3

li           x2, 20
la           x3, mod64
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.addvm.4D  w12, w4, w5

li           x2, 20
la           x3, mod128
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20

bn.addvm.2Q   w13, w6, w7
bn.addvm.2Q   w14, w8, w9

addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  16bit vector mod16 for instruction addvm
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
  16bit vector vec16a0 for instruction addvm
  vec16a0 = [65535, 65535, 3791, 7582, 65535, 0, 3791, 7582, 65535, 65535, 3791, 7582, 65535, 65535, 3791, 7582]
  vec16a0 = 0xffffffff0ecf1d9effff00000ecf1d9effffffff0ecf1d9effffffff0ecf1d9e
*/
vec16a0:
  .word 0x0ecf1d9e
  .word 0xffffffff
  .word 0x0ecf1d9e
  .word 0xffffffff
  .word 0x0ecf1d9e
  .word 0xffff0000
  .word 0x0ecf1d9e
  .word 0xffffffff

/*
  16bit vector vec16b0 for instruction addvm
  vec16b0 = [2024, 1, 2527, 7580, 2024, 32767, 2527, 7580, 2024, 1, 2527, 7580, 2024, 1, 2527, 7580]
  vec16b0 = 0x07e8000109df1d9c07e87fff09df1d9c07e8000109df1d9c07e8000109df1d9c
*/
vec16b0:
  .word 0x09df1d9c
  .word 0x07e80001
  .word 0x09df1d9c
  .word 0x07e80001
  .word 0x09df1d9c
  .word 0x07e87fff
  .word 0x09df1d9c
  .word 0x07e80001

/*
  Result of 16bit addvm
  res = [59976, 57953, 6318, 7579, 59976, 25184, 6318, 7579, 59976, 57953, 6318, 7579, 59976, 57953, 6318, 7579]
  res = 0xea48e26118ae1d9bea48626018ae1d9bea48e26118ae1d9bea48e26118ae1d9b
*/

/*
  32bit vector mod32 for instruction addvm
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
  32bit vector vec32a0 for instruction addvm
  vec32a0 = [4294967295, 4294967295, 4190208, 8380416, 4294967295, 0, 4190208, 8380416]
  vec32a0 = 0xffffffffffffffff003ff000007fe000ffffffff00000000003ff000007fe000
*/
vec32a0:
  .word 0x007fe000
  .word 0x003ff000
  .word 0x00000000
  .word 0xffffffff
  .word 0x007fe000
  .word 0x003ff000
  .word 0xffffffff
  .word 0xffffffff

/*
  32bit vector vec32b0 for instruction addvm
  vec32b0 = [2024, 1, 2793472, 8380414, 2024, 2147483647, 2793472, 8380414]
  vec32b0 = 0x000007e800000001002aa000007fdffe000007e87fffffff002aa000007fdffe
*/
vec32b0:
  .word 0x007fdffe
  .word 0x002aa000
  .word 0x7fffffff
  .word 0x000007e8
  .word 0x007fdffe
  .word 0x002aa000
  .word 0x00000001
  .word 0x000007e8

/*
  Result of 32bit addvm
  res = [4286588902, 4286586879, 6983680, 8380413, 4286588902, 2139103230, 6983680, 8380413]
  res = 0xff8027e6ff801fff006a9000007fdffdff8027e67f801ffe006a9000007fdffd
*/

/*
  64bit vector mod64 for instruction addvm
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
  64bit vector vec64a0 for instruction addvm
  vec64a0 = [18446744073709551615, 18446744073709551615, 4190208, 8380416]
  vec64a0 = 0xffffffffffffffffffffffffffffffff00000000003ff00000000000007fe000
*/
vec64a0:
  .word 0x007fe000
  .word 0x00000000
  .word 0x003ff000
  .word 0x00000000
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff

/*
  64bit vector vec64b0 for instruction addvm
  vec64b0 = [2024, 1, 2793472, 8380414]
  vec64b0 = 0x00000000000007e8000000000000000100000000002aa00000000000007fdffe
*/
vec64b0:
  .word 0x007fdffe
  .word 0x00000000
  .word 0x002aa000
  .word 0x00000000
  .word 0x00000001
  .word 0x00000000
  .word 0x000007e8
  .word 0x00000000

/*
  Result of 64bit addvm
  res = [18446744073701173222, 18446744073701171199, 6983680, 8380413]
  res = 0xffffffffff8027e6ffffffffff801fff00000000006a900000000000007fdffd
*/

/*
  128bit vector mod128 for instruction addvm
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
  128bit vector vec128a0 for instruction addvm
  vec128a0 = [340282366920938463463374607431768211455, 340282366920938463463374607431768211455]
  vec128a0 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
vec128a0:
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff

/*
  128bit vector vec128a1 for instruction addvm
  vec128a1 = [4190208, 8380416]
  vec128a1 = 0x000000000000000000000000003ff000000000000000000000000000007fe000
*/
vec128a1:
  .word 0x007fe000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x003ff000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b0 for instruction addvm
  vec128b0 = [2024, 1]
  vec128b0 = 0x000000000000000000000000000007e800000000000000000000000000000001
*/
vec128b0:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x000007e8
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b1 for instruction addvm
  vec128b1 = [2793472, 8380414]
  vec128b1 = 0x000000000000000000000000002aa000000000000000000000000000007fdffe
*/
vec128b1:
  .word 0x007fdffe
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x002aa000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  Result of 128bit addvm
  res = [340282366920938463463374607431759833062, 340282366920938463463374607431759831039]
  res = 0xffffffffffffffffffffffffff8027e6ffffffffffffffffffffffffff801fff
*/

/*
  Result of 128bit addvm
  res = [6983680, 8380413]
  res = 0x000000000000000000000000006a9000000000000000000000000000007fdffd
*/
