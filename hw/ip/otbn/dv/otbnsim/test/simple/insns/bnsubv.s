/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors into w0-w7
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

bn.subv.16H w10, w0, w1
bn.subv.8S  w11, w2, w3
bn.subv.4D  w12, w4, w5
bn.subv.2Q  w13, w6, w7


addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  16bit vector vec16a0 for instruction subv
  vec16a0 = [0, 0, 32767, 32767, 0, 65535, 1684, 0, 0, 0, 65523, 65535, 0, 0, 32767, 65535]
  vec16a0 = 0x000000007fff7fff0000ffff0694000000000000fff3ffff000000007fffffff
*/
vec16a0:
  .word 0x7fffffff
  .word 0x00000000
  .word 0xfff3ffff
  .word 0x00000000
  .word 0x06940000
  .word 0x0000ffff
  .word 0x7fff7fff
  .word 0x00000000

/*
  16bit vector vec16b0 for instruction subv
  vec16b0 = [2048, 1, 32767, 0, 2048, 1, 437, 1, 2048, 1, 1568, 9362, 2048, 1, 32767, 12]
  vec16b0 = 0x080000017fff00000800000101b500010800000106202492080000017fff000c
*/
vec16b0:
  .word 0x7fff000c
  .word 0x08000001
  .word 0x06202492
  .word 0x08000001
  .word 0x01b50001
  .word 0x08000001
  .word 0x7fff0000
  .word 0x08000001

/*
  Result of 16bit subv
  res = [63488, 65535, 0, 32767, 63488, 65534, 1247, 65535, 63488, 65535, 63955, 56173, 63488, 65535, 0, 65523]
  res = 0xf800ffff00007ffff800fffe04dffffff800fffff9d3db6df800ffff0000fff3
*/

/*
  32bit vector vec32a0 for instruction subv
  vec32a0 = [0, 0, 2147483647, 2147483647, 0, 4294967295, 1684, 0]
  vec32a0 = 0x00000000000000007fffffff7fffffff00000000ffffffff0000069400000000
*/
vec32a0:
  .word 0x00000000
  .word 0x00000694
  .word 0xffffffff
  .word 0x00000000
  .word 0x7fffffff
  .word 0x7fffffff
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32b0 for instruction subv
  vec32b0 = [2048, 1, 2147483647, 0, 2048, 1, 437, 1]
  vec32b0 = 0x00000800000000017fffffff000000000000080000000001000001b500000001
*/
vec32b0:
  .word 0x00000001
  .word 0x000001b5
  .word 0x00000001
  .word 0x00000800
  .word 0x00000000
  .word 0x7fffffff
  .word 0x00000001
  .word 0x00000800

/*
  Result of 32bit subv
  res = [4294965248, 4294967295, 0, 2147483647, 4294965248, 4294967294, 1247, 4294967295]
  res = 0xfffff800ffffffff000000007ffffffffffff800fffffffe000004dfffffffff
*/

/*
  64bit vector vec64a0 for instruction subv
  vec64a0 = [0, 0, 9223372036854775807, 9223372036854775807]
  vec64a0 = 0x000000000000000000000000000000007fffffffffffffff7fffffffffffffff
*/
vec64a0:
  .word 0xffffffff
  .word 0x7fffffff
  .word 0xffffffff
  .word 0x7fffffff
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64b0 for instruction subv
  vec64b0 = [2048, 1, 9223372036854775807, 0]
  vec64b0 = 0x000000000000080000000000000000017fffffffffffffff0000000000000000
*/
vec64b0:
  .word 0x00000000
  .word 0x00000000
  .word 0xffffffff
  .word 0x7fffffff
  .word 0x00000001
  .word 0x00000000
  .word 0x00000800
  .word 0x00000000

/*
  Result of 64bit subv
  res = [18446744073709549568, 18446744073709551615, 0, 9223372036854775807]
  res = 0xfffffffffffff800ffffffffffffffff00000000000000007fffffffffffffff
*/

/*
  128bit vector vec128a0 for instruction subv
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
  128bit vector vec128b0 for instruction subv
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
  Result of 128bit subv
  res = [340282366920938463463374607431768209408, 340282366920938463463374607431768211455]
  res = 0xfffffffffffffffffffffffffffff800ffffffffffffffffffffffffffffffff
*/

